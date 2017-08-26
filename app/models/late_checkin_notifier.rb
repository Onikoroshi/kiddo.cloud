class LateCheckinNotifier
  def execute
    assistant = TimeAssistant.new
    if assistant.time_to_check_lower_grades?
      processor = LateCheckinProcessor.new(assistant)
      processor.process_low_grade_alerts
    end

    if assistant.time_to_check_higher_grades?
      processor = LateCheckinProcessor.new(assistant)
      processor.process_high_grade_alerts
    end
  end
end
