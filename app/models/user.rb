class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :account, dependent: :destroy
  belongs_to :center

  has_one :parent, dependent: :destroy
  has_one :staff, dependent: :destroy

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles, dependent: :destroy

  has_many :user_permissions, dependent: :destroy
  has_many :permissions, through: :user_permissions, dependent: :destroy

  has_many :time_disputes

  scope :staff, -> { joins(:staff) }

  def full_name
    "#{first_name} #{last_name}"
  end

  # Returns true if the user has *any* of the roles
  def role?(*r)
    roles.find_by(name: r).present? # Use db query instead of array filtering
  end

  # Returns true if the user has *any* of the permissions
  def permission?(*p)
    p = p.flatten if p.present?
    permissions.find_by(name: p).present? # Use db query instead of array filtering
  end

  def director?
    role?(:director)
  end

  def legacy?
    legacy
  end

  def legacy_dropin_chargeable?
    false
  end

  def legacy_enrollment_chargeable?
    false
  end
end
