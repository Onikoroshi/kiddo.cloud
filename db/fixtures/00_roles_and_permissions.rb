# Roles are based on identity. For example, I can "act in" a role of staff.
Role.seed_once(:name) do |role|
  role.id = 1
  role.name = "super_admin"
end

Role.seed_once(:name) do |role|
  role.id = 2
  role.name = "director"
end

