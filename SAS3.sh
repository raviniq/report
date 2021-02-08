#!/bin/bash
start_time="$(date -u +%s)"

echo "select * from (
select SUBSTRING(date, 1, 10)as Date,
sum(if( price=0 ,1,0))as reward_points ,
sum(if( price=35000 ,1,0))as 35K ,
sum(if( price=50000 ,1,0))as 45K ,
sum(if( price=60000 ,1,0))as 55K,
sum(if( price=120000 ,1,0))as 120K,
sum(if( price=480000 ,1,0))as 480K 
   from sas3.sas_invoice 
   where  DATE(date) = DATE_SUB(current_date(), INTERVAL 1 Day) ) as A
   cross join(
            select count(*) as active_clients
            from sas3.sas_users 
             where expiration > curdate())as B
  cross join(
            select count(*) as expired_clients
            from sas3.sas_users 
             where expiration < curdate()
            )as C;" |
 
 mysql -N -h host  -P port  -u user_name -p password -D sas3  | 
              
    awk -F: '{print $0}' | 
    while read line
    do
       tmparray=($line)
        Value1=${tmparray[0]}
        Value2=${tmparray[1]}
        Value3=${tmparray[2]}
        Value4=${tmparray[3]}
        Value5=${tmparray[4]}
        Value6=${tmparray[5]}
        Value7=${tmparray[6]}
        Value8=${tmparray[7]} #Active
        Value9=${tmparray[8]} #Expire
        active=$(expr $Value8 - $(mysql -N -u user -p pass -D DB -e "(SELECT(select active_clients from test1.sas3 where Date(date)= subdate(curdate(),interval 2 day))); " ) )
        expire=$(expr $Value9 - $( mysql -N -u user -p pass -D DB -e "(SELECT (select expired_clients from test1.sas3 where Date(date)= subdate(curdate(),interval 2 day))); ") )
    
     
     echo "
       INSERT INTO test1.sas3 (date ,reward_points,35K ,45K,55K ,120K, 480K, active_clients, expired_clients ,daily_activation ,daily_expiration)
     VALUES('$Value1',$Value2,$Value3,$Value4,$Value5,$Value6,$Value7,$Value8,$Value9,'$active','$expire');"  |
      mysql -u user  -p pass -D DB 
    done
    
end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"
echo "Total of $elapsed seconds elapsed for SAS3 process"
