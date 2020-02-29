-- Ways you might handle multiple rows in SSRMEET.
-- You could, of course, do your magic in R, but some SQL ideas...

-- 1. WINDOW FUNCTIONS
-- You could use a window function to assign rank in a CTE or subquery.
-- ROW_NUMBER assigns row numbers in order based on the field specified in
-- the order by clause.  Row numbering assignment resets with each partition.
WITH (
    SELECT a.ssrmeet_term_code,
           a.ssrmeet_crn,
           a.ssrmeet_begin_time,
           a.ssrmeet_end_time,
           a.ssrmeet_bldg_code,
           a.ssrmeet_room_code,
           a.ssrmeet_start_date,
           a.ssrmeet_end_date,
           a.ssrmeet_mon_day, -- Code for other days...
           a.ssrmeet_schd_code,
           ROW_NUMBER() OVER (PARTITION BY a.ssrmeet_term_code, a.ssrmeet_crn
                                  ORDER BY a.ssrmeet_hrs_week DESC) AS rn
      FROM ssrmeet a
     WHERE a.ssrmeet_term_code = '201940'
       AND a.ssrmeet_crn IN ('40007','40082','40244')
) AS sched_data;

-- You could then retrieve the row that contains the maximum value...
SELECT * FROM sched_data WHERE rn = 1;

-- Or you could retrieve the first two entries for a class, etc.
   SELECT a.ssrmeet_begin_time AS begintime1,
          a.ssrmeet_end_time AS endtime1,
          b.ssrmeet_begin_time AS begintime2,
          b.ssrmeet_end_time AS endtime2
     FROM (SELECT * FROM sched_data WHERE rn = 1) a
LEFT JOIN (SELECT * FROM sched_data WHERE rn = 2) b
       ON a.ssrmeet_term_code = b.ssrmeet_term_code
      AND a.ssrmeet_crn = b.ssrmeet_crn;

-- 2. LISTAGG
-- Listagg is a little known function (LIST_AGG in MSSQL) that concatenates
-- values over a returned list.  It is considered by some a window function too.
-- You can specify the separator in the call to LISTAGG.
   SELECT a.ssrmeet_term_code,
          a.ssrmeet_crn,
          LISTAGG(a.ssrmeet_begin_time, ';') AS begin_times,
          LISTAGG(a.ssrmeet_end_time, ';') AS end_times
     FROM ssrmeet a
    WHERE a.ssrmeet_term_code = '201940'
      AND a.ssrmeet_crn IN ('40007','40082','40244')
 GROUP BY a.ssrmeet_term_code,
          a.ssrmeet_crn;
