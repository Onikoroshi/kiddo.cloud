class Enrollment < ApplicationRecord
  belongs_to :location
  belongs_to :child
  belongs_to :plan

  after_create :copy_attendance_selections

  def to_s
    "#{child.full_name} is enrolled in the #{plan.display_name} plan on #{enrolled_days(humanize: true)} at #{child.account.location.name}."
  end

  def enrolled_days(humanize = false)
    day_hash = {
      monday: monday,
      tuesday: tuesday,
      wednesday: wednesday,
      thursday: thursday,
      friday: friday,
      saturday: saturday,
      sunday: sunday
    }

    selected = Array.new
    day_hash.each do |k,v|
      selected << k if v
    end

    if humanize
      value = selected.to_sentence.titleize
    else
      selected
    end
  end

  def enrolled_today?
    dictionary = {
      1 => "monday",
      2 => "tuesday",
      3 => "wednesday",
      4 => "thursday",
      5 => "friday",
      6 => "saturday",
      7 => "sunday",
    }

    today = Time.zone.now.wday
    send(dictionary[today])
  end

  def copy_attendance_selections
    as = child.attendance_selection
    update_attributes(
      monday: as.monday,
      tuesday: as.tuesday,
      wednesday: as.wednesday,
      thursday: as.thursday,
      friday: as.friday
    )
  end
end
