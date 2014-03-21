name "jobs"
run_list "recipe[redisio::install]", "recipe[redisio::enable]", "recipe[redis-setup]"

