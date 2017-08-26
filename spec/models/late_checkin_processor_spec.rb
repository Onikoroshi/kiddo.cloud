require "rails_helper"

RSpec.describe LateCheckinProcessor, type: :model do
  let(:time_assistant) { TimeAssistant.new }

  describe ".process_low_grade_alerts" do
    context "when processing children without time entries in swipe window range" do
      let!(:not_checked_in_child) { create(:child) }
      it "sends an email" do
        set_checkin_window
        result = LateCheckinProcessor.new(time_assistant).process_low_grade_alerts
        expect(result).to be true
      end
    end

    context "when processing children with time entries in swipe window range" do
      let!(:checked_in_child) { create(:child, :with_time_entry) }
      it "doesn't send an email" do
        set_checkin_window
        result = LateCheckinProcessor.new(time_assistant).process_low_grade_alerts
        expect(result).to be false
      end
    end
  end

  def set_checkin_window
    window = Time.zone.now - 1.hour..Time.zone.now + 1.hour
    allow_any_instance_of(TimeAssistant).to receive(:low_grade_swipe_window).and_return(window)
  end
end
