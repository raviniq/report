#!/bin/bash
start_time="$(date -u +%s)"
echo "select * from ( 
 select date(created_at) AS date,
sum(if(type ='redeem' and amount=2000 ,1,0))as redeem2K ,
sum(if(type ='redeem' and amount=5000 ,1,0))as redeem5K ,
sum(if(type ='redeem' and amount=10000 ,1,0))as redeem10K ,
sum(if(type ='redeem' and amount=25000 ,1,0))as redeem25K ,
sum(if(type ='purchase' and amount=2000 ,1,0))as purchase2K ,
sum(if(type ='purchase' and amount=5000 ,1,0))as purchase5K ,
sum(if(type ='purchase' and amount=10000 ,1,0))as purchase10K,
sum(if(type ='purchase' and amount=25000 ,1,0))as purchase25K 
 from cbs.transactions 
 where DATE(created_at) = DATE_SUB(current_date(), INTERVAL 1 Day)  
 group by Date ) as A
cross join (
            SELECT count(*) as daily_registration 
             FROM cbs.subscribers 
               where DATE(created_at) = DATE_SUB(current_date(), INTERVAL 1 Day))as B
cross join (
            SELECT
             sum(if(date(expiration)= DATE_SUB(curdate(),INTERVAL 30 Day) ,1,0))as daily_expiry
                FROM cbs.rdbaccounts 
                   where expiration< curdate())as c
cross join ( 
         select count(s.id) as registered
         from cbs.subscribers s 
           inner join accounts a on s.id=a.subscriber_id 
             where s.created_at < curdate() ) as d

cross join (
            SELECT 
             sum(if(date(expiration)< DATE_SUB(curdate(),INTERVAL 30 Day) ,1,0))as total_expiry 
               FROM cbs.rdbaccounts 
                 where expiration< curdate())as e;" |
 
 mysql -N -h HOST -P PORT -u USER  -p PASS -D cbs | 
              
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
        Value9=${tmparray[8]}
        Value10=${tmparray[9]}
        Value11=${tmparray[10]}
        Value12=${tmparray[11]}
        Value13=${tmparray[12]}
       
     
     echo " 
       INSERT INTO test1.rcell (date,redeem2K,redeem5K,redeem10K,redeem25K ,purchase2K ,purchase5K ,purchase10K ,purchase25K,daily_registration,daily_expiration,registered,total_expiry)
     VALUES('$Value1',$Value2,$Value3,$Value4,$Value5,$Value6,$Value7,$Value8,$Value9,$Value10,$Value11,$Value12,$Value13);"  |
      mysql -u USER  -p PASS -D DB 
     done
end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"
echo "Total of $elapsed seconds elapsed for process rcell script"

