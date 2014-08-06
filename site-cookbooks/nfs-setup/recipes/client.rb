app_data = node.default['app_data'] = data_bag_item("apps", node['data_bag'] || node['app_name'])

directory "/var/www/apps/#{node['app_name']}" do
  action :create
  owner app_data["user"]["name"]
  mode "0755"
end

directory "/var/www/apps/#{node['app_name']}/shared" do
  action :create
  owner app_data["user"]["name"]
  mode "0755"
end

app_data['nfs']['export_folders'].each do |folder|

  directory "/var/www/apps/#{node['app_name']}/shared/#{folder}" do
    action :create
    owner app_data["user"]["name"]
    mode "0755"
  end

  mount "/var/www/apps/#{node['app_name']}/shared/#{folder}" do
    device "#{app_data['nfs']['server']}:#{app_data['nfs']['export_dir']}#{folder}"
    fstype "nfs"
    options "rw"
    action [:mount, :enable]
  end
end