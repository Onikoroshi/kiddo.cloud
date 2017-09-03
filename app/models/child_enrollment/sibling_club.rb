module ChildEnrollment
  class SiblingClub
    attr_reader :children, :program, :location, :older_children, :younger_children
    def initialize(children, program, location)
      @children = children
      @program = program
      @location = location
      @older_children = children.high_grade
      @younger_children = children.low_grade
    end

    # Sibling Club is designed for students 1-3 grade waiting for siblings 4-6 grade
    # any day but wednesday
    def apply
      return if enrollment_day("wednesday")

      unapply
      if enrollments_same_day? && older_children.any?
        younger_children.each do |yc|
          yc.enrollments.last.update_attributes(sibling_club: true)
        end
      end
    end

    def unapply
      younger_children.each do |yc|
        yc.enrollments.last.update_attributes(sibling_club: false)
      end
    end

    def enrollments
      children.collect { |c| c.enrollments }.flatten
    end

    def enrollments_same_day?
      enrollments.all? { |e| e.monday } ||
        enrollments.all? { |e| e.tuesday } ||
        enrollments.all? { |e| e.wednesday } ||
        enrollments.all? {|e| e.thursday } ||
        enrollments.all? { |e| e.friday } ||
        enrollments.all? { |e| e.saturday } ||
        enrollments.all? { |e| e.sunday }
    end

    def enrollment_day(day)
      enrollments.all? { |e| e.send(day) }
    end
  end
end
