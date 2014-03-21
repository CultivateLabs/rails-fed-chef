include_recipe "database"

gem_package "mysql" do
  gem_binary "/opt/chef/embedded/bin/gem"
end

app_data = node.default['app_data'] = data_bag_item("apps", node['data_bag'] || node['app_name'])

mysql_configuration = app_data['mysql_configuration']
database_name = "#{node['app_name']}_#{app_data['rails_env']}"

mysql_connection_info = {:host => "localhost", :username => "root", :password => node['mysql']['server_root_password']}

mysql_database database_name do
  connection(mysql_connection_info)
end

mysql_database_user database_name do
  connection(mysql_connection_info)
  username node['app_name']
  password mysql_configuration['password']
  table "*"
  host "localhost"
  action :grant
end

ohai "reload" do
  action :reload
end

mysql_configuration['allowed_app_servers'].each do |server|

  mysql_database_user database_name do
    connection(mysql_connection_info)
    username node['app_name']
    password mysql_configuration['password']
    table "*"
    host "#{server}/32"
    action :grant
  end

  firewall_rule "mysql" do
    port      3306
    source    "#{server}/32"
    action    :allow
  end

end