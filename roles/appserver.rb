name "appserver"
run_list "recipe[unicorn-setup]", "recipe[nodejs-setup]"

default_attributes(
  :unicorn => {
    :worker_processes => 4,
    :executable => "unicorn"
  }
)