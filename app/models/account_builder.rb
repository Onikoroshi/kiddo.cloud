class AccountBuilder

  attr_accessor :user, :center
  def initialize(user, center)
    @user = user
    @center = center
  end

  def build
    user.create_parent(primary: true)
    parent = user.parent
    parent.create_account(center: center, user: user)
    parent.account.parents << parent
    user.roles << Role.find_by(name: "parent")
  end

end