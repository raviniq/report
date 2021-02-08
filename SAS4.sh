start_time="$(date -u +%s)"

echo "select * from (
select SUBSTRING(created_at, 1, 10) AS Date,
sum(if( amount=0 ,1,0))as reward_points ,
sum(if( amount=6000 ,1,0))as 6K ,
sum(if( amount=30000 ,1,0))as 30K ,
sum(if( amount=40000 ,1,0))as 40K ,
sum(if( amount=55000 ,1,0))as 55K ,
sum(if( amount=75000 ,1,0))as 75K ,
sum(if( amount=120000 ,1,0))as 120K 
   from sas4.sas_managers_invoices
   where  DATE(created_at) = DATE_SUB(current_date(), INTERVAL 1 Day) group by date) as A
   cross join(
            select count(*) as active_clients
            from sas4.sas_users 
             where expiration > curdate())as B
  cross join(
            select count(*) as expired_clients
            from sas4.sas_users 
             where expiration < curdate()
            )as C;" |
 
 mysql -N -h host  -P port  -u user_name -p password -D sas4  | 
              
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
        Value8=${tmparray[7]}
        Value9=${tmparray[8]} #Active
        Value10=${tmparray[9]} #expire
        active=$(expr $Value9 - $( mysql -N -u USER -p PASS -D DB -e "(SELECT(select active_clients from test1.sas4 where Date(date)= subdate(curdate(),interval 2 day))); " ) )
        expire=$(expr $Value10 - $( mysql -N -u USER -p PASS -D DB -e "(SELECT (select expired_clients from test1.sas4 where Date(date)= subdate(curdate(),interval 2 day))); ") )
       
     echo " 
       INSERT INTO test1.sas4 (date ,reward_points,6K,30K ,40K,55K,75K,120K, active_clients, expired_clients ,daily_activation ,daily_expiration)
     VALUES('$Value1',$Value2,$Value3,$Value4,$Value5,$Value6,$Value7,$Value8 ,$Value9,$Value10,'$active','$expire');"  |
      mysql -u user  -p password -D DB_name 
    done
    
end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"
echo "Total of $elapsed seconds elapsed for SAS4 process"
