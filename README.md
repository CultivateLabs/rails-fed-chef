Getting Started
---------------

```bash
 git clone insert_url_here
 cd rails-chef
 gem install knife-solo
 gem install berkshelf
 ```

Adding a New Cookbook to site-cookbooks
---------------------------------------

We add cookbooks that we created to the site-cookbooks folder, since Librarian manages community cookbooks in the cookbooks directory. You can add a new one via:

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


Setting Up a New Server
=======================

Prep the Server
---------------

```bash
 knife solo prepare username@ip_address
```

This will install chef-solo on the target machine.


Run Chef on the Server
----------------------

```bash
 knife solo cook username@ip_address
```

or to specify a node to use:

```bash
 knife solo cook username@ip_address nodes/staging.json
```


Set the DB_PASS Environment Var
-------------------------------

If the server you're setting up includes the appserver role (ie. an app server or staging server), then you need to set the DB_PASS environment variable to the db user's password. In the deploy user's bashrc file, you should put the following:

export DB_PASS=dbpasswordhere

This line must be placed above the line containing [ -z "$PS1" ] && return


Deploy With Capistrano
----------------------

```bash
 cap stage_name deploy
```

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
