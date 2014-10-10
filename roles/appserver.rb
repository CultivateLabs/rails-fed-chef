name "appserver"
run_list "recipe[unicorn-setup]", "recipe[nodejs-setup]", "recipe[imagemagick]"

default_attributes(
  :unicorn => {
    :worker_processes => 4,
    :executable => "unicorn"
  }
)