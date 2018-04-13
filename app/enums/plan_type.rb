class PlanType < ClassyEnum::Base
end

class PlanType::Contract < PlanType
end

class PlanType::Weekly < PlanType
end

class PlanType::DropIn < PlanType
end
