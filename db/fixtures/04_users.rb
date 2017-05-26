super_admin = Role.find_by(name: "super_admin")
wu_admin = Role.find_by(name: "wu_admin")
btv_admin = Role.find_by(name: "btv_admin")

User.seed_once(:email) do |user|
  user.id = 1
  user.email = "jason.eastwood@ibethel.org"
  user.first_name = "Jason"
  user.last_name = "Eastwood"
  user.roles = [super_admin, wu_admin, btv_admin]
  user.permissions = Permission.all
end

User.seed_once(:email) do |user|
  user.id = 2
  user.email = "keith.ward@ibethel.org"
  user.first_name = "Keith"
  user.last_name = "Ward"
  user.roles = [super_admin, wu_admin, btv_admin]
end

User.seed_once(:email) do |user|
  user.id = 3
  user.email = "mrortner@gmail.com"
  user.first_name = "Mike"
  user.last_name = "Ortner"
  user.roles = [super_admin, wu_admin, btv_admin]
end

User.seed_once(:email) do |user|
  user.id = 4
  user.email = "baltazar.pazos@bethel.com"
  user.first_name = "Baltazar"
  user.last_name = "Pazos"
  user.roles = [super_admin, wu_admin, btv_admin]
end

User.seed_once(:email) do |user|
  user.id = 5
  user.email = "holly.brunson@ibethel.org"
  user.first_name = "Holly"
  user.last_name = "Brunson"
  user.roles = [btv_admin]
end

User.seed_once(:email) do |user|
  user.id = 6
  user.email = "joshua@bethelmusic.com"
  user.first_name = "Josh"
  user.last_name = "Mohline"
  user.roles = [wu_admin]
end

User.seed_once(:email) do |user|
  user.id = 7
  user.email = "senordelaflor@gmail.com"
  user.first_name = "Pablo"
  user.last_name = "Martinez De La Flor"
  user.roles = [super_admin, wu_admin, btv_admin]
end

User.seed_once(:email) do |user|
  user.id = 8
  user.email = "christian.smith@bethelmusic.com"
  user.first_name = "Christian"
  user.last_name = "Smith"
  user.roles = [super_admin, wu_admin, btv_admin]
end

User.all.map { |u| u.update_attributes!(password: "asdfasdf") }
