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

    ap partial_core
    ap partial_core.primary_parent
    ap partial_core.primary_parent.address
    ap partial_core.primary_parent.user
    ap partial_core.primary_parent.children

    if partial_core.save!
      true
    else
      byebug
      self.errors.add(:user, "messed up.")
      false
    end
  end

end

