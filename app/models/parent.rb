class Parent < ApplicationRecord
  belongs_to :account
  belongs_to :user
  has_and_belongs_to_many :children
  has_one :address, as: :addressable

  after_commit :update_account_search_field

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def update_account_search_field
    return unless account.present?

    if saved_change_to_email? || saved_change_to_first_name? || saved_change_to_last_name?
      account.update_search_field
    end
  end
end
