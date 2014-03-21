#
# Cookbook Name:: nodejs-setup
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package "python-software-properties"

apt_repository "chris-lea-node.js" do
  uri "http://ppa.launchpad.net/chris-lea/node.js/ubuntu"
  distribution node["lsb"]["codename"]
  components ["main"]
  key "C7917B12"
  keyserver "keyserver.ubuntu.com"
  action :add
end

package 'nodejs'