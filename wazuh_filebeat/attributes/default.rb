#
# Cookbook Name:: filebeat
# Attribute:: default
# Author:: Wazuh <info@pwazuh.com>
#
#
#
default['filebeat']['ssl_enabled'] = false
default['filebeat']['elastic_stack_version'] = '6.5.4'
default['filebeat']['package_name'] = 'filebeat'
default['filebeat']['service_name'] = 'filebeat'
default['filebeat']['logstash_servers'] = 'indexer.wazuh.com:5000'
default['filebeat']['timeout'] = 15
default['filebeat']['config_path'] = '/etc/filebeat/filebeat.yml'
default['filebeat']['certificate_authorities'] = '/etc/filebeat/logstash_certificate.crt'
default['filebeat']['certificate'] = '/etc/filebeat/logstash.crt'
default['filebeat']['key'] = '/etc/filebeat/logstash.key'
