Parent.seed_once(:id) do |p|
  p.id = 10
  p.account_id = 1
  p.user_id = 10
  p.primary = true
  p.first_name = "Parent"
  p.last_name = "One"
end

parent = Parent.last
Address.seed_once(:id) do |a|
  a.addressable = parent
  a.street = "34 Main Street"
  a.locality = "Los Angeles"
  a.region = "California"
  a.postal_code = "93240"
  a.country_code_alpha3 = "USA"
end

Child.seed_once(:id) do |c|
  c.id = 1
  c.account_id = 1
  c.first_name = "Jill"
  c.last_name = "Newman"
  c.gender = Gender.all.sample.to_s
  c.grade_entering = Child.available_grades.sample
  c.birthdate = ((Time.zone.today - 12.years)..(Time.zone.today - 3.years)).to_a.sample
  c.grade_entering = Child.available_grades.sample
  c.birthdate = ((Time.zone.today - 12.years)..(Time.zone.today - 3.years)).to_a.sample
end

Child.seed_once(:id) do |c|
  c.id = 2
  c.account_id = 1
  c.first_name = "Hunter"
  c.last_name = "Thompson"
  c.gender = Gender.all.sample.to_s
  c.grade_entering = Child.available_grades.sample
  c.birthdate = ((Time.zone.today - 12.years)..(Time.zone.today - 3.years)).to_a.sample
end

Child.seed_once(:id) do |c|
  c.id = 3
  c.account_id = 1
  c.first_name = "Sage"
  c.last_name = "Sprague"
  c.gender = Gender.all.sample.to_s
  c.grade_entering = Child.available_grades.sample
  c.birthdate = ((Time.zone.today - 12.years)..(Time.zone.today - 3.years)).to_a.sample
end

Child.seed_once(:id) do |c|
  c.id = 4
  c.account_id = 1
  c.first_name = "Caspian"
  c.last_name = "Reed"
  c.gender = Gender.all.sample.to_s
  c.grade_entering = Child.available_grades.sample
  c.birthdate = ((Time.zone.today - 12.years)..(Time.zone.today - 3.years)).to_a.sample
end

Child.seed_once(:id) do |c|
  c.id = 5
  c.account_id = 1
  c.first_name = "Landon"
  c.last_name = "Newman"
  c.gender = Gender.all.sample.to_s
  c.grade_entering = Child.available_grades.sample
  c.birthdate = ((Time.zone.today - 12.years)..(Time.zone.today - 3.years)).to_a.sample
end

Child.seed_once(:id) do |c|
  c.id = 6
  c.account_id = 1
  c.first_name = "Raquel"
  c.last_name = "Rivera"
  c.gender = Gender.all.sample.to_s
  c.grade_entering = Child.available_grades.sample
  c.birthdate = ((Time.zone.today - 12.years)..(Time.zone.today - 3.years)).to_a.sample
end

Child.seed_once(:id) do |c|
  c.id = 7
  c.account_id = 1
  c.first_name = "Caroline"
  c.last_name = "Murray"
  c.gender = Gender.all.sample.to_s
  c.grade_entering = Child.available_grades.sample
  c.birthdate = ((Time.zone.today - 12.years)..(Time.zone.today - 3.years)).to_a.sample
end

Child.seed_once(:id) do |c|
  c.id = 8
  c.account_id = 1
  c.first_name = "Dani"
  c.last_name = "Osorio"
  c.gender = Gender.all.sample.to_s
  c.grade_entering = Child.available_grades.sample
  c.birthdate = ((Time.zone.today - 12.years)..(Time.zone.today - 3.years)).to_a.sample
end

Child.find((1..8).to_a).map! { |c| Parent.find(10).children << c }
