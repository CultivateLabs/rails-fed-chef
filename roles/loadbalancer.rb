name "loadbalancer"
run_list "recipe[nginx-setup::loadbalancer]"

default_attributes({
  "firewall" => {
    "rules" => [
      "http" => { "port" => "80" },
      "https" => { "port" => "443" }
    ]
  }
})