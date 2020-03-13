-- Written with a subquery.

        SELECT DISTINCT a.sfrstcr_term_code,
               a.sfrstcr_pidm,
               CASE WHEN b.sfrstcr_pidm IS NOT NULL THEN 'Y'
                    ELSE 'N'
                    END AS retention_ind
          FROM sfrstcr a
     LEFT JOIN (SELECT DISTINCT bb.sfrstcr_term_code,
                       bb.sfrstcr_pidm
                  FROM sfrstcr bb
                 WHERE bb.sfrstcr_camp_code <> 'XXX'
                   AND bb.sfrstcr_term_code = '202020'
                   AND bb.sfrstcr_levl_code = 'UG'
                   AND bb.sfrstcr_rsts_code IN
                       (SELECT bbb.stvrsts_code
                          FROM stvrsts bbb
                         WHERE bbb.stvrsts_incl_sect_enrl = 'Y')) b
            ON a.sfrstcr_pidm = b.sfrstcr_pidm
         WHERE a.sfrstcr_camp_code <> 'XXX'
           AND a.sfrstcr_term_code = '201940'
           AND a.sfrstcr_levl_code = 'UG'
           AND a.sfrstcr_rsts_code IN
                 (SELECT b.stvrsts_code
                    FROM stvrsts b
                   WHERE b.stvrsts_incl_sect_enrl = 'Y')

-- Written with a CTE.

WITH enrolled_students AS (
        SELECT DISTINCT a.sfrstcr_term_code,
               a.sfrstcr_pidm
          FROM sfrstcr a
         WHERE a.sfrstcr_camp_code <> 'XXX'
           AND a.sfrstcr_levl_code = 'UG'
           AND a.sfrstcr_rsts_code IN
                 (SELECT b.stvrsts_code
                    FROM stvrsts b
                   WHERE b.stvrsts_incl_sect_enrl = 'Y')
        GROUP BY a.sfrstcr_term_code,
               a.sfrstcr_pidm

    )

   SELECT a.sfrstcr_pidm,
          CASE WHEN b.sfrstcr_pidm IS NOT NULL THEN 'Y'
               ELSE 'N'
               END AS next_term_retained
     FROM enrolled_students a
LEFT JOIN enrolled_students b
       ON a.sfrstcr_pidm = b.sfrstcr_pidm
      AND b.sfrstcr_term_code = '202020'
    WHERE a.sfrstcr_term_code = '201940'

-- Written with a CTE to get minimum term.
-- Min term is returned from the join to SFRSTCR.

WITH enrolled_students AS (
        SELECT DISTINCT a.sfrstcr_term_code,
               a.sfrstcr_pidm,
               MIN(DISTINCT b.sfrstcr_term_code) AS stu_first_term
          FROM sfrstcr a
     LEFT JOIN sfrstcr b
            ON a.sfrstcr_pidm = b.sfrstcr_pidm
         WHERE a.sfrstcr_camp_code <> 'XXX'
           AND a.sfrstcr_levl_code = 'UG'
           AND a.sfrstcr_rsts_code IN
                 (SELECT b.stvrsts_code
                    FROM stvrsts b
                   WHERE b.stvrsts_incl_sect_enrl = 'Y')
        GROUP BY a.sfrstcr_term_code,
               a.sfrstcr_pidm
    )
 
   SELECT a.sfrstcr_pidm,
          CASE WHEN b.sfrstcr_pidm IS NOT NULL THEN 'Y'
               ELSE 'N'
               END AS next_term_retained
     FROM enrolled_students a
LEFT JOIN enrolled_students b
       ON a.sfrstcr_pidm = b.sfrstcr_pidm
      AND b.sfrstcr_term_code = '202020'
    WHERE a.sfrstcr_term_code = '201940'


-- This one just creates a giant summary table.

WITH enrolled_students AS (
        SELECT DISTINCT a.sfrstcr_term_code,
               a.sfrstcr_pidm,
               MIN(DISTINCT b.sfrstcr_term_code) AS stu_first_term
          FROM sfrstcr a
     LEFT JOIN sfrstcr b
            ON a.sfrstcr_pidm = b.sfrstcr_pidm
         WHERE a.sfrstcr_camp_code <> 'XXX'
           AND a.sfrstcr_levl_code = 'UG'
           AND a.sfrstcr_rsts_code IN
                 (SELECT b.stvrsts_code
                    FROM stvrsts b
                   WHERE b.stvrsts_incl_sect_enrl = 'Y')
        GROUP BY a.sfrstcr_term_code,
               a.sfrstcr_pidm
    )
 
SELECT * FROM enrolled_students
