#
# Cookbook Name:: unicorn-setup
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

app_data = node['app_data']
node.default[:unicorn] = Chef::Mixin::DeepMerge.merge(node[:unicorn], [ app_data[:unicorn] ])

directory "/etc/unicorn" do
  recursive true
  action :create
end

template "/etc/unicorn/#{node['app_name']}.rb" do
  source "unicorn.rb.erb"
  owner app_data['user']['name']
  mode "0755"
end

template "/etc/unicorn/unicorn_init.sh" do
  source "unicorn_init.sh.erb"
  owner "root"
  group "root"
  mode "0755"
end

bash "symlink init script" do
  code "ln -nfs /etc/unicorn/unicorn_init.sh /etc/init.d/unicorn"
  action :run
end

bash "set unicorn to boot on restart" do
  code "update-rc.d unicorn defaults"
  action :run
end

template "/etc/logrotate.d/#{node['app_name']}" do
  source "logrotate_app.erb"
  mode "0644"
end