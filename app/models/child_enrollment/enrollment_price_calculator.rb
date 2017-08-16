module ChildEnrollment
  class EnrollmentPriceCalculator

    attr_reader :children, :program
    def initialize(children, program)
      @children = children
      @program = program
    end

    def calculate
      total = Money.new("0.00")
      children.each do |child|
        # We'll want to scope this to the child's program at some point
        child.enrollments.each do |enrollment|
          total += enrollment.plan.price
        end
      end
      apply_discount(total)
    end

    def apply_discount(total)
      if Time.zone.now.month == 8
        discount = total * 0.20
        total = total - discount
      else
        total
      end
    end

  end
end
