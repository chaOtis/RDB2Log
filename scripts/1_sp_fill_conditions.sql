CREATE PROCEDURE [dbo].[sp_fill_conditions]
@database varchar(128) = NULL

AS

BEGIN

IF object_id(N'DBA..[RoleConditions]') IS NOT NULL
DELETE FROM [DBA].[dbo].[RoleConditions]

INSERT INTO [DBA].[dbo].[RoleConditions] (role, accuracy_upper, accuracy_lower, sufficiency_upper, sufficiency_lower, precision_upper, precision_lower, consistency_upper, consistency_lower, completeness_upper, completeness_lower, objectivity_upper, objectivity_lower, security_upper, security_lower, uniqueness_upper, uniqueness_lower, informativeness_upper, informativeness_lower, integrity_upper, integrity_lower, conciseness_upper, conciseness_lower, currency_upper, currency_lower) VALUES ('caseID', null, 0.9, null, 0.7, null, null, null, 0.8, null, 0.9, null, 0.5, null, null, null, 0.9, null, 0.8, null, 0.9, null, 0.5, null, null);
INSERT INTO [DBA].[dbo].[RoleConditions] (role, accuracy_upper, accuracy_lower, sufficiency_upper, sufficiency_lower, precision_upper, precision_lower, consistency_upper, consistency_lower, completeness_upper, completeness_lower, objectivity_upper, objectivity_lower, security_upper, security_lower, uniqueness_upper, uniqueness_lower, informativeness_upper, informativeness_lower, integrity_upper, integrity_lower, conciseness_upper, conciseness_lower, currency_upper, currency_lower) VALUES ('activity', null, 0.9, null, 0.7, null, null, null, 0.8, null, 0.9, null, null, null, 0.5, 0.5, null, null, 0.6, null, 0.9, null, 0.8, null, null);
INSERT INTO [DBA].[dbo].[RoleConditions] (role, accuracy_upper, accuracy_lower, sufficiency_upper, sufficiency_lower, precision_upper, precision_lower, consistency_upper, consistency_lower, completeness_upper, completeness_lower, objectivity_upper, objectivity_lower, security_upper, security_lower, uniqueness_upper, uniqueness_lower, informativeness_upper, informativeness_lower, integrity_upper, integrity_lower, conciseness_upper, conciseness_lower, currency_upper, currency_lower) VALUES ('timestamp', null, 0.9, null, 0.7, null, 0.6, null, 0.7, null, 0.9, null, null, null, null, null, 0.9, null, 0.8, null, 0.9, null, 0.5, null, 0.6);
INSERT INTO [DBA].[dbo].[RoleConditions] (role, accuracy_upper, accuracy_lower, sufficiency_upper, sufficiency_lower, precision_upper, precision_lower, consistency_upper, consistency_lower, completeness_upper, completeness_lower, objectivity_upper, objectivity_lower, security_upper, security_lower, uniqueness_upper, uniqueness_lower, informativeness_upper, informativeness_lower, integrity_upper, integrity_lower, conciseness_upper, conciseness_lower, currency_upper, currency_lower) VALUES ('event', null, 0.9, null, 0.7, null, 0.6, null, 0.7, null, 0.9, null, null, null, null, null, 0.9, null, 0.8, null, 0.9, null, 0.5, null, 0.6);
INSERT INTO [DBA].[dbo].[RoleConditions] (role, accuracy_upper, accuracy_lower, sufficiency_upper, sufficiency_lower, precision_upper, precision_lower, consistency_upper, consistency_lower, completeness_upper, completeness_lower, objectivity_upper, objectivity_lower, security_upper, security_lower, uniqueness_upper, uniqueness_lower, informativeness_upper, informativeness_lower, integrity_upper, integrity_lower, conciseness_upper, conciseness_lower, currency_upper, currency_lower) VALUES ('resource', null, 0.5, null, null, null, 0.2, null, 0.7, null, 0.5, null, 0.5, null, 0.8, null, null, null, null, null, 0.9, null, 0.7, null, null);
INSERT INTO [DBA].[dbo].[RoleConditions] (role, accuracy_upper, accuracy_lower, sufficiency_upper, sufficiency_lower, precision_upper, precision_lower, consistency_upper, consistency_lower, completeness_upper, completeness_lower, objectivity_upper, objectivity_lower, security_upper, security_lower, uniqueness_upper, uniqueness_lower, informativeness_upper, informativeness_lower, integrity_upper, integrity_lower, conciseness_upper, conciseness_lower, currency_upper, currency_lower) VALUES ('eventData', null, 0.5, null, null, null, 0.2, null, 0.7, null, 0.3, null, 0.5, null, 0.5, null, null, null, null, null, 0.9, null, 0.7, null, null);
INSERT INTO [DBA].[dbo].[RoleConditions] (role, accuracy_upper, accuracy_lower, sufficiency_upper, sufficiency_lower, precision_upper, precision_lower, consistency_upper, consistency_lower, completeness_upper, completeness_lower, objectivity_upper, objectivity_lower, security_upper, security_lower, uniqueness_upper, uniqueness_lower, informativeness_upper, informativeness_lower, integrity_upper, integrity_lower, conciseness_upper, conciseness_lower, currency_upper, currency_lower) VALUES ('caseData', null, 0.5, null, null, null, 0.2, null, 0.7, null, 0.3, null, 0.5, null, 0.5, null, null, null, null, null, 0.9, null, 0.7, null, null);

