class StepFactory

  def self.find(core, step, params)
    class_name(step).new(core, step, params)
  end

  def self.class_name(step)
    "::#{step.to_s.capitalize!}StepBuilder".constantize
  end

end