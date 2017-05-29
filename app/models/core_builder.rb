class CoreBuilder

  attr_accessor :user
  def initialize(user)
    @user = user
  end

  def build
    user.create_parent(primary: true)
    user.parent.create_core
  end

end