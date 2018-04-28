module ChildEnrollment
  class EnrollmentPriceCalculator
    attr_reader :account, :enrollments, :enrollment_changes, :itemizations, :total

    def initialize(account)
      @account = account
      @enrollments = account.enrollments.alive.unpaid
      @enrollment_changes = account.enrollment_changes.pending
      @itemizations = Hash.new
    end

    def calculate
      total = enrollments.total_amount_due_today
      total += enrollment_changes.charge_total

      total += first_time_user_fee
      total += change_fee
      @total = total
    end

    def refund_total
      @refund_total ||= enrollment_changes.refund_total
    end

    def first_time_user_fee
      if @first_time_user_fee.blank?
        total_fee = Money.new(0)

        first_time_programs = []
        account.enrollments.alive.programs.find_each do |program|
          next if account.transactions.paid_signup_fee_for_program(program).any?

          fee = Money.new(program.registration_fee)
          if fee > 0
            itemizations["signup_fee_#{program.id}".to_sym] = fee
            total_fee += fee
          end
        end

        @first_time_user_fee = total_fee
      end

      @first_time_user_fee
    end

    def change_fee
      if @change_fee.blank?
        total_fee = Money.new(0)

        changed_programs.each do |program|
          fee = Money.new(program.change_fee)
          if fee > 0
            itemizations["change_fee_#{program.id}".to_sym] = fee
            total_fee += fee
          end
        end

        @change_fee = total_fee
      end

      @change_fee
    end

    def itemize
      itemizations
    end

    def programs
      program_ids = enrollments.programs.pluck(:id)
      program_ids += independent_enrollment_changes.joins(enrollment: :program).pluck("programs.id")
      program_ids = program_ids.uniq

      @programs ||= Program.where(id: program_ids)
    end

    def changed_programs
      program_ids = enrollment_changes.require_fee.joins(enrollment: :program).pluck("programs.id").uniq
      @changed_programs ||= Program.where(id: program_ids)
    end

    def children_by_program(program)
      children_ids = enrollments.by_program(program).pluck(:child_id)
      children_ids += independent_enrollment_changes.joins(:enrollment).pluck("enrollments.child_id")
      children_ids = children_ids.uniq

      Child.where(id: children_ids)
    end

    def independent_enrollment_changes
      considered_enrollment_ids = enrollments.pluck(:id)
      @independent_enrollment_changes ||= enrollment_changes.where.not(enrollment_id: considered_enrollment_ids)
    end

    def enrollments_by_program_and_child(program, child)
      enrollments.by_program(program).by_child(child)
    end

    def independent_enrollment_changes_by_program_and_child(program, child)
      independent_enrollment_changes.joins(enrollment: {plan: :program}).where("programs.id = ? AND enrollments.child_id = ?", program.id, child.id)
    end

    def itemizations_by_program(program)
      itemizations.select{|key, value| key.to_s.split("_fee_")[1] == program.id.to_s}
    end
  end
end
