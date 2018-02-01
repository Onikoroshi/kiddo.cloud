days = [:monday, :tuesday, :wednesday, :thursday, :friday]
sans_wednesday = [:monday, :tuesday, :thursday, :friday]

Child.find_each do |child|
  chosen_plan = Plan.all.sample

  as_id = AttendanceSelection.maximum(:id).to_i + 1
  AttendanceSelection.seed_once do |as|
    as.id = as_id
    as.child_id = child.id
    as.monday = false
    as.tuesday = false
    as.wednesday = false
    as.thursday = false
    as.friday = false
    as.saturday = false
    as.sunday = false
  end
  as = AttendanceSelection.find(as_id)
  if chosen_plan.short_code == "week_1"
    as.update_attribute(sans_wednesday.sample, true)
  else
    days.sample(chosen_plan.days_per_week).each do |weekday|
      as.update_attribute(weekday, true)
    end
  end

  Enrollment.seed_once(:id) do |e|
    e.id = Enrollment.maximum(:id).to_i + 1
    e.child_id = child.id
    e.location_id = child.locations.all.sample.id
    e.plan_id = chosen_plan.id
  end
end
