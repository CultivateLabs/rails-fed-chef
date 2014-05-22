#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2013, Federis Inc.
#
# All rights reserved - Do Not Redistribute
#

Chef::Application.fatal! "You must set an app_name" unless node['app_name']

app_data = node.default['app_data'] = data_bag_item("apps", node['data_bag'] || node['app_name'])
Chef::Application.fatal! "You must create a data bag for your app" unless app_data

user app_data["user"]["name"] do
  password app_data["user"]["password"]
  gid "sudo"
  home "/home/#{app_data["user"]["name"]}"
  supports manage_home: true
  shell "/bin/bash"
end

directory "/home/#{app_data["user"]["name"]}/.ssh" do
  action :create
  owner app_data["user"]["name"]
  mode "0700"
end

if app_data["user"]["allowed_ssh_keys"] && app_data["user"]["allowed_ssh_keys"].is_a?(Array)
  file "/home/#{app_data["user"]["name"]}/.ssh/authorized_keys" do
    action :create
    owner app_data["user"]["name"]
    mode "0700"
    content app_data["user"]["allowed_ssh_keys"].join("\n")
  end
end

directory "/var/www" do
  action :create
end

directory "/var/www/apps" do
  action :create
  owner app_data["user"]["name"]
  mode "0755"
end

%w{ vim libcurl4-gnutls-dev libssl-dev unattended-upgrades fail2ban }.each do |pkg_name|
  package pkg_name
end

cookbook_file "10periodic" do
  backup false
  path "/etc/apt/apt.conf.d/10periodic"
  action :create_if_missing
end

cookbook_file "50unattended-upgrades" do
  backup false
  path "/etc/apt/apt.conf.d/50unattended-upgrades"
  action :create_if_missing
end

ruby_build_ruby app_data['ruby']['ruby-build-version'] do
  if app_data['ruby']['configure-opts']
    environment({ 'CONFIGURE_OPTS' => "#{app_data['ruby']['configure-opts']}" })
  end
end

ruby_block "update-bashrc" do
  block do
    new_text = <<-EOS
export RUBYOPT="rubygems"
export PATH="/usr/local/ruby/#{app_data['ruby']['ruby-build-version']}/bin:$PATH"
alias current="cd #{node[:app_deploy_dir]}/current"
alias console="cd #{node[:app_deploy_dir]}/current && RAILS_ENV=#{node[:app_data][:rails_env]} bundle exec rails c"
    EOS

    f = File.open("/home/#{app_data["user"]["name"]}/.bashrc")
    file = f.read
    f.close

    unless file.include?(new_text)
      new_file = File.new("/home/#{app_data["user"]["name"]}/.bashrc.new", "w")
      new_file.write new_text
      new_file.write file
      new_file.close

      File.rename("/home/#{app_data["user"]["name"]}/.bashrc", "/home/#{app_data["user"]["name"]}/.bashrc.old")
      File.rename("/home/#{app_data["user"]["name"]}/.bashrc.new", "/home/#{app_data["user"]["name"]}/.bashrc")
      File.delete("/home/#{app_data["user"]["name"]}/.bashrc.old")
    end
  end
end

# Need to reload OHAI to ensure the newest ruby is loaded up
ohai "reload" do
  action :reload
end

gem_package "bundler" do
  gem_binary "/usr/local/ruby/#{app_data["ruby"]["ruby-build-version"]}/bin/gem"
  action :install
end

# Firewall exclusion for outgoing SMTP
firewall_rule "smtp" do
  port      587
  direction :out
  action    :allow
end