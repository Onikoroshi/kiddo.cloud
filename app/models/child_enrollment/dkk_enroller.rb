module ChildEnrollment
  class DkkEnroller

    attr_reader :children, :plans
    def initialize(children, program)
      @children = children
      @plans = program.plans
    end

    def enroll
      unenroll

      children.each do |child|
        enroll_child(child)
      end

      if account_qualifies_for_sibling_club?
        adjust_enrollments_for_sibling_club
      end
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

    def enroll_in_sibling_club(child)
      child.plans.clear
      child.plans << plans.where(short_code: "sibling_club").first
    end

    def adjust_enrollments_for_sibling_club
      high_grade_siblings.each do |high_grade_sibling|
        if high_grade_sibling.plans.first == "week_1"
          low_grade_siblings.map { |c| enroll_in_sibling_club(c) }
        end
      end
    end

    def high_grade_siblings
      children.select { |c| c.grade_entering > 3 }
    end

    def low_grade_siblings
      children.select { |c| c.grade_entering <= 3 }
    end

    private

    # low_grade_siblings.map { |c| enroll_in_sibling_club(c) }

    # Sibling Club is designed for students 1-3 grade waiting for siblings 4-6 grade
    # any day but wednesday
    def account_qualifies_for_sibling_club?
      return false unless children.size > 1
      #return false if not wednesday

      high_grade_siblings.any? && low_grade_siblings.any?
    end

  end
end
