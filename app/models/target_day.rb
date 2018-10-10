class TargetDay < ApplicationRecord
  belongs_to :plan

  scope :by_program_and_plan_type, ->(program, plan_type) { joins(:plan).where("plans.program_id = ? AND plans.plan_type = ?", program.id, plan_type.to_s) }

  def self.select_options
    all.map{|target| [target.target_date.stamp("Tuesday, January 8th, 2018"), target.target_date.stamp("2018/03/08")]}
  end
end
