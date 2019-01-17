# -*- encoding: utf-8 -*-
#
# Cookbook Name:: wazuh-elastic
# Recipe:: elasticsearch_install
#
######################################################

package 'elasticsearch' do
    version node['wazuh-elastic']['elastic_stack_version']
end

half = ((node['memory']['total'].to_i * 0.5).floor / 1024)

node.default['wazuh_elastic']['memmory'] = (half > 30_500 ? '30500m' : "#{half}m")

template '/etc/elasticsearch/elasticsearch.yml' do
  source 'elasticsearch.yml.erb'
  owner 'root'
  group 'elasticsearch'
  mode '0660'
  variables({hostname: node['hostname'],
            clustername: node['wazuh-elastic']['elasticsearch_cluster_name'],
            ip:  node['wazuh-elastic']['elasticsearch_ip']})
  notifies :restart, 'service[elasticsearch]', :delayed
end

template '/etc/elasticsearch/jvm.options' do
  source 'jvm.options.erb'
  owner 'root'
  group 'elasticsearch'
  mode '0660'
  variables({memmory: node['wazuh_elastic']['memmory']})
  notifies :restart, 'service[elasticsearch]', :delayed
end

bash 'insert_line_limits.conf' do
  code <<-EOH
  echo "elasticsearch - nofile  65535" >> /etc/security/limits.conf
  echo "elasticsearch - memlock unlimited" >> /etc/security/limits.conf
  EOH
  not_if "grep -q elasticsearch /etc/security/limits.conf"
  notifies :restart, 'service[elasticsearch]', :immediately
end

ruby_block 'wait for elasticsearch' do
  block do
    loop { break if (TCPSocket.open("#{node['wazuh-elastic']['elasticsearch_ip']}",node['wazuh-elastic']['elasticsearch_port']) rescue nil); puts "Waiting elasticsearch...."; sleep 1 }
  end
end

execute 'Elasticsearch_template' do
  command "cat #{Chef::Config['cookbook_path']}/wazuh_elastic/files/default/elasticsearch_template.json | curl -XPUT 'http://localhost:9200/_template/wazuh' -H 'Content-Type: application/json' -d @-"
  action :run
end

service 'elasticsearch' do
  action [:enable, :start]
end
