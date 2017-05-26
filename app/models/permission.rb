class Permission < ActiveRecord::Base
  has_many :user_permissions
  has_many :users, through: :user_permissions

  validates_presence_of :name
  validates_uniqueness_of :name
end
