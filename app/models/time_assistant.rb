class TimeAssistant
  def initialize
    Time.zone = "Pacific Time (US & Canada)"
    Chronic.time_class = Time.zone
  end

  def time_to_check_lower_grades?
    return false if Time.now.on_weekend?
    Time.zone.now >= low_grade_check_time &&
      Time.zone.now <= low_grade_check_time + 45.minutes
  end

  def time_to_check_higher_grades?
    return false if Time.now.on_weekend?
    Time.zone.now >= high_grade_check_time &&
      Time.zone.now <= high_grade_check_time + 45.minutes
  end

  def low_grade_start_time
    Chronic.parse("today at 2:35pm")
  end

  def high_grade_start_time
    Chronic.parse("today at 3:05pm")
  end

  def low_grade_check_time
    low_grade_start_time + 15.minutes
  end

  def high_grade_check_time
    high_grade_start_time + 15.minutes
  end

  def low_grade_swipe_window
    (low_grade_start_time - 1.hour)..(low_grade_check_time)
  end

  def high_grade_swipe_window
    (high_grade_start_time - 1.hour)..(high_grade_check_time)
  end

  # def time_entry_in_range?(time_entry: time_entry, grade_level: "low")
  #   if grade_level == "low"
  #     high_grade_swipe_window.cover?(time_entry.time)
  #   else
  #     low_grade_swipe_window.cover?(time_entry.time)
  #   end
  # end

  def day_ends(target_date)
    Chronic.parse("#{target_date} at 4:00pm")
  end

  # if someone registers for an enrollment later than 8pm the previous day,
  # they're considered late and will be charged a late fee.
  def registration_cut_off(start_date)
    begin
      start_date = Chronic.parse(start_date.to_s).to_date
      target_date = start_date - 1.day
      Chronic.parse("#{target_date} at 3:00pm")
    rescue => e
      return nil
    end
  end
end
