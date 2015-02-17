#OpenStack2CSV.sh
# Conver the format returned from a openstack service query, into a csv file

# FROM
# 
# +-------------------+-------------+------------+
# | host_name         | service     | zone       |
# +-------------------+-------------+------------+
# | prod-test-02 | consoleauth | internal   |
# | prod-test--02 | cert        | internal   |
# | prod-test-02 | scheduler   | internal   |
# | prod-test-02 | console     | internal   |
# | prod-test-01 | console     | internal   |
# | prod-test-05 | compute     | availzone3 |
# +-------------------+-------------+------------+

# TO
#
# host_name,service,zone
# prod-test-02,consoleauth,internal
# prod-test-02,cert,internal
# prod-test-02,scheduler,internal
# prod-test-02,console,internal
# prod-test-01,console,internal
# prod-test-01,compute,availzone3

# Arguments:
#$1 -> Name of the file
[ ${#1} -eq 0 ] && echo ERROR. Missing Argument  && exit
[ ! -f $1 ] && echo ERROR. The file $1 does not exist.  && exit
FILE=$1

NUM_ROWS=

PreWork( )
{
  NUM_ROWS=`cat $FILE | wc -l`
}

ProcessHeader( )
{
 # Get Second line, and format it to get fields that will be the columns of the mysql
 # Get rid of reserver words like limit
  HEADER=` cat $FILE | head -2 | tail -1 |  sed -e 's/  *//g' | sed -e 's/^|//g' |  tr \| , | sed -e 's/,$//g'| tr '-' '_' | sed -e 's/Limit/Limite/g' `
  echo $HEADER
}


ProcessFile( )
{
ROW_LINES=`expr $NUM_ROWS - 3`
cat $FILE | tail -`expr $NUM_ROWS - 3` | head -`expr $NUM_ROWS - 4` > $FILE.tmp
while read line          
do          
  echo $line | tr ',' ' ' | sed -e 's/ \{0,\}| \{0,\}/,/g' |   sed -e 's/^,//g' |  sed -e 's/,$//g'
done<$FILE.tmp
}

PostWork( )
{
rm -f  $FILE.tmp
}

# MAIN
PreWork

ProcessHeader

ProcessFile

PostWork





