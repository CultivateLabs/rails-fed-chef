apt_repository "apt.postgresql.org" do
  uri "http://apt.postgresql.org/pub/repos/apt"
  distribution "#{node['lsb']['codename']}-pgdg"
  components ["main"]
  key "http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc"
  action :add
end

package "libpq-dev"
package "postgresql-client-9.2"