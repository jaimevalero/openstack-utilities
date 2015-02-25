source $1

MYSQL_CHAIN="mysql  -u ${MYSQL_USER} -p${MYSQL_PASS} -h${MYSQL_HOSTNAME} --skip-column-names $MYSQL_DATABASE"
BASE_METRIC=stats.inventario.dSNManivela.mysql
FICHERO_TRAZA=/var/log/$0.log
#######################################################
#
# Funcion MostrarLog
#
# Saca por log el texto pasado por argumento
#
#######################################################
MostrarLog( )
{
    echo [`basename $0`] [`date +'%Y_%m_%d %H:%M:%S'`] [$$] [${FUNCNAME[1]}] $@  | /usr/bin/tee -a $FICHERO_TRAZA
}
GenerateMetric( )
{
  MostrarLog "Extract $1"
  METRIC=$1
  $MYSQL_CHAIN -e "select ID,'XXX',$METRIC, unix_timestamp(str_to_date(DATE,'%Y-%m-%d'))  from  ( SELECT initiative.id AS ID, COUNT(VM_VirtualMachine.VVMname) AS Servers ,SUM(VVMmemorySizeMB)*24 AS RAMMB_Hours ,SUM(VVMnumCpu)*24 AS CPUHours ,SUM(VM_VirtualMachine.VVMdiskMB)*24/1024 AS DiskGB_Hours, DATE FROM desarrollo.VM_VirtualMachine,inventario.vmlist,inventario.initiative, inventario.user WHERE  vmlist.vm = VM_VirtualMachine.VVMname AND vmlist.responsable = inventario.user.uid AND initiative.id = user.initiative AND VVMpowerState='poweredOn' GROUP BY id,DATE ) A   ;" > $METRIC.tmp

#######################################################
#
# Format query response to send it to graphite
# The query return lines as:
#
# 390 XXX 3 1424214000
#
# And we transform it into graphite syntax, as:
#
# stats.inventario.openstack.mysql.390.Servers 3 1423954800
#
#######################################################

# Put the base metric at the end of the line
sed  -i "s/^/${BASE_METRIC}\./g" $METRIC.tmp
# Replace tab for white space
sed -i 's/\t/ /g' $METRIC.tmp

# Replace separator character 
sed  -i "s/ XXX/\.$METRIC/g"  $METRIC.tmp

# Send to graphite
cat $METRIC.tmp | nc $GRAPHITE_SERVER $GRAPHITE_PORT
# rm -f $METRIC.tmp 
}

GenerateMetric Servers
GenerateMetric RAMMB_Hours
GenerateMetric CPUHours
GenerateMetric DiskGB_Hours
