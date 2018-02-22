module ChildEnrollment
  class EnrollmentPriceCalculator
    attr_reader :account, :enrollments, :itemizations, :total

    def initialize(account)
      @account = account
      @enrollments = account.enrollments.unpaid
      @itemizations = Hash.new
    end

    def calculate
      total = enrollments.inject(Money.new(0)){ |sum, enrollment| sum + Money.new(enrollment.plan.price) }

      total += first_time_user_fee
      total -= discount(total)
      @total = total
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
      unpaid_program_ids = account.enrollments.unpaid.programs.pluck(:id)
      paid_program_ids = account.enrollments.paid.programs.pluck(:id)

      first_time_programs = Program.where(id: (unpaid_program_ids - paid_program_ids))
      fee = first_time_programs.inject(Money.new(0)){|sum, program| sum + Money.new(program.registration_fee)}
      if fee > 0
        itemizations[:one_time_signup_fee] = fee
      else
        Money.new(0)
      end
    end

    def itemize
      itemizations
    end
  end
end
