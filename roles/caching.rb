name "caching"
run_list "recipe[memcached]", "recipe[memcached-setup]"