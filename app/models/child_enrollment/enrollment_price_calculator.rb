module ChildEnrollment
  class EnrollmentPriceCalculator
    attr_reader :children, :program, :account, :itemizations
    def initialize(account)
      @account = account
      @children = account.children
      @program = account.center.current_program
      @itemizations = Hash.new
    end

    def calculate
      total = Money.new("0.00")
      children.each_with_index do |child|
        # We'll want to scope this to the child's program at some point
        child.enrollments.each_with_index do |enrollment, index|
          if enrollment.sibling_club?
            puts "sibling club"
            total += Money.new("40.00")
            key = "sibling_club_#{child.id}_#{index}".to_sym
            itemizations[key] = 40.00
          else
            puts "enrollment"
            total += enrollment.plan.price
            key = "#{enrollment.plan.short_code}_#{child.id}_#{index}".to_sym
            itemizations[key] = enrollment.plan.price.to_f
          end
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
        itemizations[:august_discount] = total * 0.80
      elsif Time.zone.now.month == 6
        total * 0.20
        itemizations[:august_discount] = total * 0.20
      else
        Money.new("0.00")
      end
    end

    def first_time_user_fee
      if !account.user.legacy?
        Money.new("80.00")
        itemizations[:first_time_user_fee] = 80.00
      else
        Money.new("0.00")
      end
    end

    def itemize
      itemizations
    end
  end
end
