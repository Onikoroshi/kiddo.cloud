require "rails_helper"

RSpec.describe LateCheckinProcessor, type: :model do
  let(:time_assistant) { TimeAssistant.new }

  describe ".process_low_grade_alerts" do
    context "when processing children without time entries in swipe window range" do
      let!(:not_checked_in_child) do
        create(:child,
          account: build(:account, user: build(:user)))
      end

      it "sends an email" do
        set_checkin_window
        expect(not_checked_in_child.late_checkin_notifications.sent_today.size).to eq 0
        result = LateCheckinProcessor.new(time_assistant).process_low_grade_alerts
        expect(result).to be true
        expect(not_checked_in_child.late_checkin_notifications.sent_today.size).to eq 1
        expect(
          not_checked_in_child
          .late_checkin_notifications
          .sent_today
          .first
          .sent_to_email,
        ).to eq not_checked_in_child.account.primary_email
      end
    end

    context "when processing children with time entries in swipe window range" do
      let!(:checked_in_child) do
        create(:child, :with_time_entry,
          account: build(:account, user: build(:user)))
      end

      it "doesn't send an email" do
        set_checkin_window
        expect(checked_in_child.late_checkin_notifications.sent_today.size).to eq 0
        result = LateCheckinProcessor.new(time_assistant).process_low_grade_alerts
        expect(result).to be false
        expect(checked_in_child.late_checkin_notifications.sent_today.size).to eq 0
      end
    end
  end

  def set_checkin_window
    window = Time.zone.now - 1.hour..Time.zone.now + 1.hour
    allow_any_instance_of(TimeAssistant).to receive(:low_grade_swipe_window).and_return(window)
  end
end
