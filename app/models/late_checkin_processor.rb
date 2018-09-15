class LateCheckinProcessor
  attr_reader :time_assistant
  def initialize(time_assistant)
    @time_assistant = time_assistant
  end

  def process_low_grade_alerts
    process(Child.low_grade,
      time_assistant.low_grade_swipe_window)
  end

  def process_high_grade_alerts
    process(Child.high_grade,
     time_assistant.high_grade_swipe_window)
  end

  private

  def process(children, swipe_window)
    children_notified = []
    sent_notifications = false
    children.find_each do |c|
      enrollments = enrollments.alive.active.paid.select { |e| e.enrolled_today? && e.alerts_enabled? }
      if c.enrollments.any?
        if c.time_entries.all_in_range(Time.zone.today.beginning_of_day, Time.zone.today.end_of_day).none?
          if c.late_checkin_notifications.sent_today.none?
            children_notified << c

            TransactionalMailer.late_checkin_alert(c.account).deliver_now
            c.late_checkin_notifications.create(
              account: c.account,
              sent_at: Time.zone.now,
              sent_to_email: c.account.primary_email,
            )
            sent_notifications = true
          end
        end
      end
    end

    TransactionalMailer.late_notification_report(children_notified) if children_notified.any?
    
    sent_notifications
  end
end
