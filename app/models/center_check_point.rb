class CenterCheckPoint

  attr_reader :center, :user
  def initialize(center:, user:)
    @center = center
    @user = user
  end

  def passes?
    center.present? &&
    user.present? &&
    user.center_id == center.id
  end

end

