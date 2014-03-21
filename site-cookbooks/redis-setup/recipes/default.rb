if node['app_data']['rails_servers']
  node['app_data']['rails_servers'].each do |server|
    firewall_rule "redis" do
      port      6379
      source    "#{server}/32"
      action    :allow
    end
  end
end