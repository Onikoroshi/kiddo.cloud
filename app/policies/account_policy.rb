class AccountPolicy

  attr_reader :user, :account
  def initialize(user, account)
    @user = user
    @account = account
  end

  def register?
    user.present? && account.present? && user_owns_account?
  end

  private

  def user_owns_account?
    user.account.id == account.id
  end

end