# Task

## Nginx
There are two roles in this repository. _fw_ and _nginx_.

_nginx_ role will install and configure a Nginx server.

Within the task it is specified that cache storage size memory must be 2GB. It's not clear what "cache storage" refers to. There're three possibilites for that:  
1- Memory size which Nginx uses to keep cache keys
2- Storage size on disk to use for cached files
3- Mount 2GB of memory and use it for caching files


It's possible to do any of these by this role with setting vars:
1:
```yaml
## 10G Storage on disk
## 2G cache key memory size
## don't use memory for storage
nginx_cache_storage_max_size: 10g
nginx_cache_key_memory_size: 2000m
nginx_use_tempfs_for_cache: false
```
2:
```yaml
## 2G Storage on disk
## 250MB cache key memory size
## don't use memory for storage
nginx_cache_storage_max_size: 2g
nginx_cache_key_memory_size: 250m
nginx_use_tempfs_for_cache: false
```
3:
```yaml
## 2G Storage on disk
## 250m cache key memory size
## USE memory for storage
nginx_cache_storage_max_size: 2g
nginx_cache_key_memory_size: 250m
nginx_use_tempfs_for_cache: true
```


This role also could generate a self-sigend CA to generate TLS certificates for the webserver:
```yaml
## directory to keep certificates on the remote host
nginx_certs_dir: /etc/nginx/.certs

## enable ssl
nginx_enable_ssl: true

## if this option + nginx_enable_ssl are enabled, a CA and certificate signed by that CA is generated
nginx_create_selfsigned_cert: true

## common name of cert 
nginx_ssc_cn: cache.mydomain.com

## you don't need to include CN of certificate in SANs. it will be included by default
nginx_ssc_sans:
- cat.mydomain.com

## directory on controller node to save generated files related to PKI
nginx_ssc_dir: "{{ playbook_dir }}/pki"

## if self-signed certificate is enabled, it will be saved on these files
## otherwise you a key/cert pair on specified paths when nginx_enable_ssl is set to true
nginx_ssl_crt_path: "{{ playbook_dir }}/server.crt"
nginx_ssl_key_path: "{{ playbook_dir }}/server.pem"

## OPTIONAL
## diffie hellman 
# nginx_ssl_dhparam_path: '/path'

## trusted chain
# nginx_ssl_chain_path: '/path'
```
**variables**:
```yaml
## set it to true to install the latest version or update the installed package
nginx_package_update: false

nginx_cache_dir_path: /var/cache/nginx

## upstream application port (test.neshan.org:8080)
nginx_backend_port_number: 8080

nginx_local_dns_addr: 192.168.104.1
nginx_local_dns_ttl: 15s
nginx_local_dns_time_out: 3s

nginx_cache_storage_max_size: 2g
nginx_cache_key_memory_size: 250m
nginx_use_tempfs_for_cache: false

nginx_certs_dir: /etc/nginx/.certs
nginx_enable_ssl: false
nginx_create_selfsigned_cert: false
nginx_server_names: []
nginx_ssc_cn: ""
nginx_ssc_sans: []
nginx_ssc_dir: "{{ playbook_dir }}/pki"
# nginx_ssl_crt_path: '/path'
# nginx_ssl_key_path: '/path'
# nginx_ssl_dhparam_path: '/path'
# nginx_ssl_chain_path: '/path'

## path to access log file for this server
## error logs will be saved in the same file suffixed with .err
nginx_log_file_path: /var/log/nginx/cache-server.log
```
**tags**:
- nginx: install/config/PKI
- nginx_install
- nginx_config
- nginx_pki
- nginx_dns: config resolved for neshan.org domain to use private nameserver


## Firewall

_fw_ role configs websesrver firewall. As described within the task, Server has 2 NICs. One private/LAN network and communicates with a DNS and application server. Also remote ssh access is allowed on this interface. Another one is facing public/WAN network. On WAN side only inbound traffic on port 8099/tcp is allowed for the webserver.

It's mentioned in the task that webserver will communicate to the back-end application using hostname. Since the IPtables just resolve the domain on rule creation, it'll be a static IP in the rule. If back-end application ip changes, Nginx will not be able to communicate with the back-end. I allowed outbound traffic to tcp port 8099 on private CIDR. **This is vulnerable to DNS spoofing and make it possible to pivoting for an attacker(can be leveraged for reverse shell, downloading scripts/exploits/... and ...).**. It is set to log SYN packets to the back-end before allowing them to make early detection possible and usable for incident response.


**variables**:
```yaml
### ssh access
fw_ssh_access: true
fw_bastion_host_ip: 192.168.104.1
fw_private_interface: eth1

### dns server
fw_dns_protocol: udp
fw_dns_server_port_number: 53
fw_dns_server_address: 192.168.104.1

fw_upstream_app_port: 8099
```
**tags**:
- fw
