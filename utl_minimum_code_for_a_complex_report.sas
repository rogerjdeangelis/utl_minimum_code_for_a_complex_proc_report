Minimum code not minimum time
Same result WPS and SAS

Original Topic: Quartiling and finding the average in each quartile

github
https://github.com/rogerjdeangelis/utl_minimum_code_for_a_complex_report

see
https://tinyurl.com/yb9pen3u
https://communities.sas.com/t5/Base-SAS-Programming/Quartiling-and-finding-the-average-in-each-quartile/m-p/468578

INPUT
=====

 WORK.HAVE total obs=91

   PAT    SEX    AGE

   243     2      50
    89     2      49
   383     2      58
    97     2      67
   257     2      61
    88     1      61
    36     1      38
   107     1      64
  ...

EXAMPLE OUTPUT

  Minimum Code for a Complex Report


  Major       Minor
  Category    Category           Statistic

  Gender      Male               21(11.5%)      * Male before Female (out of alpha order)
              Female             70(38.5%)

  Quarter 0   N                         44
              Mean(SD)          20.4(19.2)      * Just happens to be alpha(I allow for other orders)
              Median                  14.0
              Min Max                 1 44
  ...


PROCESS (All the code)
======================

* slice into 4 quarters may want to adjust tie algorithm;
proc rank data=have out=havRnk groups=4;
  var age;
  ranks ageRnk;
run;quit;

* normalize - long and skinny;
proc transpose data=havRnk out=havNrm
   ( rename=(_name_=var col1=val));
by pat notsorted ageRnk notsorted;
var sex age;
run;quit;

proc format;
  value ageq
  0="Quarter 0"  1="Quarter 1"  2="Quarter 2"  3="Quarter 3"
;run;quit;

* set aside the 10 position of minor categories - wee will use a format later to supress;
* Order can often ad complexity;

* stack the stats - sql can do the median, max and min but no other order statistics;
proc sql;
 create
   table havSta as
 select
    'Gender    ' as mjr
    ,case (sex)
      when 1 then "Male     0"
      else        "Female   0"
    end as mnr
   ,cats(put(count(sex),3.),'(',put(100*count(sex)/(select count(*) from havNrm),5.1),'%)') as val
 from
   havRnk
 group
   by sex
 union
   corr
 select put(ageRnk,ageq.) as mjr,'N        1' as mnr,put(count(val),5.)  as val from havNrm
   group by agernk union corr
 select put(ageRnk,ageq.) as mjr,'Avg(SD)  2' as mnr,cats(put(mean(val),5.1),'(',put(std(val),5.1),')') as val from havNrm
   group by agernk union corr
 select put(ageRnk,ageq.) as mjr,'Median   3' as mnr,put(median(val),5.1)  as val from havNrm
   group by agernk union corr
 select put(ageRnk,ageq.) as mjr,'Min Max  4' as mnr,catx(' ',put(min(val),5.),put(max(val),5.))  as val from havNrm
   group by agernk
 order
  by mjr, reverse(mnr)
;quit;


proc report data=havSta nowd missing split='#' headskip;
  title "Minimum Code for a Complex Report";
  format val $18. mnr $8.;
  cols mjr mnr val;
   define mjr / group 'Major#Category' order=data;
   define mnr / group 'Minor#Category' order=data;
   define val / display 'Statistic' right;
   break after mjr / skip;
run;quit;



  Minimum Code for a Complex Report


  Major       Minor
  Category    Category           Statistic

  Gender      Male               21(11.5%)
              Female             70(38.5%)

  Quarter 0   N                         44
              Mean(SD)          20.4(19.2)
              Median                  14.0
              Min Max                 1 44

  Quarter 1   N                         46
              Mean(SD)          25.1(23.6)
              Median                  23.5
              Min Max                 1 51

  Quarter 2   N                         50
              Mean(SD)          28.3(26.8)
              Median                  27.0
              Min Max                 1 57

  Quarter 3   N                         42
              Mean(SD)          32.2(30.8)
              Median                  30.0
              Min Max                 1 71


*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data have;
 retain pat;
 input sex age @@;
 pat=int(1000*uniform(1234));
cards4;
2 50 2 49 2 58 2 67 2 61 2 61 2 38 2 64 2 54 2 54 2 50 2 49 2 43
2 56 2 66 2 42 2 47 2 48 2 59 2 53 2 56 2 59 2 45 2 47 2 57 2 43
2 47 2 53 2 56 2 50 2 68 2 47 2 35 2 43 2 45 2 49 1 54 2 49 1 50
2 55 1 54 2 57 1 38 2 66 1 57 2 44 1 53 2 55 1 38 2 58 1 60 2 46
1 38 2 45 1 51 2 51 1 61 2 39 1 56 2 40 1 56 2 53 1 37 2 57 1 37
2 52 1 44 2 34 1 50 2 46 1 50 2 53 1 40 2 66 1 51 2 42 1 26 2 69
2 58 2 65 2 44 2 58 2 57 2 71 2 31 2 52 2 59 2 44 2 55 2 60 2 55
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

options ls=171;

%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
proc rank data=wrk.have out=havRnk groups=4;
  var age;
  ranks ageRnk;
run;quit;
proc transpose data=havRnk out=havNrm
   (rename=(_name_=var col1=val));
by pat notsorted ageRnk notsorted;
var sex age;
run;quit;
proc format;
  value ageq
  0="Quarter 0"  1="Quarter 1"  2="Quarter 2"  3="Quarter 3"
;run;quit;
proc sql;
 create
   table havSta as
 select
    "Gender    " as mjr
    ,case (sex)
      when 1 then "Male     0"
      else        "Female   0"
    end as mnr
   ,cats(put(count(sex),3.),"(",put(100*count(sex)/(select count(*) from havNrm),5.1),"%)") as val
 from
   havRnk
 group
   by sex
 union
   corr
 select put(ageRnk,ageq.) as mjr,"N        1" as mnr,put(count(val),5.)  as val from havNrm
   group by agernk union corr
 select put(ageRnk,ageq.) as mjr,"Avg(SD)  2" as mnr,cats(put(mean(val),5.1),"(",put(std(val),5.1),")") as val from havNrm
   group by agernk union corr
 select put(ageRnk,ageq.) as mjr,"Median   3" as mnr,put(median(val),5.1)  as val from havNrm
   group by agernk union corr
 select put(ageRnk,ageq.) as mjr,"Min Max  4" as mnr,catx(" ",put(min(val),5.),put(max(val),5.))  as val from havNrm
   group by agernk
 order
  by mjr, reverse(mnr)
;quit;
proc report data=havSta nowd missing split="#" headskip;
title "Minimum Code for a Complex Report";
format val $18. mnr $8.;
cols mjr mnr val;
define mjr / group "Major#Category" order=data;
define mnr / group "Minor#Category" order=data;
define val / display "Statistic" right;
break after mjr / skip;
run;quit;
');

