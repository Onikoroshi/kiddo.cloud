class IdentityStepBuilder

  attr_accessor :core, :step, :params, :primary_parent
  def initialize(core, step, params)
    @core = core
    @step = step
    @params = params
    @primary_parent = @core.primary_parent
  end

  def build
    add_children(params.slice(:children))
    add_parents(params.slice(:parents))
    add_contacts
    core.last_registration_step_completed = step
    core
  end

  def add_children(params)
    params["children"].each do |k,v|
      core.primary_parent.children << build_child(v)
    end
  end

  def build_child(params)
    Child.new(
      first_name: params["first_name"],
      last_name:  params["last_name"],
      grade_entering:  params["grade_entering"],
      birthdate: params["birthdate"],
      gender: params["gender"]
    )
  end

  def add_parents(params)
    params["parents"].each do |k,v|
      update_primary_parent(v) if k.to_i == 0
    end
  end

  def update_primary_parent(params)
    primary_parent.build_user unless primary_parent.user.present?
    primary_parent.user.assign_attributes(
      first_name: params["first_name"],
      last_name: params["last_name"]
    )
    primary_parent.build_address unless primary_parent.address.present?
    primary_parent.address.assign_attributes(
      street: params["street"],
      extended: params["extended"],
      locality: params["locality"],
      region: params["region"],
      postal_code: params["postal_code"]
    )
    byebug
    puts "hi"
  end

  def add_contacts

  end

  def add_address(params)

  end

end