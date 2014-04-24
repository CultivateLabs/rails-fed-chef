#
# Cookbook Name:: nginx-setup
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "nginx::source"
node.default[:nginx] = Chef::Mixin::DeepMerge.merge(node[:nginx], [ node[:app_data][:nginx] ])

template "#{node[:nginx][:dir]}/sites-available/#{node[:app_name]}" do
  if node['app_data']['nginx'] && node['app_data']['nginx']['ssl_on'] && !node['app_data']['nginx']['load_balancer_enabled']
    source "ssl_site.conf.erb"
  else
    source "site.conf.erb"
  end
end

template "/etc/logrotate.d/nginx" do
  source "logrotate_nginx.erb"
  mode "0644"
end

nginx_site node[:app_name]