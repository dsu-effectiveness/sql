   SELECT DISTINCT a.sfrstcr_term_code AS Start_Term,
          a.sfrstcr_term_code + 80 AS Return_term,
          a.sfrstcr_pidm,
          CASE WHEN b.sfrstcr_pidm IS NOT NULL THEN 'Y'
               ELSE 'N'
               END AS retention_ind,
          CASE WHEN c.stvchrt_desc IS NOT NULL THEN 'Y'
               ELSE 'N'
               END AS structured_enrollment_SE,
          CASE WHEN c.stvchrt_term_code_start IS NOT NULL
               THEN c.stvchrt_term_code_start
               ELSE 'NA'
               END AS SE_start_date,
          d.spbpers_sex,
          d.spbpers_ethn_code,
          d.spbpers_relg_code,
          e.stvethn_desc,
          f.sgbstdn_resd_code,
          g.stvresd_desc,
          g.stvresd_in_state_ind,
          h.stvrelg_desc,
          CASE WHEN d.spbpers_citz_code = '2' THEN 'Nonresident alien'
               WHEN d.spbpers_ethn_cde = '2' THEN 'Hispanic'
               WHEN j.race_cdes LIKE '%H%' THEN 'Hispanic'
               WHEN j.race_cdes LIKE '%|%' THEN 'Two or more races'
               WHEN j.race_cdes IS NOT NULL THEN k.gorrace_desc
               ELSE 'Unknown'
               END AS race_desc
     FROM sfrstcr a
LEFT JOIN (SELECT DISTINCT bb.sfrstcr_term_code,
                  bb.sfrstcr_pidm
             FROM sfrstcr bb
            WHERE bb.sfrstcr_camp_code <> 'XXX'
              AND bb.sfrstcr_term_code IN ('201920', '202020')
              AND bb.sfrstcr_levl_code = 'UG'
              AND bb.sfrstcr_rsts_code IN
                   (SELECT bbb.stvrsts_code
                      FROM stvrsts bbb
                     WHERE bbb.stvrsts_incl_sect_enrl = 'Y')) b
               ON a.sfrstcr_pidm = b.sfrstcr_pidm
              AND a.sfrstcr_term_code = b.sfrstcr_term_code - 80 --Gap number is the number subtracted
        LEFT JOIN (SELECT ca.sgrchrt_pidm,
                          cb.stvchrt_desc,
                          cb.stvchrt_term_code_start
                     FROM sgrchrt ca
                LEFT JOIN stvchrt cb
                       ON ca.sgrchrt_chrt_code = cb.stvchrt_code
                    WHERE sgrchrt_chrt_code LIKE 'SARC%') c
               ON a.sfrstcr_pidm = c.sgrchrt_pidm
        LEFT JOIN spbpers d
               ON a.sfrstcr_pidm = d.spbpers_pidm
        LEFT JOIN stvethn e
               ON d.spbpers_ethn_code = e.stvethn_code
        LEFT JOIN sgbstdn f
               ON a.sfrstcr_pidm = f.SGBSTDN_PIDM
        LEFT JOIN stvresd g
               ON f.sgbstdn_resd_code = g.stvresd_code
        LEFT JOIN stvrelg h
               ON d.spbpers_relg_code = h.stvrelg_code
        LEFT JOIN (SELECT jj.gorprac_pidm,
                          LISTAGG(jj.gorprac_race_cde, '|') AS race_cdes
                     FROM gorprac jj
                 GROUP BY jj.gorprac_pidm) j
               ON a.sfrstcr_pidm = j.gorprac_pidm
        LEFT JOIN gorrace k
               ON j.race_cdes = k.gorrace_race_cde
            WHERE a.sfrstcr_camp_code <> 'XXX'
              AND a.sfrstcr_term_code IN ('201840', '201940')
              AND a.sfrstcr_levl_code = 'UG'
              AND a.sfrstcr_rsts_code IN
                   (SELECT b.stvrsts_code
                      FROM stvrsts b
                     WHERE b.stvrsts_incl_sect_enrl = 'Y')
              AND f.sgbstdn_term_code_eff =
                   (SELECT MAX(ff.sgbstdn_term_code_eff)
                      FROM sgbstdn ff
                     WHERE f.sgbstdn_pidm = ff.sgbstdn_pidm
                       AND ff.sgbstdn_term_code_eff <=
                            (SELECT MIN(aa.sfrstcr_term_code)
                               FROM sfrstcr aa
                              WHERE a.sfrstcr_pidm = aa.sfrstcr_pidm
                                AND aa.sfrstcr_term_code >= a.sfrstcr_term_code) )