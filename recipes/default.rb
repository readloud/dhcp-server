#
# Cookbook Name:: dhcp3-server
# Recipe:: default
#
# Copyright 2012, CloudShare, Inc.
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

zones = data_bag_item(node.chef_environment, 'zones')
zone = zones['zones'][node['dhcp3']['domain']]
master_nameserver = search(:node, "fqdn:#{zone['master_nameserver']['name']}")[0]

package "dhcp3-server" do
    action :install
    version "3.1.3-2ubuntu3.4"
end

service "dhcp3-server" do
    supports :restart => true, :start => true
    action :enable
end

template "#{node['dhcp3']['conf_dir']}/dhcpd.conf" do
    source "dhcpd.conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables ({
        :rndc_key => master_nameserver['bind9']['rndc_key'],
        :master_nameserver => master_nameserver['ipaddress'],
        :ttl => zone['dhcp']['ttl'],
        :lease_time => zone['dhcp']['lease-time'],
        :max_lease_time => zone['dhcp']['max-lease-time'],
        :domain => node['dhcp3']['domain'],
        :nameservers => zone['nameservers'],
        :authoritative => true,
        :subnet => node['dhcp3']['subnets'][node['dhcp3']['subnet']]
    })
    notifies :restart, resources(:service => 'dhcp3-server')
end

service "dhcp3-server" do
    action :start
end
