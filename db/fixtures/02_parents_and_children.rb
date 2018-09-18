index = 0
User.parent_users.find_each do |parent_user|
  Account.seed_once(:id) do |a|
    a.id = 1 + index
    a.user_id = parent_user.id
    a.center = parent_user.center
    a.signup_complete = true
  end
  account = Account.last

  Parent.seed_once(:id) do |p|
    p.id = 10 + index
    p.account_id = account.id
    p.user_id = account.user_id
    p.primary = true
    p.first_name = "Parent"
    p.last_name = parent_user.last_name
    p.phone = Forgery('address').phone
  end
  parent = Parent.last

  Address.seed_once(:id) do |a|
    a.addressable = parent
    a.street = Forgery('address').street_address
    a.locality = "Davis"
    a.region = "California"
    a.postal_code = "95617"
    a.country_code_alpha3 = "USA"
  end

  (0..rand(5)).each do |num|
    gender = Gender.all.sample
    Child.seed_once(:id) do |c|
      c.id = (index * 10) + num + 1
      c.account_id = account.id
      c.first_name = gender.male? ? Forgery('name').male_first_name : Forgery('name').female_first_name
      c.last_name = Forgery('name').last_name
      c.gender = gender.to_s
      c.grade_entering = Child.available_grades.sample
      c.birthdate = ((Time.zone.today - 12.years)..(Time.zone.today - 3.years)).to_a.sample
    end
    child = Child.last

    parent.children << child
  end

  index += 1
end
