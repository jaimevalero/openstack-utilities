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
cinder --insecure list --all_tenants
cinder --insecure service-list
cinder --insecure show <volume_id>
cinder --insecure quota-usage <tenant_name>
glance --insecure image-list
############################
# Identify Service Keystone
############################
keystone --insecure ec2-credentials-list
keystone --insecure endpoint-list
keystone --insecure role-list
keystone --insecure service-list 
keystone --insecure tenant-list
keystone --insecure user-list 
keystone --insecure user-list --tenant <tenant_name>
############################
# Networking - Neutron
############################
neutron --insecure floatingip-list
neutron --insecure net-external-list
neutron --insecure net-list
neutron --insecure port-list
neutron --insecure quota-list
neutron --insecure subnet-list
neutron --insecure show <subnet>
############################
# Compute - Nova
############################
nova --insecure aggregate-list
nova --insecure flavor-list
nova --insecure floating-ip-list
nova --insecure floating-ip-pool-list
nova --insecure diagnostics <instance>
nova --insecure host-list
nova --insecure hypervisor-stats
nova --insecure hypervisor-list
nova --insecure hypervisor-servers <hypervisor>
nova --insecure hypervisor-show <hypervisor>
nova --insecure image-list
nova --insecure list --all-tenants
nova --insecure net-list
nova --insecure quota-defaults
nova --insecure quota-show --tenant <tenant_name>
nova --insecure show "<instance>"
nova --insecure usage-list <intervalo_date>
nova --insecure --os-tenant-name <tenant_name> list
