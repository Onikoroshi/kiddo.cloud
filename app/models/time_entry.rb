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

  def self.count_checked_in_at(datetime)
    hash = {}
    self.all.each do |entry|
      key = "#{entry.time_recordable_type}_#{entry.time_recordable_id}"
      hash[key] = [] if hash[key].nil?
      hash[key] << entry
    end

    checked_in_count = 0
    hash.each do |key, entries|
      entries_before = entries.select{|e| e.time <= datetime}
      entries_after = entries.select{|e| e.time > datetime}

      last_before = entries_before.sort{|a, b| a.time <=> b.time}.last
      first_after = entries_after.sort{|a, b| a.time <=> b.time}.first

      checked_in_count += 1 if last_before.present? && last_before.checked_in? && (first_after.blank? || first_after.checked_out?)
    end

    checked_in_count
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
