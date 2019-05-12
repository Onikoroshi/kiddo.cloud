class Center < ApplicationRecord
  has_many :accounts, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :locations, dependent: :destroy

  has_many :program_groups, dependent: :destroy
  has_many :programs, dependent: :destroy

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
    programs.open_for_registration.first || programs.in_session.first || programs.last
  end
end
