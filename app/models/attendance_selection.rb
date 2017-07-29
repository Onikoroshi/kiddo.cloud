class AttendanceSelection < ApplicationRecord
  belongs_to :child

  validate :validate_day_selected, on: :update

  def day_selected?
    monday || tuesday || wednesday || thursday || friday
  end

  def validate_day_selected
    errors.add(:day_selected, "can't be blank") unless day_selected?
  end

  def empty?
    !monday && !tuesday && !wednesday && !thursday && !friday
  end

  def reset!
    self.assign_attributes(
      monday: false,
      tuesday: false,
      wednesday: false,
      thursday: false,
      friday: false,
      saturday: false,
      sunday: false
    )
    self.save(validate: false)
  end

  def day_count
    count = 0
    [
      monday,
      tuesday,
      wednesday,
      thursday,
      friday,
      saturday,
      sunday,
    ].map { |day|
      count += 1 if day
    }
    count
  end

end
