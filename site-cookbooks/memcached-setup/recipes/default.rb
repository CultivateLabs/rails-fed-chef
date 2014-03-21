if node['app_data']['rails_servers']
  node['app_data']['rails_servers'].each do |server|
    firewall_rule "memcached" do
      port      11211
      source    "#{server}/32"
      action    :allow
    end
  end
end