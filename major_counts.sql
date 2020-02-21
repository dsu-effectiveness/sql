WITH enrolled_students AS (
        SELECT DISTINCT
               a.sfrstcr_term_code,
               a.sfrstcr_pidm
          FROM sfrstcr a
         WHERE a.sfrstcr_camp_code <> 'XXX'
           AND a.sfrstcr_levl_code = 'UG'
           AND a.sfrstcr_rsts_code IN
                 (SELECT b.stvrsts_code
                    FROM stvrsts b
                   WHERE b.stvrsts_incl_sect_enrl = 'Y'))

    SELECT f.sfrstcr_term_code   AS term_code,
           g.stvterm_desc,
           f.sgbstdn_levl_code   AS levl_code,
           h.stvlevl_desc,
           CASE f.sgbstdn_coll_code_1
                WHEN 'CT' THEN 'SC' -- Computer Info Tech into Sci, Engr, & Tech
                WHEN 'EF' THEN 'ED' -- Ed/Fam Sci/PE into College of Ed
                WHEN 'HI' THEN 'HS' -- Hist/Poli Sci into College of Humanities
                WHEN 'MA' THEN 'SC' -- Math into Sci, Engr, & Tech
                WHEN 'TE' THEN 'SC' -- Technologies into Sci, Engr, & Tech
                ELSE f.sgbstdn_coll_code_1
                END AS coll_code,
           j.stvcoll_desc,
           f.sgbstdn_degc_code_1 AS degc_code,
           k.stvdegc_desc,
           f.sgbstdn_majr_code_1 AS majr_code,
           l.stvmajr_desc,
           f.sgbstdn_pidm        AS student_pidm
     FROM (
              SELECT b.sfrstcr_term_code,
                     a.sgbstdn_levl_code,
                     a.sgbstdn_coll_code_1,
                     a.sgbstdn_degc_code_1,
                     a.sgbstdn_majr_code_1,
                     a.sgbstdn_pidm
                FROM sgbstdn a
          INNER JOIN enrolled_students b
                  ON a.sgbstdn_pidm = b.sfrstcr_pidm
               WHERE a.sgbstdn_stst_code = 'AS'
                 AND SUBSTR(b.sfrstcr_term_code, 1, 4) BETWEEN '2014' AND '2019'
                 AND SUBSTR(b.sfrstcr_term_code, 5, 2) = '40'
                 AND a.sgbstdn_term_code_eff = (SELECT MAX(aa.sgbstdn_term_code_eff)
                                                  FROM sgbstdn aa
                                                 WHERE a.sgbstdn_pidm = aa.sgbstdn_pidm
                                                   AND aa.sgbstdn_term_code_eff <= b.sfrstcr_term_code)

              UNION ALL

              SELECT d.sfrstcr_term_code,
                     b.sgbstdn_levl_code,
                     b.sgbstdn_coll_code_2,
                     b.sgbstdn_degc_code_2,
                     b.sgbstdn_majr_code_2,
                     b.sgbstdn_pidm
                FROM sgbstdn b
          INNER JOIN enrolled_students d
                  ON b.sgbstdn_pidm = d.sfrstcr_pidm
               WHERE b.sgbstdn_majr_code_2 IS NOT NULL
                 AND b.sgbstdn_stst_code = 'AS'
                 AND SUBSTR(d.sfrstcr_term_code, 1, 4) BETWEEN '2014' AND '2019'
                 AND SUBSTR(d.sfrstcr_term_code, 5, 2) = '40'
                 AND b.sgbstdn_term_code_eff = (SELECT MAX(bb.sgbstdn_term_code_eff)
                                                  FROM sgbstdn bb
                                                 WHERE b.sgbstdn_pidm = bb.sgbstdn_pidm
                                                   AND bb.sgbstdn_term_code_eff <= d.sfrstcr_term_code)
          ) f
LEFT JOIN stvterm g
       ON f.sfrstcr_term_code = g.stvterm_code
LEFT JOIN stvlevl h
       ON f.sgbstdn_levl_code = h.stvlevl_code
LEFT JOIN stvcoll j
       ON f.sgbstdn_coll_code_1 = j.stvcoll_code
LEFT JOIN stvdegc k
       ON f.sgbstdn_degc_code_1 = k.stvdegc_code
LEFT JOIN stvmajr l
       ON f.sgbstdn_majr_code_1 = l.stvmajr_code


