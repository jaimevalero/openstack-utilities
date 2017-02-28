# This script calls the create csv in an clearer way
# 
# Usage: EG
# 
# ./Createcsv.sh  nova image-list
#
# Create a csv file call nova_image_list.csv with the results


FICHERO_TRAZA=/var/log/$0.log
MYSQL_CHAIN="mysql  -u ${MYSQL_USER} -p${MYSQL_PASS} -h${MYSQL_HOSTNAME} ${MYSQL_DATABASE} "
PARAMETER_LIST=./parameter-list
PARAMETER=""
MY_PARAM=""
HEADER=""
MAX_HEADER_LENGTH=0

USAGE_WINDOW=400

MostrarLog( )
{
         echo [`basename $0`] [`date +'%Y_%m_%d %H:%M:%S'`] [$$] [${FUNCNAME[1]}] $@  | /usr/bin/tee -a $FICHERO_TRAZA
}



GetIntervalDates( ) 
{
for i in $(seq $USAGE_WINDOW)
do
  ayer=`expr $i + 1`
  echo " --start "`date --date "$ayer day ago" +'%Y-%m-%d'`" --end "` date --date "$i day ago" +'%Y-%m-%d'` 
done

}

# Add a row with the date to a csv column
AddDateColumn( )
{
  MY_FILE=$1
  TODAY_FILE=/tmp/today_file
  MY_DATE=`date +'%Y-%m-%d'`
  TODAY_FILE=/tmp/today_file
 
  MY_NUM_LINE=`cat $MY_FILE | wc -l`

  # First we add a file withe header = start_date and as lines as the argument file
  echo  " printf \"$MY_DATE\n%.0s\"  {1..$MY_NUM_LINE}" > kk-date
  # Replace first line to "start_date"
  chmod +x kk-date && ./kk-date |  sed '1 s/^.*$/start_date/g' > $TODAY_FILE

  # Merge two files
  paste -d',' $MY_FILE $TODAY_FILE >  ${MY_FILE}.tmp
  cp -f  $MY_FILE.tmp  $MY_FILE

  # Remove temp files
  rm -f kk-date $MY_FILE.tmp

}

# Fix Metrics for graphite
FixRx( )
{
  MY_FILE=$1
  sed -i "s/_rx\,/_rx_traffic\,/g"  $MY_FILE
  sed -i "s/_tx\,/_tx_traffic\,/g"  $MY_FILE
}

FixForSpecialParameters( )
{
# Extract list of parameter from the parameter name
case $PARAMETER in
   subnet)  continue ;;
   instance) AddDateColumn ./spool/$FILE_NAME.csv;FixRx ./spool/$FILE_NAME.csv  ;continue;;
   tenant_id) continue ;;
   tenant|tenant_name) continue ;; 
   hypervisor_id)   continue ;; 
   intervalo_date) sed -i 's/--start //g' ./spool/$FILE_NAME.csv ; sed -i 's/ --end /,/g' ./spool/$FILE_NAME.csv ; sed -i 's/intervalo_date/start_date,end_date/g' ./spool/$FILE_NAME.csv  ;;
   hypervisor|hypervisor_name) continue ;; 
   *) continue ;; 
esac


}

GetParameterList( )
{


# Get parameter to be replaced
PARAMETER=` echo $@ | cut -d\> -f1 | cut -d\< -f2`

FILE_NAME=`echo $@ | sed -e 's/ --insecure//g' | grep -o -i -e '[A-Z]*' |  grep -o -i -e '[0-9]*' -e '[A-Z]*' | sed ':a;N;$!ba;s/\n/_/g' |sed -e 's/statistics//g' | sed -e 's/meter//g' | sed -e 's/\(_\)*/\1/g' |  sed -e 's/sample_list//g' | sed -e 's/__/_/g'  |cut -c1-25 `

MostrarLog All arguments=$@
MostrarLog PARAMETER=$PARAMETER
MostrarLog MYSQL_CHAIN=$MYSQL_CHAIN

# Extract list of parameter from the parameter name
case $PARAMETER in
   subnet)             echo " $MYSQL_CHAIN -e \" SELECT id   AS QUITAR from neutron_net_list       \" | sort -du |grep -v QUITAR > $PARAMETER_LIST  " > ./kk-exec ;;
   instance)           echo " $MYSQL_CHAIN -e \" SELECT id   AS QUITAR from nova_list_all_tenants  \" | sort -du |grep -v QUITAR > $PARAMETER_LIST  " > ./kk-exec ;;
   tenant_id)          
             echo " $MYSQL_CHAIN -e \" SELECT id   AS QUITAR from keystone_tenant_list   \" | grep -v QUITAR           > $PARAMETER_LIST  " > ./kk-exec 
             echo " $MYSQL_CHAIN -e \" SELECT id   AS QUITAR from project                \" | grep -v QUITAR           >> $PARAMETER_LIST  " > ./kk-exec ;;

   tenant|tenant_name) 
              echo " $MYSQL_CHAIN -e \" SELECT name AS QUITAR from keystone_tenant_list   \" | grep -v QUITAR           > $PARAMETER_LIST "  > ./kk-exec 
              echo " $MYSQL_CHAIN -e \" SELECT name   AS QUITAR from project   \" | grep -v QUITAR           >> $PARAMETER_LIST  " > ./kk-exec ;;
        

   hypervisor_id)      echo " $MYSQL_CHAIN -e \" SELECT ID   AS QUITAR from nova_hypervisor_list   \" | grep -v QUITAR           > $PARAMETER_LIST "  > ./kk-exec ;;
   intervalo_date) GetIntervalDates  > $PARAMETER_LIST ;;
   hypervisor|hypervisor_name) echo " $MYSQL_CHAIN -e \" SELECT Hypervisorhostname AS QUITAR from nova_hypervisor_list \" | grep -v QUITAR > $PARAMETER_LIST"  > ./kk-exec  ;;
   today) echo ">"`date --date "20 day ago" +'%Y-%m-%d'`"T00:00" > $PARAMETER_LIST;;
   volume_id) echo " $MYSQL_CHAIN -e \" SELECT ID AS QUITAR from cinder_list_all_tenants  \" | grep -v QUITAR > $PARAMETER_LIST"  > ./kk-exec  ;;
   *) echo "Sorry, Unknown parameter $PARAMETER ";;
