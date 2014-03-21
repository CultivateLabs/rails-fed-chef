name "webserver"
run_list "recipe[nginx-setup]"

default_attributes(
  "firewall" => {
    "rules" => [
      "http" => { "port" => "80" },
      "https" => { "port" => "443" }
    ]
  },
  "nginx" => {
    "load_balancer_enabled" => false,
    "ssl_on" => false
  }
)