class Account < ApplicationRecord
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  has_many :users, dependent: :destroy
end


