module ChildEnrollment
  class EnrollmentPriceCalculator
    attr_reader :children, :program, :account
    def initialize(account)
      @account = account
      @children = account.children
      @program = account.center.current_program
    end

    def calculate
      total = Money.new("0.00")
      children.each do |child|
        # We'll want to scope this to the child's program at some point
        child.enrollments.each do |enrollment|
          total += enrollment.plan.price
        end
      end
      total += first_time_user_fee
      total -= discount(total)
      total
    end

    # 80% off for August, 20% off for June
    def discount(total)
      if Time.zone.now.month == 8
        total * 0.80
      elsif Time.zone.now.month == 6
        total * 0.20
      else
        Money.new("0.00")
      end
    end

    def first_time_user_fee
      if !account.user.legacy?
        Money.new("80.00")
      else
        Money.new("0.00")
      end
    end
  end
end
