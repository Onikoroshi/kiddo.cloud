class StepFactory

  def self.find(core, step, params)
    class_name(step).new(core, step, params)
  end

  def self.class_name(step)
    prefix = step.to_s.capitalize
    "::#{prefix}StepBuilder".constantize
  end

end