Parent.seed_once(:id) do |p|
  p.id = 10
  p.account_id = 1
  p.user_id = 10
  p.primary = true
  p.first_name = "Parent"
  p.last_name = "One"
end

Child.seed_once(:id) do |c|
  c.id = 1
  c.account_id = 1
  c.first_name = "Jill"
  c.last_name = "Newman"
end

Child.seed_once(:id) do |c|
  c.id = 2
  c.account_id = 1
  c.first_name = "Hunter"
  c.last_name = "Thompson"
end

Child.seed_once(:id) do |c|
  c.id = 3
  c.account_id = 1
  c.first_name = "Sage"
  c.last_name = "Sprague"
end

Child.seed_once(:id) do |c|
  c.id = 4
  c.account_id = 1
  c.first_name = "Caspian"
  c.last_name = "Reed"
end

Child.seed_once(:id) do |c|
  c.id = 5
  c.account_id = 1
  c.first_name = "Landon"
  c.last_name = "Newman"
end

Child.seed_once(:id) do |c|
  c.id = 6
  c.account_id = 1
  c.first_name = "Raquel"
  c.last_name = "Rivera"
end

Child.seed_once(:id) do |c|
  c.id = 7
  c.account_id = 1
  c.first_name = "Caroline"
  c.last_name = "Murray"
end

Child.seed_once(:id) do |c|
  c.id = 8
  c.account_id = 1
  c.first_name = "Dani"
  c.last_name = "Osorio"
end

Child.find((1..8).to_a).map! { |c| Parent.find(10).children << c }
