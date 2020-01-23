--Grad Rate 19-20 (Fall 2013)

--I need to have Identifiers, name, gender, Ethnicity, birthdate, degree intent

SELECT dsc_pidm, s_banner_id, spriden_first_name, spriden_last_name, substr(spriden_mi,0,1), spbpers_name_suffix, spbpers_sex, spbpers_ethn_code, s_deg_intent, spbpers_birth_date
FROM   students03 s1, SATURN.spbpers s3, SATURN.spriden s4 
WHERE  s3.spbpers_pidm = s1.dsc_pidm
AND    s1.dsc_pidm = s4.spriden_pidm
AND    s4.spriden_change_ind is null
AND    dsc_term_code = '201343'
AND    s_deg_intent  in ('4', '2')
AND    s_pt_ft       = 'F'
AND    (
         s_entry_action IN ('FF','FH')
         OR
         (
           EXISTS
           (
             SELECT 'Y'
             FROM   students03 s2 
             WHERE  s2.dsc_pidm        = s1.dsc_pidm
             AND    s2.dsc_term_code   = substr(s1.dsc_term_code,1,4)||'3E' -- The Summer previous to that Fall.
             AND    s2.s_entry_action IN ('FF','FH','HS') -- If they were HS in Summer, and FH the next Fall, I assume they should have been labeled FH. 
           )
           AND
           (
             s_entry_action = 'CS'
           )   
         )  
       );
--count 1388       
       

--Missing Ethnicity (new) 
select gorprac_pidm, gorprac_race_cde
from general.gorprac

--Missing Graduation Data (could earn more than 1 degree)
select shrdgmr_pidm, shrdgmr_degc_code, shrdgmr_grad_date 
from shrdgmr
where shrdgmr_degs_code = 'AW'
and shrdgmr_levl_code = 'UG'
--heirarchy of degrees like B, A, C

--Missing Exclusion Data (the exclusions table has not been updated with the latest data)
select * from enroll.exclusions @dscir.dixie.edu
where ex_eff_term >= '201340'

--Athlete data (All athletes need to be Bachelor's degree seeking - for degree intent)
select * from sgrsprt
where sgrsprt_term_code in ('201340', '201420')
and sgrsprt_spst_code = 'AC'

--Missing Still enrolled data (enrolled Fall 2020)
select distinct sfrstcr_pidm
from sfrstcr, stvrsts
where sfrstcr_term_code = '201940'
and sfrstcr_rsts_code = stvrsts_code 
and stvrsts_incl_sect_enrl = 'Y'

--Missing Fin Aid Data (entering year) Pell Grant Recipient; Direct Subsidized Loan Recipient (no pell grant)

--Missing National Student Clearinghouse Data

--Missing degree intent from application for admission
