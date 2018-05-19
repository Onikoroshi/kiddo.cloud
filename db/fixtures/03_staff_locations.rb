User.staff.find_each do |staff_user|
  staff_obj = staff_user.staff
  (0..rand(3)).each do |num|
    location = Location.all.sample
    while staff_obj.locations.include?(location)
      location = Location.all.sample
    end

    StaffLocation.create!(staff: staff_obj, location: location)
  end
end
