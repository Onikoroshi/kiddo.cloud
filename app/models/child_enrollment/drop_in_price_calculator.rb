module ChildEnrollment
  class DropInPriceCalculator

    attr_reader :children, :program
    def initialize(children, program)
      @children = children
      @program = program
    end

    def calculate
      assign_prices
      base_price
    end

    def assign_prices
      children.each do |child|
        child.drop_ins.each do |drop_in|
          drop_in.update_attributes(price: price_for_plan(drop_in))
        end
      end
    end

    def price_for_plan(drop_in)
      plan_type_code = drop_in.wednesday? ? "drop_1_wed" : "drop_1"
      program.plans.where(short_code: plan_type_code).first.price
    end

    def base_price
      total = Money.new("0.00")
      children.each do |child|
        child.drop_ins.upcoming.not_paid.each do |drop_in|
          total += drop_in.price if drop_in.price.present?
        end
      end
      total
    end

  end
end
