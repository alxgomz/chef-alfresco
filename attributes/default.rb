##########################
### Default's defaults :-)
##########################

default['alfresco']['default_hostname'] = node['fqdn']
#default['alfresco']['default_hostname'] = "localhost"
default['alfresco']['default_port']     = "8080"
default['alfresco']['default_portssl']  = "8443"
default['alfresco']['default_protocol'] = "http"

# Artifact Deployer attributes - Artifact coordinates defaults used in sub-recipes
default['alfresco']['groupId'] = "org.alfresco"
default['alfresco']['version'] = "4.2.f"
default["alfresco"]["start_service"] = true

default['alfresco']['allinone'] = false
allinone = node['alfresco']['allinone']
if allinone == true
  default['artifacts']['alfresco']['enabled']       = true
  default['artifacts']['alfresco-mmt']['enabled']   = true
  default['artifacts']['alfresco-spp']['enabled']   = true
  default['artifacts']['mysqlconnector']['enabled'] = true
  default['artifacts']['classes']['enabled']        = true
  default['artifacts']['share']['enabled']          = true
  default['artifacts']['solr']['enabled']           = true
  default['artifacts']['solrhome']['enabled']       = true
else
  default['artifacts']['alfresco']['enabled']       = false
  default['artifacts']['alfresco-mmt']['enabled']   = false
  default['artifacts']['alfresco-spp']['enabled']   = false
  default['artifacts']['mysqlconnector']['enabled'] = false
  default['artifacts']['classes']['enabled']        = false
  default['artifacts']['share']['enabled']          = false
  default['artifacts']['solr']['enabled']           = false
  default['artifacts']['solrhome']['enabled']       = false
end

# Important Alfresco and Solr global properties
default['alfresco']['properties']['dir.root']           = "#{default['tomcat']['base']}/alf_data"
default['alfresco']['solrproperties']['data.dir.root']  = "#{node['alfresco']['properties']['dir.root']}/solrhome"

# Tomcat defaults
node.default["tomcat"]["start_service"]       = node["alfresco"]["start_service"]
node.default["tomcat"]["files_cookbook"]      = "alfresco"
node.default["tomcat"]["deploy_manager_apps"] = false
node.default["tomcat"]["jvm_memory"]          = "-Xmx1500M -XX:MaxPermSize=256M"
node.default["tomcat"]["java_options"]        = "#{node['tomcat']['jvm_memory']} -Djava.rmi.server.hostname=#{node['alfresco']['default_hostname']} -Dsolr.solr.home=#{node['alfresco']['solrproperties']['data.dir.root']} -Dcom.sun.management.jmxremote=true -Dsun.security.ssl.allowUnsafeRenegotiation=true"

# Java defaults
node.default["java"]["default"]                                 = true
node.default["java"]["accept_license_agreement"]                = true
node.default["java"]["install_flavor"]                          = "oracle"
node.default["java"]["jdk_version"]                             = "7"
node.default["java"]["oracle"]['accept_oracle_download_terms']  = true

# Choose whether to restart services or not (i.e. Docker would fail if any service attempts to start during provisioning)
version = node["tomcat"]["base_version"]
start_service = node["alfresco"]["start_service"]
if start_service == false
  default['alfresco']['restart_services'] = []
  default['alfresco']['restart_action']   = "nothing"
elsif platform?("centos") and version == 7
  default['alfresco']['restart_services'] = ["tomcat"]
  default['alfresco']['restart_action']   = "start"
else
  default['alfresco']['restart_services'] = ["tomcat7"]
  default['alfresco']['restart_action']   = "restart"
end

# Logging defaults used by artifact-deployer configurations, see repo_config and solr_config defaults
default['logging']['log4j.rootLogger']                                = "error, Console, File"
default['logging']['log4j.appender.Console']                          = "org.apache.log4j.ConsoleAppender"
default['logging']['log4j.appender.Console.layout']                   = "org.apache.log4j.PatternLayout"
default['logging']['log4j.appender.Console.layout.ConversionPattern'] = "%d{ISO8601} %x %-5p [%c{3}] [%t] %m%n"
default['logging']['log4j.appender.File']                             = "org.apache.log4j.DailyRollingFileAppender"
default['logging']['log4j.appender.File.Append']                      = "true"
default['logging']['log4j.appender.File.DatePattern']                 = "'.'yyyy-MM-dd"
default['logging']['log4j.appender.File.layout']                      = "org.apache.log4j.PatternLayout"
default['logging']['log4j.appender.File.layout.ConversionPattern']    = "%d{ABSOLUTE} %-5p [%c] %m%n"

######################################################
### alfresco-global.properties used across all recipes
######################################################

