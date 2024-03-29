module ChildEnrollment
  class DkkEnroller
    attr_reader :children, :plans, :location, :program
    def initialize(children, program, location)
      @children = children
      @plans = program.plans
      @location = location
    end

    def enroll
      unenroll

      children.each do |child|
        enroll_child(child)
        child.enrollments.alive.update_all(location_id: location.id)
      end

      SiblingClub.new(children, program, location).apply
    end

    def unenroll
      children.each do |c|
        plans.each do |p|
          c.plans.destroy(p)
        end
      end
    end

    def enroll_child(child)
      day_count = child.attendance_selection.day_count
      if day_count > 1
        enroll_direct_plan(child, day_count)
      else
        enroll_single_day_plan(child)
      end
    end

    protected

    def enroll_direct_plan(child, day_count)
      plan = plans.where(days_per_week: day_count).first
      child.plans << plan
    end

    def enroll_single_day_plan(child)
      short_code = child.attendance_selection.wednesday ? "week_1_wed" : "week_1"
      plan = plans.where(short_code: short_code).first
      child.plans << plan
    end
  end
end
