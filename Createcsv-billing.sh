# This script calls the create csv in an clearer way
# 
# Usage: EG
# 
# ./Createcsv.sh  nova image-list
#
# Create a csv file call nova_image_list.csv with the results

source $1
#source $KEYSTONE_FILE

MY_TABLA="billing_temp"

FICHERO_TRAZA=/var/log/$0.log
MostrarLog( )
{
   echo [`basename $0`] [`date +'%Y_%m_%d %H:%M:%S'`] [$$] [${FUNCNAME[1]}] $@  | /usr/bin/tee -a $FICHERO_TRAZA
}

PostWork( )
{
  MostrarLog Generado el fichero ./spool-billing/$FILE.csv con `cat ./spool-billing/$FILE.csv | wc -l` registros
  rm -f $FILE
}

Accumulate_Data( )
{

export MYSQL_CHAIN2=" mysql -u$MYSQL_USER -p$MYSQL_PASS -h$MYSQL_HOSTNAME $MYSQL_DATABASE" 

# Drop and load data
$MYSQL_CHAIN2 -e " drop table $MY_TABLA"

# Load
PHP_SCRIPT=csv_import.php
php ${PHP_SCRIPT} ./spool-billing/$FILE.csv $MY_TABLA $MYSQL_DATABASE $MYSQL_USER $MYSQL_PASS $MYSQL_HOSTNAME #2>/dev/null 1>/dev/null


}

AddDate( )
{
   # Add Date
   FECHA_TEMP=`date +'%Y-%m-%d %H'`
   FECHA="${FECHA_TEMP}:00"
   sed -i "s/^/$FECHA,/g"  ./spool-billing/$FILE.csv
   sed -i "s/$FECHA,ID,Name,/date,ID,Name,/g" ./spool-billing/$FILE.csv

}

Execute( )
{
  COMMAND="nova image-list"

  # Create file to expand the shells and execute it
  FILE=`echo $COMMAND |  sed -e 's/ --insecure//g' |  grep -o -i -e '[A-Z]*' |  grep -o -i -e '[0-9]*' -e '[A-Z]*' | sed ':a;N;$!ba;s/\n/_/g'   | cut -c1-25 `
  FILE2="$FILE-$MYSQL_DATABASE"
  FILE=$FILE2
 
  MostrarLog "Executing: ${@} to file: $FILE"
  echo "$COMMAND 2>/dev/null"> kk_exec && chmod +x kk_exec && ./kk_exec | grep -v :$ > $FILE
  rm -f ./kk_exec 
  
  # Generate csv
  ./Generatecsv.sh $FILE > ./spool-billing/$FILE.csv
   wc -l  ./spool-billing/$FILE.csv
 
   # Add Date
   AddDate

   Accumulate_Data
}

Execute "${@}"

PostWork

