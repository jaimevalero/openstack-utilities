source $1

MYSQL_CHAIN=
BASE_METRIC=
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
PreWork( )
{
  source $1
  MostrarLog Comienzo $0 $2
  if [ ` echo $2 | grep -i TENANT | wc -l ` -eq 1 ]
  then
    BASE_METRIC=${BASE_METRIC_OPENSTACK}
    SQL=${SQL_OPENSTACK} 
  else
    if [ ` echo $2 | grep -i VMWARE | wc -l ` -eq 1 ]
    then
      BASE_METRIC=${BASE_METRIC_VMWARE}
      SQL=${SQL_VMWARE} 
    else
      MostrarLog "ERROR, No Parameter TENANT/VMWARE detected"
    fi
  fi 
 MYSQL_CHAIN="mysql  -u ${MYSQL_USER} -p${MYSQL_PASS} -h${MYSQL_HOSTNAME} --skip-column-names $MYSQL_DATABASE"


}
 


GenerateMetric( )
{
  MostrarLog "Extract $1"
   
  METRIC=$1
  SQL2=`echo $SQL | sed -e "s/METRIC/$METRIC/g"`
 
   MostrarLog : Query \" $MYSQL_CHAIN -e "$SQL2" \"  
 
   $MYSQL_CHAIN -e "$SQL2" > $METRIC.tmp

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
MostrarLog "Generado Informe $METRIC: Primera Linea" `head -1 $METRIC.tmp`
cat $METRIC.tmp | nc $GRAPHITE_SERVER $GRAPHITE_PORT
MostrarLog "Enviadas: "`cat $METRIC.tmp | wc -l`" metricas de: $METRIC a $GRAPHITE_SERVER"

rm -f $METRIC.tmp 
}

PreWork $1 $2

GenerateMetric Servers
GenerateMetric RAMMB_Hours
GenerateMetric CPUHours
GenerateMetric DiskGB_Hours
