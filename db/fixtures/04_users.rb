super_admin = Role.find_by(name: "super_admin")
director = Role.find_by(name: "director")

User.seed_once(:email) do |user|
  user.id = 1
  user.email = "jeastwood@gmail.com"
  user.first_name = "Jason"
  user.last_name = "Eastwood"
  user.roles = Role.all
  user.permissions = Permission.all
  user.center = Center.find_by(subdomain: "www")
end

User.seed_once(:email) do |user|
  user.id = 2
  user.email = "ian.kilpatrick@gmail.com"
  user.first_name = "Ian"
  user.last_name = "kilpatrick"
  user.roles = Role.all
  user.permissions = Permission.all
end

User.seed_once(:email) do |user|
  user.id = 3
  user.email = "daviskidsklub@aol.com"
  user.first_name = "Lynda"
  user.last_name = "Yancher"
  user.roles = [director]
  user.center = Center.find_by(subdomain: "daviskidsklub")
end

User.all.map { |u| u.update_attributes!(password: "asdfasdf") }