-- MIMIC DOMAIN KNOWLEDGE

-- ADMISSIONS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'EMERGENCY;ELECTIVE;URGENT;NEWBORN'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'ADMISSIONS' AND columnname = 'ADMISSION_TYPE'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 58976, [min_value] = 1000000, [max_value] = 1999999
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'ADMISSIONS' AND columnname = 'HADM_ID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 15693
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'ADMISSIONS' AND columnname = 'DIAGNOSIS'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'EMERGENCY ROOM ADMIT;TRANSFER FROM HOSP/EXTRAM;TRANSFER FROM OTHER HEALT;CLINIC REFERRAL/PREMATURE;** INFO NOT AVAILABLE **;TRANSFER FROM SKILLED NUR;TRSF WITHIN THIS FACILITY;HMO REFERRAL/SICK;PHYS REFERRAL/NORMAL DELI'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'ADMISSIONS' AND columnname = 'ADMISSION_LOCATION'

-- CALLOUT
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 34499
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'CALLOUT' AND columnname = 'ROW_ID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'Acknowledged;Revised;Unacknowledged;Reactivated'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'CALLOUT' AND columnname = 'ACKNOWLEDGE_STATUS'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'Discharged;Cancelled'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'CALLOUT' AND columnname = 'CALLOUT_OUTCOME'

-- CAREGIVERS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 7567
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'CAREGIVERS' AND columnname = 'CGID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] ='RO;RT;RN;MD;MedSt;Res;RA;RD;PA;RRT;Rehab;NP'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'CAREGIVERS' AND columnname = 'LABEL'

-- CHARTEVENTS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 330712483
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'CHARTEVENTS' AND columnname = 'ROW_ID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'Manual;Automatic'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'CHARTEVENTS' AND columnname = 'RESULTSTATUS'

-- CPTEVENTS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 573146
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'CPTEVENTS' AND columnname = 'ROW_ID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'ICU;Resp'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'CPTEVENTS' AND columnname = 'COSTCENTER'

-- D_CPT
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 134
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'D_CPT' AND columnname = 'ROW_ID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'Evaluation and management;Surgery;Radiology;Anesthesia;Emerging technology;Pathology and laboratory;Performance measurement;Medicine'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'D_CPT' AND columnname = 'SECTIONHEADER'

-- D_ICD_DIAGNOSES
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 14567
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'D_ICD_DIAGNOSES' AND columnname = 'ROW_ID'

