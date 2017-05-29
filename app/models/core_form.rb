class CoreForm
  include ActiveModel::Model

  attr_accessor :core
  def initialize(core)
    @core = core
  end

  def user
    core.parent.user
  end

  def parent
    core.parent.primary
  end

  def parse_attributes(params)
    child_attributes = params.slice(:children)
    byebug
  end

  def update(params)
    parse_attributes(params)
  end

end