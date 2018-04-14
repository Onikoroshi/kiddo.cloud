class Program < ApplicationRecord
  belongs_to :center
  has_many :plans
  has_many :enrollments, through: :plans
  has_many :children, through: :enrollments
  has_many :transactions, through: :enrollments
  has_many :drop_ins

  has_many :program_locations, dependent: :destroy
  has_many :locations, through: :program_locations

  money_column :registration_fee
  money_column :change_fee

  validates :name, :starts_at, :ends_at, :registration_opens, :registration_closes, :short_code, :registration_fee, :change_fee, presence: true

  scope :open_for_registration, -> { where("registration_opens <= ? AND registration_closes >= ?", Time.zone.today, Time.zone.today) }
  scope :in_session, -> { where("starts_at <= ? AND ends_at >= ?", Time.zone.today, Time.zone.today) }
  scope :active, -> { where("ends_at >= ?", Time.zone.today) }

  def plan_types
    plans.map{|plan| plan.plan_type}.uniq{|plan| plan.to_s}
  end

  def short_name
    name.gsub("Davis Kids Klub ", "")
  end

  def can_destroy?
    return false if plans.any?
    return false if enrollments.any?
    return false if transactions.any?
    return false if locations.any?

    true
  end
end
