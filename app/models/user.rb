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

  scope :by_role, ->(role_name) { joins(:roles).where("roles.name = ?", role_name) }
  scope :staff, -> { joins(:staff) }
  scope :parent_users, -> { by_role("parent") }

  def full_name
    "#{first_name} #{last_name}"
  end

  # Returns true if the user has *any* of the roles
  def role?(*r)
    roles.find_by(name: r.map(&:to_s)).present? # Use db query instead of array filtering
  end

  # Returns true if the user has *any* of the permissions
  def permission?(*p)
    p = p.flatten if p.present?
    permissions.find_by(name: p).present? # Use db query instead of array filtering
  end

  def super_admin?
    role?(:super_admin)
  end

  def director?
    role?(:director)
  end

  def staff?
    role?(:staff)
  end

  def parent?
    role?(:parent)
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

  def manageable_locations
    if super_admin?
      Location.all
    elsif director? && staff.present?
      staff.locations
    else
      Location.none
    end
  end

  def email_required?
    # database query doesn't work here when creating new object
    if self.roles.map(&:name).include?("staff")
      false
    else
      super
    end
  end

  def password_required?
    # database query doesn't work here when creating new object
    if self.roles.map(&:name).include?("staff")
      false
    else
      super
    end
  end
end
