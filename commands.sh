# CeiloMeter Metrics
ceilometer sample-list -m instance -q"timestamp<today>"
ceilometer sample-list -m vcpus -q"timestamp<today>"
ceilometer sample-list -m memory -q"timestamp<today>"
ceilometer sample-list -m disk.ephemeral.size -q"timestamp<today>"
ceilometer sample-list -m disk.root.size -q"timestamp<today>"
# Cinder
cinder list
cinder quota-usage <tenant_name>
cinder service-list
# KeyStone
keystone ec2-credentials-list
keystone endpoint-list
keystone role-list
keystone service-list 
keystone tenant-list
keystone user-list 
keystone user-list --tenant <tenant_name>
# Neutron
neutron quota-list
neutron floatingip-list
# Nova
nova aggregate-list
nova flavor-list
nova floating-ip-pool-list
nova diagnostics <instance>
nova host-list
nova hypervisor-stats
nova hypervisor-list
nova hypervisor-servers <hypervisor>
nova hypervisor-show <hypervisor>
nova image-list
nova list --all-tenants
nova net-list
nova quota-defaults
nova usage-list <intervalo_date>
nova --os-tenant-name <tenant_name> list
