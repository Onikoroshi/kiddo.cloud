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

  before_add_for_locations << ->(method, owner, change) { owner.send(:on_add_location, change) }
  before_remove_for_locations << ->(method, owner, change) { owner.send(:on_remove_location, change) }

  after_initialize :initialize_location_changes

  validates :name, :starts_at, :ends_at, :registration_opens, :registration_closes, :registration_fee, :change_fee, presence: true

  validate :validate_changed_location_free

  after_save :sync_enrollments

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

  def locations_changed?
    @location_changes[:removed].present? or @location_changes[:added].present?
  end

  private

  def on_add_location(location)
    initialize_location_changes_safe
    @location_changes[:added] << location.id
  end

  def on_remove_location(location)
    initialize_location_changes_safe
    @location_changes[:removed] << location.id
  end

  def initialize_location_changes
    @location_changes = {added: [], removed: []}
  end

  def initialize_location_changes_safe
    @location_changes = {added: [], removed: []} if @location_changes.nil?
  end

  def validate_changed_location_free
    return unless self.locations_changed?

    unless @location_changes[:added].nil?
    end

    unless @location_changes[:removed].nil?
      @location_changes[:removed].each do |location_id|
        location = Location.find_by(id: location_id)
        next unless location.present?

        errors.add(:base, "#{location.name} already has people attending and cannot be removed.") if Enrollment.active.by_program_and_location(self, location).any?
      end
    end
  end

  def sync_enrollments
    if starts_at_changed? || ends_at_changed? || earliest_payment_offset_changed? || latest_payment_offset_changed?
      enrollments.recurring.find_each do |enrollment|
        if starts_at_changed?
          enrollment.update_attribute(:starts_at, [self.starts_at, enrollment.created_at.to_date].max)
        end

        if ends_at_changed?
          enrollment.update_attribute(:ends_at, [self.starts_at, Time.zone.today].max)
        end

        if earliest_payment_offset_changed? && enrollment.child.account.payment_offset < earliest_payment_offset
          enrollment.child.account.update_attribute(:payment_offset, self.earliest_payment_offset)
        end

        if latest_payment_offset_changed? && enrollment.child.account.payment_offset > latest_payment_offset
          enrollment.child.account.update_attribute(:payment_offset, self.latest_payment_offset)
        end

        enrollment.set_next_target_and_payment_date!
      end
    end
  end
end
