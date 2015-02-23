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

USAGE_WINDOW=365

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


FixForSpecialParameters( )
{
# Extract list of parameter from the parameter name
case $PARAMETER in
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

FILE_NAME=`echo $@ | grep -o -i -e '[A-Z]*' |  grep -o -i -e '[0-9]*' -e '[A-Z]*' | sed ':a;N;$!ba;s/\n/_/g'  | cut -c1-25 `

MostrarLog All arguments=$@
MostrarLog PARAMETER=$PARAMETER
MostrarLog MYSQL_CHAIN=$MYSQL_CHAIN

# Extract list of parameter from the parameter name
case $PARAMETER in
   tenant_id)          echo " $MYSQL_CHAIN -e \" SELECT id AS QUITAR from keystone_tenant_list  \" | grep -v QUITAR > $PARAMETER_LIST  " > ./kk-exec ;;
   tenant|tenant_name) echo " $MYSQL_CHAIN -e \" SELECT name AS QUITAR from keystone_tenant_list \" | grep -v QUITAR  > $PARAMETER_LIST " > ./kk-exec ;;
   hypervisor_id)      echo " $MYSQL_CHAIN -e \" SELECT ID AS QUITAR from nova_hypervisor_list \" | grep -v QUITAR  > $PARAMETER_LIST "   > ./kk-exec ;;
   intervalo_date) GetIntervalDates  > $PARAMETER_LIST ;;
   hypervisor|hypervisor_name) echo " $MYSQL_CHAIN -e \" SELECT Hypervisorhostname AS QUITAR from nova_hypervisor_list \" | grep -v QUITAR > $PARAMETER_LIST"  > ./kk-exec  ;;
   *) echo "Sorry, Unknown parameter $PARAMETER ";;
esac

[ -f kk-exec ] && chmod +x kk-exec ; ./kk-exec ; rm -f ./kk-exec 2>/dev/null

MostrarLog PARAMETER_LIST=`cat $PARAMETER_LIST`
}

# REmove the header of a csv
QuitarCabecera( )
{
MY_FILE=$1
NUM_LINES=`cat $MY_FILE | wc -l`
if [ $NUM_LINES -ne 0 ] 
then
  HEADER=`cat $MY_FILE | head -1`
  cat $MY_FILE  | tail -`expr $NUM_LINES - 1` > $MY_FILE.temp
  cp -f $MY_FILE.temp $MY_FILE
  rm -f $MY_FILE.temp
fi
MostrarLog HEADER=$HEADER
}

# Añade la cabecera al fichero final
AñadirCabecera( )
{
echo $HEADER,$PARAMETER | tr '-' '_' > $1.temp

cat $1 >> $1.temp
cp -rf $1.temp $1
rm -f $1.temp

}

Execute( )
{
 COMMAND=$@

 # Create file to expand the shells and execute it
  echo "$COMMAND 2>/dev/null"> kk_exec && chmod +x kk_exec && ./kk_exec | grep -v :$ > $FILE_NAME

 rm -f ./kk_exec 

 # Generamos un fichero para este tenant, quitamos la cabecera del csv, añadimos el tenant, etc
  MostrarLog "Executing: ${@} to file: $FILE_NAME"
  ./Generatecsv.sh $FILE_NAME  > $FILE_NAME.temp
  QuitarCabecera $FILE_NAME.temp
  sed -i "s/$/,$MY_PARAM/g" $FILE_NAME.temp
  cat $FILE_NAME.temp >> ./spool/$FILE_NAME.csv
  MostrarLog "Fichero $FILE_NAME.temp  añade" ` cat $FILE_NAME.temp  | wc -l` "registros a ./spool/$FILE_NAME.csv"
  rm -f $FILE_NAME.temp $FILE_NAME


}



GetParameterList "${@}"


while read MY_PARAM 
do
  COMMAND_ITERATOR=`echo ${@}| sed -e "s/<$PARAMETER>/$MY_PARAM/g" `
  #MostrarLog "Executing :::::::${COMMAND_ITERATOR}:::::::"
  Execute "${COMMAND_ITERATOR}"
done< $PARAMETER_LIST

MostrarLog Resultados: Generado el fichero ./spool/$FILE_NAME.csv con `cat ./spool/$FILE_NAME.csv | wc -l` registros
AñadirCabecera ./spool/$FILE_NAME.csv

FixForSpecialParameters

rm -f $PARAMETER_LIST 

