first_time = Time.zone.parse("today at 8:00am")
last_time = Time.zone.parse("today at 6:00pm")

User.staff.find_each do |staff_user|
  staff_obj = staff_user.staff
  next if staff_obj.blank?

  rand(0..5).times do
    location = staff_obj.locations.sample
    target_start_time = rand(first_time..(last_time - 1.hour))
    TimeEntry.create(time_recordable: staff_obj, location: location, record_type: TimeEntryType[:entry], time: target_start_time)
    target_stop_time = rand(target_start_time..last_time)
    TimeEntry.create(time_recordable: staff_obj, location: location, record_type: TimeEntryType[:exit], time: target_stop_time)
  end
end

Child.find_each do |child_obj|
  rand(0..5).times do
    location = child_obj.locations.sample
    target_start_time = rand(first_time..(last_time - 1.hour))
    TimeEntry.create(time_recordable: child_obj, location: location, record_type: TimeEntryType[:entry], time: target_start_time)
    target_stop_time = rand(target_start_time..last_time)
    TimeEntry.create(time_recordable: child_obj, location: location, record_type: TimeEntryType[:exit], time: target_stop_time)
  end
end
