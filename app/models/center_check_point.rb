class CenterCheckPoint
  attr_reader :center, :user
  def initialize(center:, user:)
    @center = center
    @user = user
  end

  def passes?
    #byebug if center.nil? || user.nil? || user.center_id != center.id

    center.present? ||
      user.blank? ||
      user.center_id == center.id
  end
end
