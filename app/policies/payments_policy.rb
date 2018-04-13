class PaymentsPolicy < Struct.new(:user, :payments)
  def manage?
    user.role?(:super_admin)
  end
end
