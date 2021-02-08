#!/bin/bash
start_time="$(date -u +%s)"

echo "select * from (
select SUBSTRING(created_on, 1, 10) AS date,
sum(if( amount=33500 ,1,0))as 33K ,
sum(if( amount=39000 ,1,0))as 39K ,
sum(if( amount=50000 ,1,0))as 49K ,
sum(if( amount=70000 ,1,0))as 70K ,
sum(if( amount=100000 ,1,0))as 100K,
sum(if( amount=200000 ,1,0))as 200K,
sum(if( amount=300000 ,1,0))as 300K,
sum(if( amount=500000 ,1,0))as 500K
   from firebird.fb_invoices 
   where  DATE(created_on) = DATE_SUB(curdate(), Interval 1 day) group by date) as A
   cross join(
            select count(*) as active
            from firebird.fb_cpe cp 
             inner join fb_clients c on  c.id = cp.client_id 
              where expiration >  curdate()
              and gr_phone is null )as B
  cross join(
             select count(*) as expire
             from firebird.fb_cpe cp 
             inner join fb_clients c on  c.id = cp.client_id 
             where expiration <  curdate()
             and gr_phone is null)as C;" |
 
 mysql -N -h HOST -P PORT -u USER -p PASS -D firebird  | 
              
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
        Value10=${tmparray[9]} #Active
        Value11=${tmparray[10]} #Expire
       
        Active=$(expr $Value10 - $( mysql -N -u USER -p PASS -D DB -e "(SELECT (select active from test1.ftth where Date(date)= subdate(curdate(),interval 2 day))); ") )
        Expire=$(expr $Value11 - $( mysql -N -u USER -p PASS -D DB -e "(SELECT(select expire from test1.ftth where Date(date)= subdate(curdate(),interval 2 day))); " ) )
       
    echo "
       INSERT INTO test1.ftth (date ,33K ,39K ,49K,70K ,100K ,200K ,300K ,500K ,active,expire ,daily_activation,daily_expiration)
        VALUES('$Value1',$Value2,$Value3,$Value4,$Value5,$Value6,$Value7,$Value8,$Value9,$Value10,$Value11,'$Active','$Expire');"  |
      mysql -u USER  -p PASS -D DB 
    done
    
end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"
echo "Total of $elapsed seconds elapsed for FTTH process"

