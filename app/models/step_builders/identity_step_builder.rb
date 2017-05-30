class IdentityStepBuilder

  attr_accessor :core, :step, :params
  def initialize(core, step, params)
    @core = core
    @step = step
    @params = params
  end

  def build
    add_children(params.slice(:children))
    add_parents(params)
    add_contacts
  end

  def add_children(params)
    params.each do |k,v|
      core.primary_parent.children.build(v["0"])
      byebug
      # build child
      # add to core
    end
  end

  def add_parents

  end

  def add_contacts

  end

end