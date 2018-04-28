class PlanType < ClassyEnum::Base
  def self.recurring
    PlanType.select{|pt| pt.recurring?}
  end

  def recurring?
    false
  end
end

class PlanType::Contract < PlanType
  def text
    "School Year Contract"
  end

  def recurring?
    true
  end
end

class PlanType::SiblingClub < PlanType
  def recurring?
    true
  end
end

class PlanType::Weekly < PlanType
end

class PlanType::DropIn < PlanType
end
