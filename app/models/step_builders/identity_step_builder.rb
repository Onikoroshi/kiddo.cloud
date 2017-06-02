class IdentityStepBuilder

  attr_accessor :core, :step, :params
  def initialize(core, step, params)
    @core = core
    @step = step
    @params = params
  end

  def build
    add_children(params.slice(:children))
    add_parents(params.slice(:parents))
    add_contacts
  end

  def add_children(params)
    primary_parent = core.primary_parent
    params["children"].each do |k,v|
      primary_parent.children << build_child(v)
    end
  end

  def build_child(params)
    Child.new(
      first_name: v["first_name"],
      last_name:  v["last_name"],
      grade_entering:  v["grade_entering"],
      birthdate: v["grade_entering"],
      gender: v["gender"]
    )
  end

  def add_parents(params)
    params.each do |k,v|
      byebug
      core.parents.build(v)
    end
  end

  def add_contacts

  end

  def save_all
    core.save
  end

end