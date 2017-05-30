class Core < ApplicationRecord
  belongs_to :center
  has_many :parents
  has_many :children
  has_many :emergency_contacts, dependent: :destroy

  cattr_accessor :form_steps do
    %w(identity instructions medical signature)
  end

  attr_accessor :form_step

  def primary_parent
    parents.where(primary: true).first
  end

end
