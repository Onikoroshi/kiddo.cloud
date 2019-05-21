class Grades
  TKK_GRADES = ["TK", "K"]
  OTHER_GRADES = (1..6).to_a.map(&:to_s)
  GRADES = TKK_GRADES + OTHER_GRADES

  def collection
    GRADES
  end

  def tkk
    TKK_GRADES
  end

  def other_grades
    OTHER_GRADES
  end
end
