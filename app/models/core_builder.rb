class CoreBuilder

  attr_accessor :user, :center
  def initialize(user, center)
    @user = user
    @center = center
  end

  def build
    user.create_parent(primary: true)
    parent = user.parent
    parent.create_core(center: center)
    parent.core.parents << parent
  end

end