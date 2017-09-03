class AccountPolicy
  attr_reader :user, :account
  def initialize(user, account)
    @user = user
    @account = account
  end

  def register?
    user_owns_account?
  end

  def dashboard?
    user_owns_account?
  end

  private

  def user_owns_account?
    user.present? &&
    account.present? &&
    user.account.id == account.id
  end

end
