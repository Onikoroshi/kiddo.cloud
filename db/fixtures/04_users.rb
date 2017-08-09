super_admin = Role.find_by(name: "super_admin")
director = Role.find_by(name: "director")
staff = Role.find_by(name: "staff")
parent = Role.find_by(name: "parent")

#---------------------------

User.seed_once(:email) do |user|
  user.id = 4
  user.email = "bonnie.townsend@gmail.com"
  user.first_name = "Bonnie"
  user.last_name = "Townsend"
  user.roles = [staff]
  user.center = Center.find_by(subdomain: "daviskidsklub")
  user.staff = Staff.create
end

User.seed_once(:email) do |user|
  user.id = 5
  user.email = "olive.wagner@gmail.com"
  user.first_name = "Olive"
  user.last_name = "Wagner"
  user.roles = [staff]
  user.center = Center.find_by(subdomain: "daviskidsklub")
  user.staff = Staff.create
end

User.seed_once(:email) do |user|
  user.id = 6
  user.email = "evan.bridges@gmail.com"
  user.first_name = "Evan"
  user.last_name = "Bridges"
  user.roles = [staff]
  user.center = Center.find_by(subdomain: "daviskidsklub")
  user.staff = Staff.create
end

User.seed_once(:email) do |user|
  user.id = 7
  user.email = "angel.burton@gmail.com"
  user.first_name = "Angel"
  user.last_name = "Burton"
  user.roles = [staff]
  user.center = Center.find_by(subdomain: "daviskidsklub")
  user.staff = Staff.create
end

User.seed_once(:email) do |user|
  user.id = 8
  user.email = "june.hogan@gmail.com"
  user.first_name = "June"
  user.last_name = "Hogan"
  user.roles = [staff]
  user.center = Center.find_by(subdomain: "daviskidsklub")
  user.staff = Staff.create
end

User.seed_once(:email) do |user|
  user.id = 9
  user.email = "aubrey.adkins@gmail.com"
  user.first_name = "Aubrey"
  user.last_name = "Adkins"
  user.roles = [staff]
  user.center = Center.find_by(subdomain: "daviskidsklub")
  user.staff = Staff.create
end

#-----------------------------------------------------------

User.seed_once(:email) do |user|
  user.id = 10
  user.email = "parent.one@gmail.com"
  user.first_name = "Parent"
  user.last_name = "One"
  user.roles = [parent]
  user.center = Center.find_by(subdomain: "daviskidsklub")
  user.parent = Parent.create
end


User.all.map { |u| u.update_attributes!(password: "asdfasdf") }
# https://stackoverflow.com/questions/6004216/devise-how-do-i-forbid-certain-users-from-signing-in
