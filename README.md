# Readme

#### Extra Start-Up Commands:
`rake jobs:work`

#### Beta URL:
https://kiddocloud-staging.herokuapp.com

#### New Live Site:
manage.daviskidsklub.com
https://kiddocloud.herokuapp.com/
https://daviskidsklub.com/wp-admin/

#### Wordpress Admin
https://iank.us/dkk/
https://iank.us/dkk/wp-login.php

#### Deploy to Production:
```
git push production master
heroku run rake db:migrate -a kiddocloud
```

#### Deploy to Beta:
```
git push beta master
heroku run rake db:migrate -a kiddocloud-staging
```

#### Deploy to Beta with non-master branch:
```
git push beta branch_name:master
heroku run rake db:migrate -a kiddocloud-staging
```
**WARNING: When done, use `git push -f beta master:master` to reset when back to master.**

#### See Heroku Logs
`heroku logs -t -a kiddocloud`
`heroku logs -t -a kiddocloud-staging`

#### Get to Heroku Rails Console:
`heroku run console -a kiddocloud`
`heroku run console -a kiddocloud-staging`

#### Run Rake Task on Heroku
`heroku run rake task:name -a kiddocloud`
`heroku run rake task:name -a kiddocloud-staging`

#### Reload Beta Database
```
heroku pg:reset DATABASE -a kiddocloud-staging --confirm kiddocloud-staging
heroku run rake db:reload -a kiddocloud-staging
```

**if it hangs, seed manually:**
`heroku run rake db:seed -a kiddocloud-staging`

#### Change Wordpress banner about closed sites:
`https://daviskidsklub.com/wp-admin/theme-editor.php?file=header.php&theme=bridge line 929`

### Set Up Heroku environments on local machine
#### For beta:
`heroku git:remote -a kiddocloud-staging`

`git remote rename heroku beta`

#### For production:
`heroku git:remote -a kiddocloud`

`git remote rename heroku production`

#### Your list should look like this at the end:
`git remote -v`
```
beta    https://git.heroku.com/kiddocloud-staging.git (fetch)
beta    https://git.heroku.com/kiddocloud-staging.git (push)
origin    git@github.com:eastwoj/kiddo.cloud.git (fetch)
origin    git@github.com:eastwoj/kiddo.cloud.git (push)
production    https://git.heroku.com/kiddocloud.git (fetch)
production    https://git.heroku.com/kiddocloud.git (push)
```
