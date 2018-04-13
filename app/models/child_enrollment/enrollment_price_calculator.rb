module ChildEnrollment
  class EnrollmentPriceCalculator
    attr_reader :account, :enrollments, :enrollment_changes, :itemizations, :total

    def initialize(account)
      @account = account
      @enrollments = account.enrollments.alive.unpaid
      @enrollment_changes = account.enrollment_changes.pending
      @itemizations = Hash.new
    end

    def independent_enrollment_changes
      considered_enrollment_ids = enrollments.pluck(:id)
      enrollment_changes.where.not(enrollment_id: considered_enrollment_ids)
    end

    def calculate
      total = enrollments.inject(Money.new(0)){ |sum, enrollment| sum + Money.new(enrollment.plan.price) }
      total += enrollment_changes.charge_total

      total += first_time_user_fee
      total += change_fee
      total -= discount(total)
      @total = total
    end

    def refund_total
      @refund_total ||= enrollment_changes.refund_total
    end

    # 80% off for August, 20% off for June
    def discount(total)
      # if Time.zone.now.month == 8
      #   total * 0.80
      #   itemizations[:august_discount] = total * 0.80
      # elsif Time.zone.now.month == 6
      #   total * 0.20
      #   itemizations[:august_discount] = total * 0.20
      # else
      #   Money.new("0.00")
      # end
      Money.new("0.00")
    end

    def first_time_user_fee
      unpaid_program_ids = account.enrollments.alive.unpaid.programs.pluck(:id)
      paid_program_ids = account.enrollments.alive.paid.programs.pluck(:id)

      first_time_programs = Program.where(id: (unpaid_program_ids - paid_program_ids))
      fee = first_time_programs.inject(Money.new(0)){|sum, program| sum + Money.new(program.registration_fee)}
      if fee > 0
        itemizations[:one_time_signup_fee] = fee
      else
        Money.new(0)
      end
    end

    def change_fee
      program_ids = enrollment_changes.require_fee.joins(enrollment: :program).pluck("programs.id").uniq
      fee = Program.where(id: program_ids).inject(Money.new(0)){|sum, program| sum + Money.new(program.change_fee)}

      if fee > 0
        itemizations[:change_fee] = fee
      else
        Money.new(0)
      end
    end

    def itemize
      itemizations
    end
  end
end
