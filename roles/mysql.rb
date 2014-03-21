name "mysql"
run_list "recipe[build-essential]", "recipe[mysql::server]", "recipe[mysql::client]", "recipe[mysql-setup]"