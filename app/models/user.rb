class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :account # a child or parent
  has_one :company, class_name: "Account", dependent: :destroy # if i have an account, i'm the owner

  has_one :parent, dependent: :destroy
  has_one :staff, dependent: :destroy

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles, dependent: :destroy

  has_many :user_permissions, dependent: :destroy
  has_many :permissions, through: :user_permissions, dependent: :destroy



  after_initialize :set_account

  def set_account
    build_account unless account.present?
  end
end
