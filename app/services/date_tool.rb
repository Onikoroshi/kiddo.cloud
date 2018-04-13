class DateTool
  def self.display_week(start_date, stop_date)
    "#{start_date.stamp("Mar. 3rd")} - #{start_date.month == stop_date.month ? stop_date.stamp("3rd") : stop_date.stamp("Mar. 3rd")}, #{start_date.stamp("2018")}"
  end
end
