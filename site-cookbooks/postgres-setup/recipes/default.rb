#
# Cookbook Name:: postgres-setup
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

app_data = node['app_data']

Chef::Application.fatal! "You must set postgres user password." unless app_data['postgres']['password']
Chef::Application.fatal! "You must set postgres app_password." unless app_data['postgres']['app_password']

apt_repository "apt.postgresql.org" do
  uri "http://apt.postgresql.org/pub/repos/apt"
  distribution "#{node['lsb']['codename']}-pgdg"
  components ["main"]
  key "http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc"
  action :add
end

package "pgdg-keyring"

package "postgresql-9.2"
package "libpq-dev"
package "postgresql-client-9.2"

service "postgresql" do
  service_name "postgresql"
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

template "/etc/postgresql/9.2/main/pg_hba.conf" do
  source "pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 00600
  notifies :reload, 'service[postgresql]', :immediately
end

bash "assign-postgres-password" do
  user 'postgres'
  code <<-EOH
echo "ALTER ROLE postgres ENCRYPTED PASSWORD '#{app_data['postgres']['password']}';" | psql
  EOH
  not_if "echo '\connect' | PGPASSWORD=#{app_data['postgres']['password']} psql --username=postgres --no-password -h localhost"
  action :run
end

bash "create-application-user" do
  user 'postgres'
  code <<-EOH
echo "CREATE USER #{node['app_name']};" | psql 
  EOH
  not_if "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='#{node['app_name']}'\""
  action :run
end

bash "assign-application-user-password" do
  user 'postgres'
  code <<-EOH
echo "ALTER ROLE #{node['app_name']} ENCRYPTED PASSWORD '#{app_data['postgres']['app_password']}';" | psql
  EOH
  not_if "echo '\connect' | PGPASSWORD=#{app_data['postgres']['app_password']} psql --username=#{node['app_name']} --no-password -h localhost"
  action :run
end

bash "create-application-db" do
  user 'postgres'
  code <<-EOH
echo "CREATE DATABASE #{node['app_name']}_#{app_data['rails_env']};" | psql
  EOH
  not_if "psql -tAc \"SELECT 1 from pg_database where datname='#{node['app_name']}_#{app_data['rails_env']}';\""
  action :run
end

bash "grant-privs-on-application-db" do
  user 'postgres'
  code <<-EOH
echo "GRANT ALL PRIVILEGES ON DATABASE #{node['app_name']}_#{app_data['rails_env']} to #{node['app_name']};" | psql
  EOH
  action :run
end


directory "/home/postgres" do
  action :create
  owner "postgres"
  mode "0744"
  recursive true
end

cookbook_file "pg_backup.config" do
  backup false
  path "/home/postgres/pg_backup.config"
  owner "postgres"
end

cookbook_file "pg_backup.sh" do
  backup false
  path "/home/postgres/pg_backup.sh"
  mode "0744"
  owner "postgres"
end

cron "pg_backup" do
  hour "5"
  minute "0"
  day "*"
  user "postgres"
  command "/home/postgres/pg_backup.sh"
end

node['app_data']['postgres']['allowed_app_servers'].each do |server|
  firewall_rule "postgres" do
    port      5432
    source    "#{server}/32"
    action    :allow
  end
end