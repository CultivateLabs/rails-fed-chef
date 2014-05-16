#
# Cookbook Name:: backup-setup
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

app_data = node.default['app_data'] = data_bag_item("apps", node['data_bag'] || node['app_name'])

Chef::Application.fatal! "You must set provide backup config for the node." unless node['backup']

gem_package 'backup' do
  gem_binary "/usr/local/ruby/#{app_data["ruby"]["ruby-build-version"]}/bin/gem"
  version node['backup']['version'] if node['backup']['version']
  action :install
end

package "postfix"

%w[ config_path model_path ].each do |dir|
  directory node['backup'][dir] do
    owner node['backup']['user']
    group node['backup']['group']
    mode '0700'
  end
end

template "Backup model file" do
  path ::File.join( node['backup']['model_path'], "model.rb")
  source 'model.rb.erb'
  owner node['backup']['user']
  group node['backup']['group']
  mode '0700'
end

template "Backup config file" do
  path ::File.join( node['backup']['config_path'], "config.rb")
  source 'config.rb.erb'
  owner node['backup']['user']
  group node['backup']['group']
  mode '0600'
end

hour = if node['backup']['schedule']['minute'] && !node['backup']['schedule']['hour']
  '*'
else
  node['backup']['schedule']['hour'] || 0
end

backup_name = "#{node['app_name'].to_sym}_#{app_data['rails_env'].to_sym}_backup"

cron backup_name do
  minute "#{node['backup']['schedule']['minute'] || '0'}"
  hour "#{hour}"
  day "*"
  user "#{node['backup']['user']}"
  command "env RUBYOPT=\"rubygems\" \
    env PATH=\"/usr/local/ruby/#{app_data['ruby']['ruby-build-version']}/bin:$PATH\" \
    backup perform --trigger #{backup_name} \
    --config-file #{node['backup']['config_path']}/config.rb \
    --log-path=#{node['backup']['log_path']} > /dev/null".squeeze(' ')
  mailto node['backup']['notify_mail']['to'] if node['backup']['notify_mail']
end
