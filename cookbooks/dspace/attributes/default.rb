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

default['dspace']['dspace_version'] = "1.6.2"
default['dspace']['install_tmp'] = "/home/dspace/tmp"
default['dspace']['dspace_dir'] = "/home/dspace/dspace"
default['dspace']['dspace_hostname'] = "dspace.myu.edu"
default['dspace']['dspace_baseUrl'] = "https://dspace.myu.edu"
default['dspace']['dspace_url'] = "https://dspace.myu.edu"
default['dspace']['dspace_name'] = "Chef DSpace Repository"
default['dspace']['db_name'] = "postgres"
default['dspace']['db_driver'] = "org.postgresql.Driver"
default['dspace']['db_url'] = "jdbc:postgresql://localhost:5432/dspace"
default['dspace']['db_username'] = "dspace"
default['dspace']['db_password'] = "dspace"
default['dspace']['db_postgresql_name'] = "dspace"
default['dspace']['db_postgresql_host'] = "localhost"
default['dspace']['db_postgresql_port'] = "5432"
default['dspace']['mail_server'] = "smtp.myu.edu"
default['dspace']['mail_from_address'] = "no-reply@illinois.edu"
default['dspace']['feedback_recipient'] = "no-reply@illinois.edu"
default['dspace']['mail_admin'] = "no-reply@illinois.edu"
default['dspace']['mail_server_disabled'] = "true"
default['dspace']['authentication_method'] = "org.dspace.authenticate.PasswordAuthentication"
default['dspace']['solr_log_server'] = "http://localhost:8080/solr/statistics"
default['dspace']['solr_authority_server'] = "http://localhost:8080/solr/authority"
default['dspace']['xmlui_google_analytics_key'] = "UA-xxxxxx-x"
default['dspace']['handle_prefix'] = "123456789"