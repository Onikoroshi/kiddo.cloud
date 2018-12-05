class EnrollmentTransaction < ApplicationRecord
  belongs_to :enrollment
  belongs_to :my_transaction, class_name: "Transaction"

  money_column :amount

  scope :chronological, -> { order("enrollment_transactions.created_at ASC") }
  scope :reverse_chronological, -> { order("enrollment_transactions.created_at DESC") }
  scope :by_target_date, -> { order("enrollment_transactions.target_date ASC") }
  scope :paid, -> { joins(:my_transaction).where("transactions.paid IS TRUE") }

  # used to populate receipts where people signed up before the first payment date
  scope :placeholders, -> { joins(:enrollment).where("DATE(enrollment_transactions.description_data -> 'stop_date') <= enrollments.starts_at") }

  def placeholder?
    if description_data["stop_date"].present? && enrollment.present? && enrollment.starts_at.present?
      begin
        target_stop = description_data["stop_date"].to_date
        return target_stop < enrollment.starts_at
      rescue => e
        return false
      end
    else
      return false
    end
  end

  def description
    description_data.present? && description_data["description"].present? ? description_data["description"] : enrollment.to_short
  end

  def service_dates
    if description_data.present? && description_data["start_date"].present? && description_data["stop_date"].present?
      start_date = description_data["start_date"].to_date
      stop_date = description_data["stop_date"].to_date
    else
      start_date, stop_date = enrollment.deduce_current_service_dates
    end

    if start_date == stop_date
      start_date.stamp("Mar. 3rd, 2018")
    else
      "#{start_date.stamp("Mar. 3rd, 2018")} to #{stop_date.stamp("Mar. 3rd, 2018")}"
    end
  end
end
