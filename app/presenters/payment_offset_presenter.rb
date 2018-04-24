class PaymentOffsetPresenter
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  def self.build(start_num, stop_num)
    offsets = []

    (start_num..stop_num).each do |num|
      offsets << PaymentOffsetPresenter.new(num)
    end

    offsets
  end

  def initialize(num)
    @number = num.to_i
  end

  def to_i
    @number
  end

  def to_s
    if @number < 0
      "#{pluralize(@number.abs, "Day")} before the end of the previous month"
    else
      "#{(@number + 1).ordinalize} of the month"
    end
  end
end
