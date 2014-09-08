if node['app_data']['rails_servers']
  node['app_data']['rails_servers'].each do |server|
    firewall_rule "redis" do
      port      6379
      if server.include? "/"
        source    "#{server}"
      else
        source    "#{server}/32"
      end
      action    :allow
    end
  end
end