-- D_ICD_PROCEDURES
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 3882
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'D_ICD_PROCEDURES' AND columnname = 'ROW_ID'

-- D_ITEMS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 12487
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'D_ITEMS' AND columnname = 'ROW_ID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'carevue;metavision'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'D_ITEMS' AND columnname = 'DBSOURCE'

-- D_LABITEMS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 753
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'D_LABITEMS' AND columnname = 'ROW_ID'

-- DATETIMEEVENTS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 4485937
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'DATETIMEEVENTS' AND columnname = 'ROW_ID'

-- DIAGNOSES_ICD
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 651047
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'DIAGNOSES_ICD' AND columnname = 'ROW_ID'

-- DRGCODES
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 125557
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'DRGCODES' AND columnname = 'ROW_ID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'HCFA;APR'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'DRGCODES' AND columnname = 'DRG_TYPE'

-- ICUSTAYS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 61532
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'ICUSTAYS' AND columnname = 'ROW_ID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'carevue;metavision'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'ICUSTAYS' AND columnname = 'DBSOURCE'

-- INPUTEVENTS_CV
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 17527935
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'INPUTEVENTS_CV' AND columnname = 'ROW_ID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [min_value] = 30000, [max_value] = 1000000
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'INPUTEVENTS_CV' AND columnname = 'ITEMID'

-- INPUTEVENTS_MV
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 3618991
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'INPUTEVENTS_MV' AND columnname = 'ROW_ID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [min_value] = 30000, [max_value] = 1000000
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'INPUTEVENTS_MV' AND columnname = 'ITEMID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [min_value] = 2, [max_value] = 200
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'INPUTEVENTS_MV' AND columnname = 'PATIENTWEIGHT'

-- LABEVENTS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 27854055
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'LABEVENTS' AND columnname = 'ROW_ID'

-- MICROBIOLOGYEVENTS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 631726
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'MICROBIOLOGYEVENTS' AND columnname = 'ROW_ID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'S;R;I;P'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'MICROBIOLOGYEVENTS' AND columnname = 'INTERPRETATION'

-- NOTEEVENTS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 2083180
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'NOTEEVENTS' AND columnname = 'ROW_ID'

-- OUTPUTEVENTS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 4349218
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'OUTPUTEVENTS' AND columnname = 'ROW_ID'

-- PATIENTS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 46520
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'PATIENTS' AND columnname = 'SUBJECT_ID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'M;F'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'PATIENTS' AND columnname = 'GENDER'

-- PRESCRIPTIONS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 4156450
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'PRESCRIPTIONS' AND columnname = 'ROW_ID'

-- PROCEDUREEVENTS_MV
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 258066
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'PROCEDUREEVENTS_MV' AND columnname = 'ROW_ID'

-- PROCEDURES_ICD
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 240095
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'PROCEDURES_ICD' AND columnname = 'ROW_ID'

-- SERVICES
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 73343
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'SERVICES' AND columnname = 'ROW_ID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'CMED;CSURG;DENT;ENT;GU;GYN;MED;NB;NBB;NMED;NSURG;OBS;ORTHO;OMED;PSURG;PSYCH;SURG;TRAUM;TSURG;VSURG'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'SERVICES' AND (columnname = 'CURR_SERVICE' OR columnname = 'PREV_SERVICE')

-- TRANSFERS
UPDATE [DBA].[dbo].[DomainKnowledge] SET [distinct_values] = 261897
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'TRANSFERS' AND columnname = 'ROW_ID'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'admit;transfer;discharge'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'TRANSFERS' AND columnname = 'EVENTTYPE'

UPDATE [DBA].[dbo].[DomainKnowledge] SET [categories] = 'CCU;CSRU;MICU;NICU;NWARD;SICU;TSICU'
WHERE tablecatalog = 'MIMIC' AND tableschema = 'dbo' AND tablename = 'TRANSFERS' AND (columnname = 'CURR_CAREUNIT' OR columnname = 'PREV_CAREUNIT')

RETURN 0

END
