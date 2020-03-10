    SELECT b.stvterm_desc,
           a.ssbsect_crn,
           a.ssbsect_subj_code,
           a.ssbsect_crse_numb,
           a.ssbsect_seq_numb,
           e.gtvinsm_desc,
           CASE WHEN g.pebempl_ecls_code IN ('F2','F9') THEN 'FT'
                ELSE 'PT'
                END AS instructor_type,
           COUNT(DISTINCT c.sfrstcr_pidm) AS enrl_cnt,
           SUM(CASE WHEN c.sfrstcr_grde_code IN ('A+','A','A-') THEN 1
                    WHEN c.sfrstcr_grde_code IN ('B+','B','B-') THEN 1
                    WHEN c.sfrstcr_grde_code IN ('C+','C','S')  THEN 1
                    ELSE 0
                    END) AS success_cmpltd
      FROM ssbsect a
INNER JOIN stvterm b
        ON a.ssbsect_term_code = b.stvterm_code
 LEFT JOIN sfrstcr c
        ON a.ssbsect_term_code = c.sfrstcr_term_code
       AND a.ssbsect_crn = c.sfrstcr_crn
INNER JOIN stvrsts d
        ON c.sfrstcr_rsts_code = d.stvrsts_code
 LEFT JOIN gtvinsm e
        ON a.ssbsect_insm_code = e.gtvinsm_code
 LEFT JOIN sirasgn f
        ON a.ssbsect_term_code = f.sirasgn_term_code
       AND a.ssbsect_crn = f.sirasgn_crn
 LEFT JOIN pebempl g
        ON f.sirasgn_pidm = g.pebempl_pidm
     WHERE a.ssbsect_ssts_code = 'A'
       AND a.ssbsect_term_code = '201940'
       AND a.ssbsect_enrl > 0
       AND d.stvrsts_incl_sect_enrl = 'Y'
       AND f.sirasgn_primary_ind = 'Y'
       -- Erin's list of courses; these could be removed to generalize.
       AND CONCAT(a.ssbsect_subj_code, a.ssbsect_crse_numb) IN (
             'ECON1740','HIST1700','HIST2700','HIST2710','POLS1100',
             'MATH1030','MATH1040','MATH1050','MATH1060','MATH1080',
             'MATH1100','MATH1210','MATH1220','MATH2210')
  GROUP BY b.stvterm_desc,
           a.ssbsect_crn,
           a.ssbsect_subj_code,
           a.ssbsect_crse_numb,
           a.ssbsect_seq_numb,
           f.sirasgn_pidm,
           e.gtvinsm_desc,
           CASE WHEN g.pebempl_ecls_code IN ('F2','F9') THEN 'FT'
                ELSE 'PT'
                END;