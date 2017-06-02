class CoreForm
  include ActiveModel::Model

  attr_reader :core, :step, :child_attributes, :parent_attributes
  def initialize(core, step)
    @core = core
    @step = step
  end

  def user
    core.parent.user
  end

  def parent
    core.parent.primary
  end

  def update(params)
    partial_core = StepFactory.find(core, step, params).build

    if partial_core.save_all
      byebug
    else
      self.errors.add(:user, "messed up.")
    end
  end

end

