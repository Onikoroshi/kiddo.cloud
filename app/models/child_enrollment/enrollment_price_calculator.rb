module ChildEnrollment
  class EnrollmentPriceCalculator
    attr_reader :account, :params, :enrollment_price_alterations, :enrollments, :enrollment_changes, :itemizations, :total, :refund_total

    def initialize(account, params = {})
      @account = account
      @enrollments = account.enrollments.alive.unpaid
      @enrollment_changes = account.enrollment_changes.pending
      @itemizations = Hash.new
      @params = params
      @enrollment_price_alterations = Hash.new
    end

    def calculate
      total = calculate_enrollments_costs
      total += calculate_enrollment_changes_amounts

      total += first_time_user_fee
      total += change_fee
      @total = total
    end

    def calculate_enrollments_costs
      ap params
      if params["enrollments"].present?
        enrollments.one_time.inject(Money.new(0)) do |sum, enrollment|
          altered_cost = find_altered_amount(params["enrollments"][enrollment.id.to_s])

          if altered_cost.present? && altered_cost != enrollment.amount_due_today.to_money
            @enrollment_price_alterations[enrollment.id.to_s] = altered_cost
          end

          target_cost = @enrollment_price_alterations[enrollment.id.to_s] || enrollment.amount_due_today.to_money

          sum + Money.new(target_cost)
        end
      else
        enrollments.total_amount_due_today
      end
    end

    def calculate_enrollment_changes_amounts
      @refund_total = Money.new(0)

      if params["enrollment_changes"].present?
        enrollment_changes.inject(Money.new(0)) do |sum, change|
          altered_cost = find_altered_amount(params["enrollment_changes"][change.id.to_s])

          if altered_cost.present? && altered_cost != change.amount
            change.update_attribute(:amount, altered_cost)
          end

          @refund_total += change.refund_amount
          sum + change.charge_amount
        end
      else
        @refund_total = enrollment_changes.refund_total
        enrollment_changes.charge_total
      end
    end

    def first_time_user_fee
      if @first_time_user_fee.blank?
        total_fee = Money.new(0)

        account.enrollments.alive.programs.find_each do |program|
          next if account.transactions.paid_signup_fee_for_program(program).any?

          fee = Money.new(program.registration_fee)

          altered_fee = find_altered_itemization_fee("signup_fee_#{program.id}")

          fee = altered_fee if altered_fee.present? && altered_fee != fee

          if fee > 0
            itemizations["signup_fee_#{program.id}".to_sym] = fee
            total_fee += fee
          end
        end

        # if they haven't chosen an enrollment, but there is a summer program available,
        # allow them to register for summer without choosing any enrollments
        if @enrollments.blank? && @enrollment_changes.blank?
          Program.open_for_registration.for_summer.each do |program|
            next if account.transactions.paid_signup_fee_for_program(program).any?

            fee = Money.new(program.registration_fee)

            altered_fee = find_altered_itemization_fee("signup_fee_#{program.id}")

            fee = altered_fee if altered_fee.present? && altered_fee != fee

            if fee > 0
              itemizations["signup_fee_#{program.id}".to_sym] = fee
              total_fee += fee
            end
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

          altered_fee = find_altered_itemization_fee("change_fee_#{program.id}")

          fee = altered_fee if altered_fee.present? && altered_fee != fee

          if fee > 0
            itemizations["change_fee_#{program.id}".to_sym] = fee
            total_fee += fee
          end
        end

        @change_fee = total_fee
      end

      @change_fee
    end

    def find_altered_enrollment_cost(given_enrollment)
      @enrollment_price_alterations[given_enrollment.id.to_s]
    end

    def itemize
      itemizations
    end

    def programs
      program_ids = enrollments.programs.pluck(:id)
      program_ids += independent_enrollment_changes.joins(enrollment: :program).pluck("programs.id")
      program_ids += itemizations.select{|key, value| key.to_s.include?("_fee_")}.map{|key, value| key.to_s.split("_fee_")[1]}
      program_ids = program_ids.map(&:to_s).uniq

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

    def find_altered_amount(orig_string)
      altered_amount = orig_string.present? ? orig_string.to_s.gsub(/[^0-9\.\-]/, "") : nil
      altered_amount = altered_amount.present? ? altered_amount.to_money : nil
    end

    def find_altered_itemization_fee(itemization_key)
      altered_fee = params["itemizations"][itemization_key] if params["itemizations"].present?
      find_altered_amount(altered_fee)
    end
  end
end
