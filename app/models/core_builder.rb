class CoreBuilder

  attr_accessor :user
  def initialize(user)
    @user = user
  end

  def build
    user.create_parent
    user.parent.create_core
  end

end