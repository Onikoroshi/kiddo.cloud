class LateCheckinNotification < ApplicationRecord
  belongs_to :account
  belongs_to :child

  scope :sent_today, -> {
    where("sent_at >= ? AND sent_at < ?",
    Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
  }

  def already_sent_today?
    (Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).cover?(sent_at)
  end
end
