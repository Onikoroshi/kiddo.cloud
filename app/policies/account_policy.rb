class AccountPolicy
  attr_reader :user, :account
  def initialize(user, account)
    @user = user
    @account = account
  end

  def authorized_staff?
    user.role?("super_admin", "director", "staff")
  end

  def index?
    authorized_staff?
  end

  def register?
    user_owns_account?
  end

  def dashboard?
    authorized_staff? || user_owns_account?
  end

  def show?
    dashboard?
  end

  private

  def user_owns_account?
    user.present? &&
    account.present? &&
    user.account.present? &&
    user.account.id == account.id
  end
end
