WITH enrolled_students AS (
        SELECT DISTINCT a.sfrstcr_term_code,
               a.sfrstcr_pidm
          FROM sfrstcr a
         WHERE a.sfrstcr_camp_code <> 'XXX'
           AND a.sfrstcr_levl_code = 'UG'
           AND a.sfrstcr_rsts_code IN
                 (SELECT b.stvrsts_code
                    FROM stvrsts b
                   WHERE b.stvrsts_incl_sect_enrl = 'Y'))
    SELECT b.sfrstcr_term_code AS term_code,
           d.stvterm_desc AS term_desc,
           a.sgbstdn_levl_code,
           a.sgbstdn_coll_code_1,
           a.sgbstdn_degc_code_1,
           a.sgbstdn_majr_code_1,
           c.stvmajr_desc AS major_desc,
           COUNT(a.sgbstdn_pidm) AS student_cnt
      FROM sgbstdn a
INNER JOIN enrolled_students b
        ON a.sgbstdn_pidm = b.sfrstcr_pidm
 LEFT JOIN stvmajr c
        ON a.sgbstdn_majr_code_1 = c.stvmajr_code
 LEFT JOIN stvterm d
        ON b.sfrstcr_term_code = d.stvterm_code
     WHERE a.sgbstdn_stst_code = 'AS'
       AND a.sgbstdn_coll_code_1 = 'FA'
       AND SUBSTR(b.sfrstcr_term_code,1,4) BETWEEN '2014' AND '2019'
       AND SUBSTR(b.sfrstcr_term_code,5,2) = '40'
       AND a.sgbstdn_term_code_eff =
           (SELECT MAX(aa.sgbstdn_term_code_eff)
              FROM sgbstdn aa
             WHERE a.sgbstdn_pidm = aa.sgbstdn_pidm
               AND aa.sgbstdn_term_code_eff <= b.sfrstcr_term_code)
  GROUP BY b.sfrstcr_term_code,
           d.stvterm_desc,
           a.sgbstdn_levl_code,
           a.sgbstdn_coll_code_1,
           a.sgbstdn_degc_code_1,
           a.sgbstdn_majr_code_1,
           c.stvmajr_desc;
