name "base"

run_list(
  "recipe[apt]",
  "recipe[git]",
  "recipe[build-essential]",
  "recipe[ruby_build]",
  "recipe[base]", 
  "recipe[ufw]",
  "recipe[nodejs-setup]"
)