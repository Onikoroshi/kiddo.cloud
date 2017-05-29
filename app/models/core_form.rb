class CoreForm
  include ActiveModel::Model

  attr_accessor :core
  def initialize(core)
    @core = core
  end

  def parse_attributes(params)

  end

  def update(params)

  end

end