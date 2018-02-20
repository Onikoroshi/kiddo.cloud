class AccountBuilder

  attr_accessor :user, :center, :program
  def initialize(user, center, program = nil)
    @user = user
    @center = center
    @program = program
  end

  def build
    user.create_parent(primary: true)
    parent = user.parent
    parent.create_account(center: center, user: user)
    parent.account.parents << parent
    parent.account.update_attribute(:program, program) if program.present?
    user.roles << Role.find_by(name: "parent")
  end

end
