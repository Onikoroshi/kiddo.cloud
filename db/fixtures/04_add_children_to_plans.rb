# Just for development, make sure all programs are in session
Program.find_each do |program|
  program.update_attribute(:starts_at, Time.zone.today - 1.month)
  program.update_attribute(:ends_at, Time.zone.today + 3.months)
  program.update_attribute(:registration_opens, Time.zone.today - 2.months)
  program.update_attribute(:registration_closes, Time.zone.today + 2.months)
end

days = [:monday, :tuesday, :wednesday, :thursday, :friday]
sans_wednesday = [:monday, :tuesday, :thursday, :friday]

Child.find_each do |child|
  (1..3).to_a.sample.times do
    available_plans = Program.open_for_registration.map{|program| program.plans}.flatten.uniq
    chosen_plan = available_plans.sample
    while chosen_plan.plan_type.contract? && child.plans.by_plan_type("contract").any?
      chosen_plan = available_plans.sample
    end
    ap "chosen type: #{chosen_plan.plan_type}"
    program = chosen_plan.program

    starts_at = nil
    ends_at = nil

    if chosen_plan.plan_type.weekly?
      weeks = []

      curr_monday = nil
      (program.starts_at..program.ends_at).each do |date|
        if date.monday?
          curr_monday = date
        elsif date.friday?
          weeks << [curr_monday, date]
          curr_monday = nil
        end
      end

      week = weeks.sample
      starts_at = week[0]
      ends_at = week[1]
    elsif chosen_plan.plan_type.drop_in?
      target = (program.starts_at..program.ends_at).to_a.sample
      starts_at = target
      ends_at = target
    else
      starts_at = program.starts_at
      ends_at = program.ends_at
    end

    if starts_at.present? && ends_at.present?
      Enrollment.seed_once(:id) do |e|
        e.id = Enrollment.maximum(:id).to_i + 1
        e.child_id = child.id
        e.location_id = program.locations.all.sample.id
        e.plan_id = chosen_plan.id
        e.starts_at = starts_at
        e.ends_at = ends_at

        if chosen_plan.plan_type.weekly?
          e.monday = true
          e.tuesday = true
          e.wednesday = true
          e.thursday = true
          e.friday = true
        elsif chosen_plan.plan_type.drop_in?
          case starts_at.wday
          when 1
            e.monday = true
          when 2
            e.tuesday = true
          when 3
            e.wednesday = true
          when 4
            e.thursday = true
          when 5
            e.friday = true
          end
        else
          num_days = chosen_plan.days_per_week.to_i
          allowed_days = chosen_plan.allowed_days

          if num_days < 0
            num_days = rand(allowed_days.count) + 1
          end

          chosen_days = allowed_days.sample(num_days)
          chosen_days.each do |day_name|
            e.send("#{day_name}=".to_sym, true)
          end
        end
      end
    end
  end
end

Enrollment.find_each do |enrollment|
  enrollment.set_next_target_and_payment_date!
  enrollment.update_attribute(:paid, true)
end
