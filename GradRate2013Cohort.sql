--This query pulls all the data needed for the IPEDS graduation report. The report year is 19-20, the cohort
--year is 2013-2014
    SELECT  a.sgbuser_pidm,
            c.spriden_id,
            c.spriden_first_name,
            c.spriden_last_name,
            SUBSTR(c.spriden_mi,0,1),
            b.spbpers_name_suffix,
            b.spbpers_sex,
            --We have to pull race code from two different tables. We will have to do this untill ???
            --gorprac is where the older race codes are contained and spbpers_ethn_code is where the 
            --newer codes are contained. 
            COALESCE(b.spbpers_ethn_code, d.race_cde, '') AS ethnicity,
            -- s_deg_intent, DELETE??
            b.spbpers_birth_date,
            a.sgbuser_sudc_code,
            e.athletic_ind,
            f.enroll_ind,
            g.shrdgmr_degc_code
       FROM sgbuser a
 INNER JOIN spbpers b
         ON a.sgbuser_pidm = b.spbpers_pidm
 INNER JOIN spriden c
         ON a.sgbuser_pidm = c.spriden_pidm
         --This subquery pulls out the ethnicity code. The select statement prior to the union pulls
         --in the race code for all the students who do not have more than one race code in gorprac.
         --The select statement after the union pulls in all the students who have more than one race
         --code in gorprac.
  LEFT JOIN (SELECT dd.gorprac_pidm,
                    dd.gorprac_race_cde AS race_cde
               FROM gorprac dd
              WHERE dd.gorprac_pidm NOT IN
                    (SELECT ddd.gorprac_pidm
                       FROM gorprac ddd
                      GROUP BY ddd.gorprac_pidm
                     HAVING COUNT(*) > 1)
              UNION
             SELECT dd.gorprac_pidm,
                    '2+' AS race_cde
               FROM gorprac dd
              GROUP BY dd.gorprac_pidm
             HAVING COUNT(*) > 1) d
         ON a.sgbuser_pidm = d.gorprac_pidm
  LEFT JOIN (SELECT DISTINCT ee.sgrsprt_pidm,
                    ee.sgrsprt_term_code,
                    'Y' AS athletic_ind
               FROM sgrsprt ee
              WHERE ee.sgrsprt_spst_code = 'AC') e
         ON a.sgbuser_pidm = e.sgrsprt_pidm
        AND e.sgrsprt_term_code BETWEEN a.sgbuser_term_code AND a.sgbuser_term_code+80 --pulls in fall and spring
  LEFT JOIN (SELECT DISTINCT ff.sfrstcr_pidm,
                             ff.sfrstcr_term_code,
                             'Y' AS enroll_ind
                        FROM sfrstcr ff
                  INNER JOIN stvrsts fff
                          ON ff.sfrstcr_rsts_code = fff.stvrsts_code
                       WHERE fff.stvrsts_incl_sect_enrl = 'Y') f
         ON a.sgbuser_pidm = f.sfrstcr_pidm
        AND f.sfrstcr_term_code = a.sgbuser_term_code + 600 --Six years
  LEFT JOIN (SELECT gg.shrdgmr_pidm,
                    gg.shrdgmr_degc_code
               FROM shrdgmr gg
              --This selects the last degree that was awarded to the student
              WHERE gg.shrdgmr_seq_no = (SELECT MAX(ggg.shrdgmr_seq_no)
                                           FROM shrdgmr ggg
                                          WHERE gg.shrdgmr_pidm = ggg.shrdgmr_pidm)) g
         ON a.sgbuser_pidm = g.shrdgmr_pidm
      WHERE c.spriden_change_ind IS NULL
        AND a.sgbuser_term_code = '201340'
        AND (a.sgbuser_sudc_code IN ('FF','FH')
    --  AND s_deg_intent IN ('4', '2') DELETE ??
    --  AND s_pt_ft = 'F'  DELETE ??
            OR (a.sgbuser_sudc_code = 'CS'
                AND a.sgbuser_pidm IN (SELECT aa.sgbuser_pidm 
                                         FROM sgbuser aa
                                        WHERE aa.sgbuser_term_code = SUBSTR(a.sgbuser_term_code,1,4)||'30' -- The Summer previous to that Fall.
                                          AND aa.sgbuser_sudc_code IN ('FF','FH','HS')))) -- If they were HS in Summer, and FH the next Fall, I assume they should have been labeled FH. 
;

--count 1388       




--heirarchy of degrees like B, A, C

--Missing Exclusion Data (the exclusions table has not been updated with the latest data)
--select *
--from enroll.exclusions
--@dscir.dixie.edu
--where ex_eff_term >= '201340'


--Missing Fin Aid Data (entering year) Pell Grant Recipient; Direct Subsidized Loan Recipient (no pell grant)

--Missing National Student Clearinghouse Data

--Missing degree intent from application for admission


