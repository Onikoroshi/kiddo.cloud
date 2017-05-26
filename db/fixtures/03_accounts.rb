Account.seed_once(:name) do |account|
  account.id = 1
  account.name = "Kiddo Cloud"
  account.subdomain = "www"
end

Account.seed_once(:name) do |account|
  account.id = 2
  account.name = "Davis Kids Klub"
  account.subdomain = "daviskidsklub"
end

Account.seed_once(:name) do |account|
  account.id = 3
  account.name = "Conejo Valley Care"
  account.subdomain = "conejovalleycare"
end

Account.seed_once(:name) do |account|
  account.id = 4
  account.name = "Bethel Kids"
  account.subdomain = "bethelkids"
end

