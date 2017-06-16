Child.seed_once(:id) do |c|
  c.id = 1
  c.parent_id = 10
  c.first_name = "Jill"
  c.last_name = "Newman"
end