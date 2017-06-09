class AccountForm
  include ActiveModel::Model

  attr_reader :account, :step, :child_attributes, :parent_attributes
  def initialize(account, step)
    @account = account
    @step = step
  end

  def user
    account.parent.user
  end

  def parent
    account.parent.primary
  end

  def update(params)
    partial_account = StepFactory.find(account, step, params).build

    ap partial_account
    ap partial_account.primary_parent
    ap partial_account.primary_parent.address
    ap partial_account.primary_parent.user
    ap partial_account.primary_parent.children

    if partial_account.save!
      true
    else
      self.errors.add(:user, "messed up.")
      false
    end
  end

end

