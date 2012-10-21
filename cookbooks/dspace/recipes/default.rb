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

include_recipe "tomcat"
include_recipe "java"

include_recipe "ark::postgresql-connector"
include_recipe "database::postgresql"
include_recipe "tomcat::postgresqljar"

version_tag       = "dspace-#{node['dspace']['dspace_version']}"
source_base_dir   = "/home/dspace/tmp"
source_dir        = "#{source_base_dir}/#{version_tag}"
install_dir       = node['dspace']['dspace_home']

# create the dspace db user
postgresql_database_user node['dspace']['db_username'] do
  connection postgresql_connection
  password node['dspace']['db_password']
  action :create
end

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

# make the dspace directory
directory node['dspace']['dspace_dir'] do
  owner "#{node['tomcat']['user']}"
  group "#{node[:tomcat][:user]}"
  mode "0755"
  recursive true
  action :create
end


directory "#{source_base_dir}" do
  owner 'root'
  group 'root'
  mode 0755
  recursive true
end

##Create directory to store install scripts in
directory node['dspace']['install_tmp'] do
  owner "#{node['tomcat']['user']}"
  group "#{node[:tomcat][:user]}"
  mode "0755"
  action :create
end

# download dspace source and checkout specific version
execute "fetch dspace from GitHub" do
  command "git clone https://github.com/DSpace/DSpace.git #{source_dir} && cd #{source_dir} && git checkout #{version_tag}"
  not_if { FileTest.exists?(source_dir) }
end

##get dspace.cfg from template
template "#{source_dir}/dspace/config/dspace.cfg" do
  source "dspace.cfg.#{node['dspace']['version']}.erb"
  owner "#{node['tomcat']['user']}"
  group "#{node[:tomcat][:user]}"
  mode 0644
end

## install dspace
execute "compile_dspace" do
  command "cd #{source_dir}/dspace && mvn -Pall -DskipTests=true clean package"
  action :run
end
execute "build_dspace" do
  command "cd #{source_dir}/dspace/target/#{version_tag}-build.dir && ant fresh_install"
  action :run
  notifies :restart, "service[tomcat]"
end

## TODO: template tomcat/conf/server.xml => server.xml.erb and add the context for dspace modules xmlui, jspui, sword, oai

