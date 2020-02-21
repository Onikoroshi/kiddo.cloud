class PlanType < ClassyEnum::Base
  def self.recurring
    PlanType.select{|pt| pt.recurring?}
  end

  def self.one_time
    PlanType.select{|pt| pt.one_time?}
  end

  def self.single_day
    PlanType.select{|pt| pt.single_day?}
  end

  def find_available_days(program = nil)
    plans = (program.present? ? program.plans : Plan).where(plan_type: self.to_s)

    days = {
      monday: false,
      tuesday: false,
      wednesday: false,
      thursday: false,
      friday: false,
      saturday: false,
      sunday: false
    }

    plans.find_each do |plan|
      plan.allowed_days.each do |plan_day|
        days[plan_day.to_sym] = true
      end
    end

    days
  end

  def recurring?
    false
  end

  def one_time?
    !recurring?
  end

  def single_day?
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

class PlanType::FullDayContract < PlanType
  def text
    "TK/K Day Options"
  end

  def recurring?
    true
  end
end

class PlanType::Weekly < PlanType
end

class PlanType::DropIn < PlanType
  def single_day?
    true
  end
end

class PlanType::CampDay < PlanType
  def single_day?
    true
  end
end
