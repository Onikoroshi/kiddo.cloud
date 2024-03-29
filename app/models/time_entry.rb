class TimeEntry < ApplicationRecord
  include ClassyEnum::ActiveRecord

  belongs_to :location
  belongs_to :time_recordable, polymorphic: true

  classy_enum_attr :record_type, enum: "TimeEntryType"

  scope :for_staff, -> { where(time_recordable_type: "Staff") }
  scope :for_children, -> { where(time_recordable_type: "Child") }

  scope :for_date, ->(date) { date.present? ? where("time >= ? and time <= ?", date.beginning_of_day, date.end_of_day) : all }
  scope :for_location, ->(location) { location.present? ? where(location: location) : all }

  scope :entering, -> { where(record_type: TimeEntryType[:entry].to_s) }
  scope :exiting, -> { where(record_type: TimeEntryType[:exit].to_s) }

  scope :entries_in_range, -> (range) do
    start_time = range.first
    end_time = range.last
    where(record_type: TimeEntryType[:entry].to_s)
      .where("time >= ? and time <= ?", start_time, end_time)
  end

  scope :all_in_range, -> (start, stop) { where("time IS NULL OR (time >= ? and time <= ?)", start.to_date.beginning_of_day, stop.to_date.end_of_day) }

  def self.staffs
    Staff.where(id: self.for_staff.pluck(:time_recordable_id).uniq).distinct
  end

  def self.count_staff_checked_in
    self.for_staff.entering.pluck(:time_recordable_id).uniq.count
  end

  def self.children
    Child.where(id: self.for_children.pluck(:time_recordable_id).uniq).distinct
  end

  def self.count_children_checked_in
    self.for_children.entering.pluck(:time_recordable_id).uniq.count
  end

  def self.display_hours
    total = self.count_minutes # total seconds

    hours = (total.to_f / 60.0).to_f

    "#{'%.2f' % hours} hours"
  end

  def self.count_minutes
    total_hours = 0.0

    last_clock_in = nil
    last_clock_out = nil
    self.reorder("time ASC").each do |entry|
      if entry.checked_in?
        if last_clock_out.present? && last_clock_in.present?
          chunk = last_clock_out.time.beginning_of_minute - last_clock_in.time.beginning_of_minute
          chunk = chunk.to_f / 60.0
          total_hours += chunk

          last_clock_in = entry
        end

        last_clock_in ||= entry
        last_clock_out = nil
      else
        last_clock_out = entry
      end
    end

    if last_clock_out.present? && last_clock_in.present?
      chunk = last_clock_out.time.beginning_of_minute - last_clock_in.time.beginning_of_minute
      chunk = chunk.to_f / 60.0
      total_hours += chunk
    end

    total_hours
  end

  def self.count_checked_in_at(datetime, entry_hash)
    staff_checked_in_count = 0
    children_checked_in_count = 0

    entry_hash.each do |key, entries|
      last_before = entries.select{|e| e.time.in_time_zone <= datetime}.last

      if last_before.present? && last_before.checked_in?
        if "child" == last_before.time_recordable_type.downcase
          children_checked_in_count += 1
        else
          staff_checked_in_count += 1
        end
      end
      last_start = Time.zone.now
    end

    {
      "staff_count" => staff_checked_in_count,
      "children_count" => children_checked_in_count
    }
  end

  def self.ratio_report_hash
    # result = {}
    #
    # return result unless self.any?
    #
    # keyed_entries = {}
    #
    # first_time = self.minimum(:time)
    # last_time = self.maximum(:time)
    #
    # self.order(:time).find_each do |time_entry|
    #   key = "#{time_entry.time_recordable_type}_#{time_entry.time_recordable_id}"
    #   keyed_entries[key] = [] if keyed_entries[key].nil?
    #   keyed_entries[key] << time_entry
    # end
    # ap "built hash"
    #
    # (first_time.to_i .. last_time.to_i).step(15.minutes).each do |time|
    #   result[Time.zone.at(time).stamp("3:00 PM")] = self.count_checked_in_at(Time.zone.at(time), keyed_entries)
    # end
    #
    # result

    RatioReporter.new(self).ratio_report
  end

  def self.to_ratio_csv
    CSV.generate do |csv|
      csv << ["Time", "Teachers", "Children"]
      self.ratio_report_hash.each do |time, data|
        csv << [time, data["staff_count"], data["children_count"]]
      end
    end
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << ["Date", "Time In", "Time Out"]
      self.all.reorder("time ASC").each do |entry|
        csv << [entry.time.stamp("March 3rd, 2019"), "#{entry.time.stamp("3:00 pm") if entry.checked_in?}", "#{entry.time.stamp("3:00 pm") if entry.checked_out?}"]
      end
    end
  end

  def checked_in?
    record_type.present? && record_type.entry?
  end

  def checked_out?
    record_type.blank? || record_type.exit?
  end

  def parent
    time_recordable
  end

  def recordable_name
    parent.full_name
  end
end
