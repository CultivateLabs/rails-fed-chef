Created by [Federis Group](http://federisgroup.com) for use with [Inked](https://www.inkedcrm.com) and [SecondCityBits](https://www.secondcitybits.com). Also, special thanks for contributions from the team at [Inkling Markets](http://inklingmarkets.com/).

This chef kitchen can be used to quickly set up servers for use with a standard rails stack. Cookbooks include postgres, mysql, nginx, unicorn, nodejs, redis, and memcache. It also attempts to perform some typical tasks like postgres backups, setting up ufw firewall rules, and installing fail2ban.


Getting Started
===============

```bash
 git clone git@github.com:federis/rails-chef.git
 cd rails-chef
 gem install knife-solo
 gem install berkshelf
```

Adding an app
-------------

### Add a databag

Add a file to ```databags/apps/```, similar to the example in that directory. To generate a password for the deploy user, you can do ```openssl passwd -1 "plantextpassword"``` and replace the user password with the output of that command.

In order to generate postgres passwords, you need to take the md5 hash of passwordapp_name, prepend it with the text "md5", and add that as the postgres app_password (e.g. the md5 of my_passwordmy_app is 31f512a71a75ddd5c0e41b189b8974b1, so you would put md531f512a71a75ddd5c0e41b189b8974b1 for the postgres app_password). You need to do the same for the postgres user, using the md5 of my_passwordpostgres.

### Add a node

You also need to add a node for your app. It should be named with the IP or FQDN of your server (e.g. 123.123.123.123.json). You then need to populate the run list, similar to the ```nodes/example.json``` file. This file should also include your rails app name, and the data bag for the app. The value of the data_bag attribute in this file should match the id value in your databag.


Setting Up a New Server
=======================

Prep the Server
---------------

```bash
knife solo prepare username@123.123.123.123
```

This will install chef-solo on the target machine.


Run Chef on the Server
----------------------

```bash
knife solo cook username@123.123.123.123
```

or to specify a node to use:

```bash
knife solo cook username@123.123.123.123 nodes/staging.json
```

Set the DB_PASS Environment Var
===============================
If the server you're setting up includes the appserver role (ie. an app server or staging server), then you need to set the DB_PASS environment variable to the db user's password. In the deploy user's bashrc file, you should put the following:

```bash
export DB_PASS=dbpasswordhere
```

This line must be placed above the line containing [ -z "$PS1" ] && return


Deploying Your Rails App to the Server
======================================

Assuming you are using capistrano, you need to set your deploy_to path:

```ruby
set :deploy_to, '/var/www/apps/my_app_name'
```

You also need to set your database username to the same as your app name, since that is how the chef recipe sets up the user in postgres. Something like: 

```
production:
  adapter: postgresql
  encoding: unicode
  host: localhost
  database: my_app_name_production
  pool: 5
  username: my_app_name
  password: ENV['DB_PASS']
```

Also, add stop, start, and reset tasks to your deploy script for unicorn. Something like:

```
namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command do
      on roles(:app) do |host|
        execute "/etc/init.d/unicorn #{command}"
      end
    end
  end

  after :finishing, 'deploy:cleanup'
end

after 'deploy:publishing', 'deploy:restart'
```

We do NOT install or use rvm, so you should not need capistrano's rvm integration.


Configuration
=============

Configuring MySQL
-----------------

Add the ```mysql``` role to the node that will run MySQL

_Note: We currenly only support a single-server MySQL setup_

Add MySQL deploy user password to the data-bag:

```javascript
"mysql_configuration": {
  "password": "app_password"
}
```

Add MySQL server configuration to the MySQL server node:

```javascript
"mysql": {
  "server_debian_password": "abc",
  "server_root_password": "def",
  "server_repl_password": "ghi",
  "client": {
    "packages": ["mysql-client", "libmysqlclient-dev", "ruby-mysql"]
  }
}

```
Configuring Memcached
---------------------

Add the ```caching-client``` role to the nodes that will be connecting to the memcached servers
Add the ```caching``` role to the node that will act as the memcached servers

Add (or create) the ip-addresses of the client nodes to the ```"rails_servers"``` data-bag array. Firewall exclusions will be added for each of these servers on the memcached servers:

```javascript
"rails_servers" : ["74.125.225.38","98.139.183.24"]
```

Configuring Background Jobs (Redis)
-----------------------------------

Add the ```jobs``` role to the nodes that will run redis

Add (or create) the ip-addresses of the client nodes to the ```"rails_servers"``` data-bag array. Firewall exclusions will be added for each of these servers on the redis servers. 


```javascript
"rails_servers" : ["74.125.225.38","98.139.183.24"]
```



Adding Cookbooks
================

Adding a New Cookbook to site-cookbooks
---------------------------------------

We add cookbooks that we created to the site-cookbooks folder, since Berkshelf manages community cookbooks in the cookbooks directory. You can add a new one via:

```bash
knife cookbook create cookbook_name_here -o site-cookbooks/
```


Adding New Community Cookbooks
------------------------------

Add a line to the Berksfile such as 

```ruby
cookbook 'nginx'
```

Then run:

```bash
berks install
```
