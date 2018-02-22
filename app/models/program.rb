class Program < ApplicationRecord
  belongs_to :center
  has_many :plans
  has_many :enrollments, through: :plans
  has_many :children, through: :enrollments
  has_many :drop_ins
  has_many :transactions

  has_many :program_locations
  has_many :locations, through: :program_locations

  money_column :registration_fee

  scope :open_for_registration, -> { where("registration_opens <= ? AND registration_closes >= ?", Time.zone.today, Time.zone.today) }
  scope :in_session, -> { where("starts_at <= ? AND ends_at >= ?", Time.zone.today, Time.zone.today) }

  def plan_types
    plans.map{|plan| plan.plan_type}.uniq{|plan| plan.to_s}
  end
end
