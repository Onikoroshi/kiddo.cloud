class StepFactory

  def self.find(account, step, params)
    class_name(step).new(account, step, params)
  end

  def self.class_name(step)
    prefix = step.to_s.capitalize
    "::#{prefix}StepBuilder".constantize
  end

end