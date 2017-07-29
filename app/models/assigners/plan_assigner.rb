module Assigners
  class PlanAssigner

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
    end



  end
end
