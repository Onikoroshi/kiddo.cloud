# Kiddo.Cloud

## Runtime Environment
* Ruby Version: 2.4.1
* Rails Version: 5.1.1
* Postgres (via Heroku)

## To Do
* Investigate ActionCable Redis usage (right now production is async)

## Odds and Ends
* Rails secrets
  * Set env variable in production `RAILS_MASTER_KEY` to value in `config/secrets.yml.key`
  * `config/secrets.yml.enc` can be safely commited to repo, contains encrypted values contained in secrets file
  * `EDITOR=vim bin/rails secrets:edit` to edit the secrets file.

## Dev Environment Setup
* Make sure you have both Docker and the Docker Compose CLI installed
  * Docker: https://docs.docker.com/engine/installation/
  * Docker Compose: https://docs.docker.com/compose/install/
* Clone the Repo (Like normal)
* Then run `docker-compose up`
  * This will build the containers and run the app (which is kinda awesome)
* Then run `docker-compose run web rake db:rebuild`
  * Then the DB's will be created and will be seeded
* Docker Compose will mount the current rails app into the web docker image automatically so there's no need to rebuild 
the docker image when you update the code. :)
* When you're done, just run `docker-compose down`
  * Keep in mind, this will destroy the database, so make sure you don't need something there. :)

# Deployments

We use Heroku for deployments. Assuming you already have a login below you will find instructions for first time machine setup, then routine deployment info.

## First time setup

* Go here: https://devcenter.heroku.com/articles/container-registry-and-runtime#getting-started
* Follow those steps. :)

## Routine Deployments

* heroku container:push web
* heroku run rake db:migrate