#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Cookbook Name:: rackspace_database
# Recipe:: master
#
# Copyright 2009-2010, Opscode, Inc.
# Copyright 2014, Rackspace, US Inc.
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
# This is potentially destructive to the nodes mysql password attributes, since
# we iterate over all the app databags. If this database server provides
# databases for multiple applications, the last app found in the databags
# will win out, so make sure the databags have the same passwords set for
# the root, repl, and debian-sys-maint users.
#

db_info = {}
if Chef::Config['solo']
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  search(:apps) do |app|
    (app['database_master_role'] & node.run_list.roles).each do |dbm_role|
      %w{ root repl debian }.each do |user|
        user_pw = app["mysql_#{user}_password"]
        if !user_pw.nil? && user_pw[node.chef_environment]
          Chef::Log.debug("Saving password for #{user} as node attribute node['mysql']['server_#{user}_password'")
          node.set['mysql']["server_#{user}_password"] = user_pw[node.chef_environment]
          node.save
        else
          log "A password for MySQL user #{user} was not found in DataBag 'apps' item '#{app["id"]}' for environment ' for #{node.chef_environment}'." do
            level :warn
          end
          log "A random password will be generated by the mysql cookbook and added as 'node.mysql.server_#{user}_password'. " \
          "Edit the DataBag item to ensure it is set correctly on new nodes" do
            level :warn
          end
        end
      end
      app['databases'].each do |env, db|
        db_info[env] = db
      end
    end
  end
end

include_recipe 'rackspace_mysql::server'

rootpw = node['rackspace_mysql']['server_root_password']
connection_info = { host: 'localhost', username: 'root', password: rootpw }

if Chef::Config['solo']
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else
  search(:apps) do |app|
    (app['database_master_role'] & node.run_list.roles).each do |dbm_role|
      app['databases'].each do |env, db|
        if env =~ /#{node.chef_environment}/
          mysql_database "create #{db['database']}" do
            database_name db['database']
            connection connection_info
            action :create
          end
          node_fqdn = node['fqdn']
          %W(% #{node_fqdn} localhost).each do |h|
            mysql_database_user db['username'] do
              connection connection_info
              password db['password']
              database_name db['database']
              host h
              action :grant
            end
          end
        end
      end
    end
  end
end
