# This script calls the create csv in an clearer way
# 
# Usage: EG
# 
# ./Createcsv.sh  nova image-list
#
# Create a csv file call nova_image_list.csv with the results

#source .credentials
#source $KEYSTONE_FILE

FICHERO_TRAZA=/var/log/$0.log
MYSQL_CHAIN="mysql  -u ${MYSQL_USER} -p${MYSQL_PASS} -h${MYSQL_HOSTNAME} ${MYSQL_DATABASE} "
PARAMETER_LIST=""
PARAMETER=""
MY_PARAM=""
HEADER=""
MostrarLog( )
{
         echo [`basename $0`] [`date +'%Y_%m_%d %H:%M:%S'`] [$$] [${FUNCNAME[1]}] $@  | /usr/bin/tee -a $FICHERO_TRAZA
}

GetParameterList( )
{


# Get parameter to be replaced
PARAMETER=` echo $@ | cut -d\> -f1 | cut -d\< -f2`

FILE_NAME=`echo $@ | grep -o -i -e '[A-Z]*' |  grep -o -i -e '[0-9]*' -e '[A-Z]*' | sed ':a;N;$!ba;s/\n/_/g'  | cut -c1-25 `

MostrarLog $PARAMETER

# Extract list of parameter from the parameter name
case $PARAMETER in
   tenant_id) PARAMETER_LIST=`$MYSQL_CHAIN -e " SELECT id AS QUITAR from keystone_tenant_list  " | grep -v QUITAR  ` ;;
   tenant|tenant_name) PARAMETER_LIST=`$MYSQL_CHAIN -e " SELECT name AS QUITAR from keystone_tenant_list " | grep -v QUITAR  ` ;;
   hypervisor_id) PARAMETER_LIST=`$MYSQL_CHAIN -e " SELECT ID AS QUITAR from nova_hypervisor_list " | grep -v QUITAR  ` ;;
   hypervisor|hypervisor_name) PARAMETER_LIST=`$MYSQL_CHAIN -e " SELECT Hypervisorhostname AS QUITAR from nova_hypervisor_list " | grep -v QUITAR  ` ;;
   *) echo "Sorry, Unknown parameter $PARAMETER ";;
esac

MostrarLog PARAMETER_LIST=$PARAMETER_LIST

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
  ./Generatecsv.sh $FILE_NAME  > $FILE_NAME.temp
  QuitarCabecera $FILE_NAME.temp
  sed -i "s/$/,$MY_PARAM/g" $FILE_NAME.temp
  cat $FILE_NAME.temp >> ./spool/$FILE_NAME.csv
  rm -f $FILE_NAME.temp $FILE_NAME

  MostrarLog "Executing: ${@} to file: $FILE_NAME"

}



GetParameterList "${@}"

for MY_PARAM in $PARAMETER_LIST
do
  COMMAND_ITERATOR=`echo ${@}| sed -e "s/<$PARAMETER>/$MY_PARAM/g" `
  #MostrarLog "Executing :::::::${COMMAND_ITERATOR}:::::::"
  Execute "${COMMAND_ITERATOR}"

done

MostrarLog Resultados: Generado el fichero ./spool/$FILE_NAME.csv con `cat ./spool/$FILE_NAME.csv | wc -l` registros
AñadirCabecera ./spool/$FILE_NAME.csv
 

