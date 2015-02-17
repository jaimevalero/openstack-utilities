cinder list
cinder service-list
keystone ec2-credentials-list
keystone endpoint-list
keystone role-list
keystone service-list 
keystone tenant-list
keystone user-list 
neutron quota-list
nova aggregate-list
nova floating-ip-pool-list
nova host-list
nova hypervisor-stats
nova hypervisor-list
nova hypervisor-servers <hypervisor>
nova hypervisor-show <hypervisor>
nova image-list
nova list --all-tenants
nova net-list
nova quota-defaults
nova usage-list --end `date +'%Y-%m-%d'` --start `date --date "1 month ago" +'%Y-%m-%d'` 
cinder quota-usage <tenant_name>
keystone user-list --tenant <tenant_name>
