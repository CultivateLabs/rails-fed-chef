include_recipe "nfs"

app_data = node.default['app_data'] = data_bag_item("apps", node['data_bag'] || node['app_name'])

app_data['nfs']['export_folders'].each do |folder|

  directory "#{app_data['nfs']['export_dir']}#{folder}" do
    action :create
    owner app_data["user"]["name"]
    mode "0755"
  end

  nfs_export "#{app_data['nfs']['export_dir']}#{folder}" do
    network app_data['rails_servers']
    writeable true
    sync true
    options ['no_root_squash', 'no_subtree_check']
  end
end

if node['app_data']['rails_servers']
  node['app_data']['rails_servers'].each do |server|
    firewall_rule "nfs" do
      port      2049
      if server.include? "/"
        source    "#{server}"
      else
        source    "#{server}/32"
      end
      action    :allow
    end

    firewall_rule "nfs" do
      port      111
      if server.include? "/"
        source    "#{server}"
      else
        source    "#{server}/32"
      end
      action    :allow
    end
  end
end