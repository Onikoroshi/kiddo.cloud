class FinanceItemPresenter
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  def initialize(account)
    @account = account
    unpaid_enrollments = account.enrollments.unpaid
    if unpaid_enrollments.any?
      @is_transaction = false
      @finance_item = ChildEnrollment::EnrollmentPriceCalculator.new(account)
      @finance_item.calculate
    elsif account.transactions.any?
      @is_transaction = true
      if account.transactions.unpaid.any?
        @finance_item = account.transactions.unpaid.chronological.first
      else
        @finance_item = account.transactions.paid.reverse_chronological.first
      end
    else
      @is_transaction = false
      @finance_item = nil
    end
  end

  def blank?
    @finance_item.blank?
  end

  def amount
    if @is_transaction
      @finance_item.amount.to_s
    else
      @finance_item.total.to_s
    end
  end

  def status
    if @is_transaction
      @finance_item.paid? ? "Paid" : "Unpaid"
    else
      "Unpaid"
    end
  end

  def transaction_type
    if @is_transaction
      @finance_item.transaction_type.text
    else
      "One Time"
    end
  end

  def date
    if @is_transaction
      @finance_item.created_at.to_date.stamp("04/02/2019")
    else
      @finance_item.enrollments.minimum(:created_at).to_date.stamp("04/02/2019")
    end
  end

  def details_link
    if @is_transaction
      link_to "Details", account_dashboard_payment_path(@account, @finance_item)
    else
      link_to "Details", new_account_dashboard_payment_path(@account)
    end
  end
end
