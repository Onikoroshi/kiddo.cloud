class Center < ApplicationRecord
  has_many :accounts, dependent: :destroy
  has_many :users
  has_many :locations, dependent: :destroy

  has_many :programs

  accepts_nested_attributes_for :locations

  def children
    children = []
    self.accounts.includes(:children).all.each do |account|
      children << account.children
    end
    children.flatten
  end

  def default_location
    @location = self.locations.select { |l| l.default }.first || self.locations.first
  end

  def current_program
    programs.where(short_code: "dkk_fall_2017").first
  end
end