#JMX
default['alfresco']['properties']['monitor.rmi.services.port']  = 50508

#Database
default['alfresco']['properties']['db.driver']          = 'org.gjt.mm.mysql.Driver'
default['alfresco']['properties']['db.username']        = 'alfresco'
default['alfresco']['properties']['db.password']        = 'alfresco'

#Additional DB params
default['alfresco']['properties']['db.prefix']          = 'mysql'
default['alfresco']['properties']['db.host']            = node['alfresco']['default_hostname']
default['alfresco']['properties']['db.port']            = 3306
default['alfresco']['properties']['db.dbname']          = 'alfresco'
default['alfresco']['properties']['db.params']          = 'useUnicode=yes&characterEncoding=UTF-8'

#Derived DB param
default['alfresco']['properties']['db.url']             = "jdbc:#{node['alfresco']['properties']['db.prefix']}://#{node['alfresco']['properties']['db.host']}/#{node['alfresco']['properties']['db.dbname']}?#{node['alfresco']['properties']['db.params']}"

#Alfresco URL
default['alfresco']['properties']['hostname.public']    = node['alfresco']['default_hostname']

default['alfresco']['properties']['alfresco.context']   = '/alfresco'
default['alfresco']['properties']['alfresco.host']      = node['alfresco']['default_hostname']
default['alfresco']['properties']['alfresco.port']      = default['alfresco']['default_port']
default['alfresco']['properties']['alfresco.port.ssl']  = default['alfresco']['default_portssl']
default['alfresco']['properties']['alfresco.protocol']  = default['alfresco']['default_protocol']

#Share URL
default['alfresco']['properties']['share.context']      = '/share'
default['alfresco']['properties']['share.host']         = node['alfresco']['default_hostname']
default['alfresco']['properties']['share.port']         = default['alfresco']['default_port']
default['alfresco']['properties']['share.protocol']     = default['alfresco']['default_protocol']

#Solr URL
default['alfresco']['properties']['solr.host']          = node['alfresco']['default_hostname']
default['alfresco']['properties']['solr.port']          = default['alfresco']['default_port']
default['alfresco']['properties']['solr.port.ssl']      = default['alfresco']['default_portssl']
default['alfresco']['properties']['solr.secureComms']   = 'https'

# SSL
default['artifacts']['keystore']['groupId']           = "org.alfresco"
default['artifacts']['keystore']['artifactId']        = "alfresco-repository"
default['artifacts']['keystore']['version']           = node['alfresco']['version']
default['artifacts']['keystore']['destination']       = node['alfresco']['properties']['dir.root']
default['artifacts']['keystore']['subfolder']         = "alfresco/keystore/\*"
default['artifacts']['keystore']['owner']             = node['tomcat']['user']
default['artifacts']['keystore']['unzip']             = true

if node['alfresco']['version'].start_with?("4.3") || node['alfresco']['version'].start_with?("5")
  default['alfresco']['properties']['dir.keystore']     = "#{node['alfresco']['properties']['dir.root']}/keystore/alfresco/keystore"
  default['artifacts']['keystore']['enabled']           = true
else
  default['alfresco']['properties']['dir.keystore']     = "#{node['alfresco']['solrproperties']['data.dir.root']}/alf_data/keystore"
  default['artifacts']['keystore']['enabled']           = false
end

##############################################
### Tomcat Configuration for Alfresco keystore
##############################################
default["alfresco"]["keystore_file"]        = "#{node['alfresco']['properties']['dir.keystore']}/ssl.keystore"
default["alfresco"]["keystore_password"]    = "kT9X6oe68t"
default["alfresco"]["keystore_type"]        = "JCEKS"
default["alfresco"]["truststore_file"]      = "#{node['alfresco']['properties']['dir.keystore']}/ssl.truststore"
default["alfresco"]["truststore_password"]  = "kT9X6oe68t"
default["alfresco"]["truststore_type"]      = "JCEKS"

#################################
### Default recipe configurations
#################################

# Additional Tomcat paths
default['alfresco']['bin']                = "#{default['tomcat']['home']}/bin"
default['alfresco']['shared']             = "#{default['tomcat']['base']}/shared"
default['alfresco']['amps_folder']        = "#{default['tomcat']['base']}/amps"
default['alfresco']['amps_share_folder']  = "#{default['tomcat']['base']}/amps_share"

# DB params shared between client and server
default['alfresco']['db']['server_root_password']   = default['mysql']['server_root_password']
default['alfresco']['db']['root_user']              = "root"
default['alfresco']['db']['repo_hosts']             = ["%"]

# Enable iptables alfresco-ports
default['alfresco']['iptables'] = true
