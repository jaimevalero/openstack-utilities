
COMMANDS_FILE=commands.sh
PHP_SCRIPT=csv_import.php
FICHERO_TRAZA=/var/log/`basename $0`.log
MYSQL_CHAIN=""

_DEBUG="yes"
function DEBUG()
{
 [ "$_DEBUG" == "yes" ] &&  $@
}

#######################################################
#
# Funcion MostrarLog
#
# Saca por log el texto pasado por argumento
#
#######################################################


MostrarLog( )
{
  if [ ` echo ${FUNCNAME[1]} | grep DEBUG | wc -l ` -eq 1 ]
  then
    echo [`basename $0`] [`date +'%Y_%m_%d %H:%M:%S'`] [$$] [${FUNCNAME[2]}] [Debug] $@  | /usr/bin/tee -a $FICHERO_TRAZA
  else
    echo [`basename $0`] [`date +'%Y_%m_%d %H:%M:%S'`] [$$] [${FUNCNAME[1]}] $@  | /usr/bin/tee -a $FICHERO_TRAZA
  fi
}
# Check if a tabla has results
CheckTable( )
{
#  DEBUG MostrarLog $1
  MY_TABLA=$1
  echo " $MYSQL_CHAIN -e ' SELECT COUNT(1) AS QUITARQUITAR from $MYSQL_DATABASE.$MY_TABLA  '  " > kkinsertarsnap
  chmod +x kkinsertarsnap
  SALIDA=` ./kkinsertarsnap | grep -v QUITAR | awk '{ print $1 }' `
  rm  -f ./kkinsertarsnap 2>/dev/null
  # TODO check wether a table exists
  MostrarLog Resultados: Insert contra la tabla $MYSQL_DATABASE.$MY_TABLA, $SALIDA

}

InsertTable( )
{
#  DEBUG MostrarLog $1
  MY_TABLA=`echo $1 | cut -d\. -f1`

  MostrarLog php ${PHP_SCRIPT} spool/$MY_TABLA.csv $MY_TABLA $MYSQL_DATABASE $MYSQL_USER $MYSQL_PASS $MYSQL_HOSTNAME 

  php ${PHP_SCRIPT} spool/$MY_TABLA.csv $MY_TABLA $MYSQL_DATABASE $MYSQL_USER $MYSQL_PASS $MYSQL_HOSTNAME 2>/dev/null 1>/dev/null

  CheckTable $MY_TABLA
}
# Drop table
DropTable( )
{
#  DEBUG MostrarLog $1
  MY_TABLA=$1
  DEBUG MostrarLog Borrando Tabla $MY_TABLA
  $MYSQL_CHAIN -e " DROP TABLE IF EXISTS  $MYSQL_DATABASE.$MY_TABLA" 2>/dev/null 1>/dev/null

}


Load_Data( )
{
# Load Into DB
for TABLA in `  ls -1 spool/ | cut -d\. -f1 `
do

  MostrarLog "Loading table: $MYSQL_DATABASE.$TABLA"
  DropTable $TABLA
  InsertTable $TABLA
done 
}


Generate_With_Arguments_Data( )
{
while read line
do

  # Skip comments
  [ ` echo $line | grep \# | wc -l` -eq 1 ] && continue

  # Skip commands with arguments
  [ ` echo $line | grep '>' | wc -l` -eq 0 ] && continue

  DEBUG MostrarLog $line

 ./Createcsv_arguments.sh "$line"

done < $COMMANDS_FILE
}


Generate_Without_Arguments_Data( )
{
DEBUG MostrarLog 

while read line
do
  # Skip comments
  [ ` echo $line | grep \# | wc -l` -eq 1 ] && continue

  # Skip commands with arguments
  [ ` echo $line | grep \> | wc -l` -eq 1 ] && continue

 ./Createcsv.sh "$line"

done < $COMMANDS_FILE
}

CleanSpool( )
{
rm -f spool/*

}
GetWorkingPath( )
{
  # GetWorking Path
  FULL_SCRIPT_PATH=`readlink -f $0`
  WORKING_PATH=`dirname $FULL_SCRIPT_PATH`
  cd $WORKING_PATH 2>/dev/null
}
PreWork( )
{
PROFILE=$1

# Assign default profile if unset
[ ! -f $PROFILE ] && PROFILE='.credentials'
[ ${#PROFILE} -eq 0 ] && PROFILE='.credentials'

GetWorkingPath


# Load profile
[ ! -f $PROFILE ] && MostrarLog "Error: $PROFILE file does not exist" && exit
MostrarLog INICIO: `basename $0` con profile $PROFILE
source $PROFILE
source $KEYSTONE_FILE

[ ! -d spool  ] && mkdir spool
MYSQL_CHAIN="mysql  -u ${MYSQL_USER} -p${MYSQL_PASS} -h${MYSQL_HOSTNAME} "
$MYSQL_CHAIN -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE " 

CleanSpool
}
PreWork $1

# First we load commands without arguments, needed to generate commands that need arguments like <tenant_id>
Generate_Without_Arguments_Data
Load_Data

# Clear enviroment
CleanSpool
 
Generate_With_Arguments_Data
Load_Data
