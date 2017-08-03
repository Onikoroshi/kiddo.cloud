# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* Rails secrets
  * Set env variable in production `RAILS_MASTER_KEY` to value in `config/secrets.yml.key`
  * `config/secrets.yml.enc` can be safely commited to repo, contains encrypted values contained in secrets file
  * `EDITOR=vim bin/rails secrets:edit` to edit the secrets file.

# Deployments

We use Heroku for deployments. Assuming you already have a login below you will find instructions for first time machine setup, then routine deployment info.

## First time setup

* Go here: https://devcenter.heroku.com/articles/container-registry-and-runtime#getting-started
* Follow those steps. :)

## Routine Deployments

* 