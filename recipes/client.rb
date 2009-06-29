#
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Joshua Sierles <joshua@37signals.com>
# Cookbook Name:: chef
# Recipe:: client
#
# Copyright 2008-2009, Opscode, Inc
# Copyright 2009, 37signals
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

client_log = node[:chef][:client_log] == "STDOUT" ? "STDOUT" : node[:chef][:client_log]

# no runit here!
if ! platform?("centos","redhat")
  include_recipe "runit"
end

if platform?("centos","redhat") and dist_only?
  package "rubygem-chef"
else
  gem_package "chef" do
    version node[:chef][:client_version]
  end
end

group "chef" do
  gid 8000
end

user "chef" do
  comment "Chef user"
  gid "chef"
  uid 8000
  home node[:chef][:path]
  supports :manage_home => false
  shell "/bin/bash"
end

if platform?("centos","redhat") and dist_only?
  template "/etc/init.d/chef-client" do
    owner "chef"
    mode 0755
    source "chef-client.init.erb"
    action :create
    backup false 
  end
end


directory "/etc/chef" do
  owner "chef"
  group "chef"
  mode "775"
end

directory node[:chef][:path] do
  owner "chef"
  group "chef"
  mode "775"
end

directory "/var/log/chef" do
  owner "chef"
  group "chef"
  mode "775"
end

template "/etc/chef/client.rb" do
  source "client.rb.erb"
  owner "chef"
  group "chef"
  mode "644"
  variables(:client_log => client_log)
end

directory node[:chef][:run_path] do
  owner "chef"
  group "chef"
  mode "755"
end

execute "Register client node with Chef Server" do
  command "/usr/bin/env chef-client -t \`cat /etc/chef/validation_token\`"
  only_if { File.exists?("/etc/chef/validation_token") }
  not_if  { File.exists?("#{node[:chef][:path]}/cache/registration") }
end

execute "Remove the validation token" do
  command "rm /etc/chef/validation_token"
  only_if { File.exists?("/etc/chef/validation_token") }
            # File.exists?("#{node[:chef][:path]}/cache/registration") }
end

if platform?("centos","redhat") and dist_only?
  service "chef-client" do
    supports [ :restart, :reload, :status ]
    action [ :enable, :start ]
  end
else
  runit_service "chef-client"
end
