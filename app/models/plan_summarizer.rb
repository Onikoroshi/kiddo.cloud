class PlanSummarizer

  attr_reader :account
  def initialize(account)
    @account = account
  end

  def summarize
    if account.drop_ins.any?
      summarize_dropins
    else
      summarize_enrollments
    end
  end

  def summarize_dropins
    string = ""
    account.drop_ins.each_with_index do |d, index|
      string += d.to_s
      string += "<br/>"
    end
    string
  end

  def summarize_enrollments
    string = ""
    account.summarize_enrollments(account.center.current_program).each_with_index do |item, index|
      string += item.to_s
      string += "<br/>"
    end
    string
  end

  def total

  end

end
