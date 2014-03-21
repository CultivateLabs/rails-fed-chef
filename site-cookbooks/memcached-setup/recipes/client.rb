%w{ libcurl4-openssl-dev libsasl2-dev libmemcached-dev }.each do |pkg_name|
  package pkg_name
end