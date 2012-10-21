#
# Cookbook Name:: dspace
# Default:: default
#
# Copyright 2012 <a href="http://bill-ingram_com"'>Bill Ingram</a>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "ark::postgresql-connector"
include_recipe "database::postgresql"
include_recipe "tomcat::postgresqljar"

# define the database connection
postgresql_connection = ({:host => node['dspace']['db_postgresql_host'], :port => node['dspace']['db_postgresql_port'], :username => node['dspace']['db_username'], :password => node['dspace']['db_password']})

# create the dspace postgresql database with additional parameters
postgresql_database node['dspace']['db_postgresql_name'] do
  connection postgresql_connection
  template 'DEFAULT'
  encoding 'UNICODE'
  tablespace 'DEFAULT'
  connection_limit '-1'
  owner node['dspace']['db_username']
  action :create
end


# create the dspace user
postgresql_database_user node['dspace']['db_username'] do
  connection postgresql_connection
  password node['dspace']['db_password']
  action :create
end

# grant permissions to locahost
postgresql_database_user node['dspace']['db_username'] do
  connection postgresql_connection
  password node['dspace']['db_password']
  database_name node['dspace']['db_name']
  host node['dspace']['postgresql_host']
  action :grant
end

# grant permissions
postgresql_database_user node['dspace']['db_username'] do
  connection postgresql_connection
  password node['dspace']['db_password']
  database_name node['dspace']['db_name']
  host node['ipaddress']
  action :grant
end

# make the dspace directory
directory node['dspace']['real_root'] do
  owner "#{node['tomcat']['user']}"
  group "root"
  mode "0755"
  action :create
end

# ln -s /opt/dspace to /opt/dspace3
link node['dspace']['root'] do
  to "#{node['dspace']['real_root']}"
end

# add link required for tomcat (may not matter but installation fails otherwise)
link "#{node['tomcat']['base']}/common/lib" do
  to "classes"
  owner "#{node['tomcat']['user']}"
  group "#{node['tomcat']['user']}"
end

##Create directory to store install scripts in
directory "#{node['dspace']['install_tmp']}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

##get the insall script
remote_file "#{node['dspace']['install_tmp']}/fcrepo-installer-#{node['dspace']['version']}.jar" do
  source "http://#{node['dspace']['source_server']}/#{node['dspace']['source_path']}/fcrepo-installer-#{node['dspace']['version']}.jar"
  mode "0644"
  checksum "aa1d29752a3b62660f3902fdf2763fdd5e3482265b3df920e84c6b5ce38f687e"
  action :create_if_missing
end

##get the install.properties from template
template "#{node['dspace']['install_tmp']}/install.properties" do
  source "install.properties.#{node['dspace']['version']}.erb"
  owner "root"
  group "root"
  mode 0644
end

## install dspace
execute "install_dspace" do
  command "java -jar #{node['dspace']['install_tmp']}/fcrepo-installer-#{node['dspace']['version']}.jar #{node['dspace']['install_tmp']}/install.properties"
  creates "#{node['dspace']['root']}/server/config/dspace.fcfg"
  action :run
end

##set ownership to tomcat for /opt/dspace/*, restart tomcat, sleep for, required for dspace to create directory for apim file below
bash "set_tomcat_perms" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  chown -R #{node['tomcat']['user']} #{node['dspace']['root']}/*
  service tomcat6 restart
  EOH
  not_if "test `stat -c %U #{node['dspace']['root']}/server/config/dspace.fcfg` = tomcat6"
end