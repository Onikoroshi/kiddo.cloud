Child.seed_once(:id) do |c|
  c.id = 1
  c.account_id = 1
  c.parent_id = 10
  c.first_name = "Jill"
  c.last_name = "Newman"
  c.locations = [Location.find(2), Location.find(3)]
end

Child.seed_once(:id) do |c|
  c.id = 2
  c.account_id = 1
  c.parent_id = 10
  c.first_name = "Hunter"
  c.last_name = "Thompson"
  c.locations = [Location.find(2), Location.find(3)]
end

Child.seed_once(:id) do |c|
  c.id = 3
  c.account_id = 1
  c.parent_id = 10
  c.first_name = "Caspian"
  c.last_name = "Reed"
  c.locations = [Location.find(2), Location.find(3)]
end