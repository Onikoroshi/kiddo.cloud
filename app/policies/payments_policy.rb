class PaymentsPolicy < Struct.new(:user, :payments)
  def manage?
    user.super_admin?
  end
end
