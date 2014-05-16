default['backup']['config_path']  = '/etc/backup'
default['backup']['log_path']     = '/var/log'
default['backup']['model_path']   = "#{node['backup']['config_path']}/models"
default['backup']['user']         = "root"
default['backup']['group']        = 'root'
default['backup']['version']      = '4.0.1'