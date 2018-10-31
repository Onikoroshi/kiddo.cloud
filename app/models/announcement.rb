class Announcement < ApplicationRecord
  belongs_to :program
  belongs_to :location

  classy_enum_attr :plan_type, enum: "PlanType", allow_blank: true

  def title
    title = [program.try(:name), location.try(:name), plan_type.try(:text)].reject(&:blank?).join(", ")
    title = "Everyone" if title.blank?
    title
  end
end
