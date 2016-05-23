# openstack-utilities
Scripts to work with Open Stack in a friendlier way


## OpenStack2CSV.sh
Convert the format returned from a openstack service query, into a csv file

 FROM
 ```
 +-------------------+-------------+------------+
 | host_name         | service     | zone       |
 +-------------------+-------------+------------+
 | prod-test-02 | consoleauth | internal   |
 | prod-test--02 | cert        | internal   |
 | prod-test-02 | scheduler   | internal   |
 | prod-test-02 | console     | internal   |
 | prod-test-01 | console     | internal   |
 | prod-test-05 | compute     | availzone3 |
 +-------------------+-------------+------------+
```
 TO
```
 host_name,service,zone
 prod-test-02,consoleauth,internal
 prod-test-02,cert,internal
 prod-test-02,scheduler,internal
 prod-test-02,console,internal
 prod-test-01,console,internal
 prod-test-01,compute,availzone3
```

Then we load into table in a mysql, and also we send the data to a graphite server

We store each of the commands on the commands.sh script into a diferent mysql table.
Just configure the credentials in the .credentials_example file, and pass the path of the file as an argument to the OpenStack2Mysql.sh

```
./OpenStack2Mysql.sh  profiles/.profile_my_dev_cloud
```