esac

[ -f kk-exec ] && chmod +x kk-exec ; ./kk-exec ; rm -f ./kk-exec 2>/dev/null

MostrarLog PARAMETER_LIST: `cat $PARAMETER_LIST| wc -l`" filas. "`cat $PARAMETER_LIST`
}

# REmove the header of a csv
QuitarCabecera( )
{
MY_FILE=$1
NUM_LINES=`cat $MY_FILE | grep \, | wc -l`
MostrarLog NUM_LINES=$NUM_LINES
MostrarLog Contenidos $MY_FILE

if [ $NUM_LINES -ne 0 ] 
then
  # Skip not responses
  HEADER=`cat $MY_FILE | head -1`
  cat $MY_FILE  | tail -`expr $NUM_LINES - 1` > $MY_FILE.temp
  cp -f $MY_FILE.temp $MY_FILE
  rm -f $MY_FILE.temp
fi
MostrarLog HEADER=$HEADER
}

# Añade la cabecera al fichero final
AnyadirCabecera( )
{
echo ${HEADER},${PARAMETER} | tr '-' '_' > $1.temp

cat $1 >> $1.temp
cp -rf $1.temp $1
rm -f $1.temp
MostrarLog Cabecera de $1:` head -1 $1`
}

Execute( )
{
 COMMAND=$@

 # Create file to expand the shells and execute it
  echo "$COMMAND 2>/dev/null"> kk_exec && chmod +x kk_exec && ./kk_exec | grep -v :$ > $FILE_NAME

 rm -f ./kk_exec 

 # Generamos un fichero para este tenant, quitamos la cabecera del csv, añadimos el tenant, etc
  MostrarLog "Executing: ${@} to file: $FILE_NAME"
  ./Generatecsv.sh $FILE_NAME  > $FILE_NAME.temp 2>/dev/null

 # Detect empty response, to skip it
  if [ `cat $FILE_NAME.temp | grep "," | wc -l  ` -eq 0  ] 
  then
    MostrarLog "Detectada respuesta vacia para: $COMMAND" 
  else
    QuitarCabecera $FILE_NAME.temp
    sed -i "s/$/,$MY_PARAM/g" $FILE_NAME.temp
    cat $FILE_NAME.temp >> ./spool/$FILE_NAME.csv
    MostrarLog "Fichero $FILE_NAME.temp  añade" ` cat $FILE_NAME.temp  | wc -l` "registros a ./spool/$FILE_NAME.csv"
    rm -f $FILE_NAME.temp $FILE_NAME
  fi

}



GetParameterList "${@}"

# Pattch for project table
cat  $PARAMETER_LIST | sort -du >  $PARAMETER_LIST.temp
mv -f $PARAMETER_LIST.temp $PARAMETER_LIST

while read MY_PARAM 
do
  COMMAND_ITERATOR=`echo ${@}| sed -e "s/<$PARAMETER>/$MY_PARAM/g" `
  #MostrarLog "Executing :::::::${COMMAND_ITERATOR}:::::::"
  Execute "${COMMAND_ITERATOR}"
done< $PARAMETER_LIST

MostrarLog Resultados: Generado el fichero ./spool/$FILE_NAME.csv con `cat ./spool/$FILE_NAME.csv | wc -l` registros
AnyadirCabecera ./spool/$FILE_NAME.csv

FixForSpecialParameters

rm -f $PARAMETER_LIST 

