# This script calls the create csv in an clearer way
# 
# Usage: EG
# 
# ./Createcsv.sh  nova image-list
#
# Create a csv file call nova_image_list.csv with the results

source .credentials
KEYSTONE_FILE=/root/keystonerc_admin_ldap

source $KEYSTONE_FILE

Execute( )
{
COMMAND=$@
echo "Executing ------${@}------"

# Create file to expand the shells and execute it
FILE=`echo $COMMAND | grep -o -i -e '[A-Z]*' |  grep -o -i -e '[0-9]*' -e '[A-Z]*' | sed ':a;N;$!ba;s/\n/_/g'  | cut -c1-25 `
echo FILE *************$FILE*************
echo "$COMMAND 2>/dev/null"> kk_exec && chmod +x kk_exec && ./kk_exec | grep -v :$ > $FILE

rm -f ./kk_exec 

./Generatecsv.sh $FILE > ./spool/$FILE.csv
rm -f $FILE
}
echo " "
echo "Executing :::::::${@}:::::::"
Execute "${@}"

