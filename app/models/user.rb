class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :center

  has_one :parent, dependent: :destroy
  has_one :staff, dependent: :destroy

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles, dependent: :destroy

  has_many :user_permissions, dependent: :destroy
  has_many :permissions, through: :user_permissions, dependent: :destroy

  has_many :time_disputes, dependent: :destroy

  scope :staff, -> { joins(:staff) }

  def full_name
    "#{first_name} #{last_name}"
  end
end
