# This script calls the create csv in an clearer way
# 
# Usage: EG
# 
# ./Createcsv.sh  nova image-list
#
# Create a csv file call nova_image_list.csv with the results


#source $KEYSTONE_FILE

FICHERO_TRAZA=/var/log/$0.log
MostrarLog( )
{
   echo [`basename $0`] [`date +'%Y_%m_%d %H:%M:%S'`] [$$] [${FUNCNAME[1]}] $@  | /usr/bin/tee -a $FICHERO_TRAZA
}

PostWork( )
{
  MostrarLog Generado el fichero ./spool/$FILE.csv con `cat ./spool/$FILE.csv | wc -l` registros
  rm -f $FILE
}


Execute( )
{
  COMMAND=$@

  # Create file to expand the shells and execute it
  FILE=`echo $COMMAND | grep -o -i -e '[A-Z]*' |  grep -o -i -e '[0-9]*' -e '[A-Z]*' | sed ':a;N;$!ba;s/\n/_/g'  | cut -c1-25 `
  MostrarLog "Executing: ${@} to file: $FILE"

  echo "$COMMAND 2>/dev/null"> kk_exec && chmod +x kk_exec && ./kk_exec | grep -v :$ > $FILE

  rm -f ./kk_exec 

  ./Generatecsv.sh $FILE > ./spool/$FILE.csv

}

Execute "${@}"

PostWork

