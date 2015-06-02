############################
# Metrics - CeiloMeter
############################
#ceilometer sample-list -m instance -q"timestamp<today>"
#ceilometer sample-list -m vcpus -q"timestamp<today>"
#ceilometer sample-list -m memory -q"timestamp<today>"
#ceilometer sample-list -m disk.ephemeral.size -q"timestamp<today>"
#ceilometer sample-list -m disk.root.size -q"timestamp<today>"
#
############################
# Block Storage - Cinder
############################
cinder list --all_tenants
cinder service-list
cinder show <volume_id>
cinder quota-usage <tenant_name>
############################
# Identify Service Keystone
############################
keystone ec2-credentials-list
keystone endpoint-list
keystone role-list
keystone service-list 
keystone tenant-list
keystone user-list 
keystone user-list --tenant <tenant_name>
############################
# Networking - Neutron
############################
neutron quota-list
neutron floatingip-list
neutron port-list
neutron net-external-list
############################
# Compute - Nova
############################
nova aggregate-list
nova flavor-list
nova floating-ip-list
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
nova show "<instance>"
nova usage-list <intervalo_date>
nova --os-tenant-name <tenant_name> list
