class PlanType < ClassyEnum::Base
  def self.recurring
    PlanType.select{|pt| pt.recurring?}
  end

  def self.one_time
    PlanType.select{|pt| pt.one_time?}
  end

  def recurring?
    false
  end

  def one_time?
    !recurring?
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
