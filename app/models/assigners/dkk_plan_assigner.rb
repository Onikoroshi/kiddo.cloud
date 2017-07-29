module Assigners
  class DkkPlanAssigner

    attr_reader :children, :plans
    def initialize(children, program)
      @children = children
      @plans = program.plans
    end

    def assign
      children.each do |child|
        assign_child(child)
      end
    end

    def assign_child(child)
      day_count = child.selection.day_count
      if day_count > 1
        assign_direct_plan(child, day_count)
      else
        assign_single_day_plan(child)
      end
    end

    protected

    def assign_direct_plan(child, day_count)
      plan = plans.where(days_per_week: day_count).first
      child.plans << plan
    end

    def assign_single_day_plan(child)
      short_code = child.selection.wednesday ? "week_1_wed" : "week_1"
      plan = plans.where(short_code: short_code).first
      child.plans << plan
    end

    private

    # Sibling Club is designed for students 1-3 grade waiting for siblings 4-6 grade
    def qualifies_for_sibling_club?(child)
      grade = child.last.grade_entering
    end

  end
end
