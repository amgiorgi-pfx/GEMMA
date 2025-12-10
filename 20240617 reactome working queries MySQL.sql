create table lk_metabolites_mapping (
MetaboliteName varchar(50),
MSILevel tinyint,
HMDB varchar(20),
PubChem varchar(10),
ChEBI varchar(10),
KEGG varchar(10),
METLIN varchar(10),
SMILES varchar(20)
)
load data local infile 'd:\\temp\\metabolites.csv' into table lk_metabolites_mapping ignore 1 lines
LOAD DATA LOCAL INFILE 'd:\\temp\\metabolites.csv' INTO TABLE lk_metabolites_mapping FIELDS TERMINATED BY ';' IGNORE 1 lines
LOAD DATA LOCAL INFILE 'd:\\temp\\metabolites.csv' INTO TABLE lk_metabolites_mapping FIELDS TERMINATED BY ';' OPTIONALLY ENCLOSED BY '"' IGNORE 1 LINES



---popolo identifier nuova colonna
select * from metabolomics_metadata
select CONCAT('0', SUBSTR(ID_sample,1,9)) from metabolomics_metadata where Center = '01-USA'
select SUBSTR(ID_sample,1,10) from metabolomics_metadata where Center <> '01-USA'

---popolo timepoint nuova colonna
select SUBSTRING_INDEX(SUBSTRING_INDEX(ID_Sample, '-',-3),'-',1) from metabolomics_metadata

update metabolomics_metadata set TimePoint = SUBSTRING_INDEX(SUBSTRING_INDEX(ID_Sample, '-',-3),'-',1)

SELECT SUBSTRING_INDEX('Ann Smith John', ' ', 2);

update metabolomics_metadata set Identifier = CONCAT('0', SUBSTR(ID_sample,1,9)) where Center = '01-USA'
update metabolomics_metadata set Identifier = SUBSTR(ID_sample,1,10) where Center <> '01-USA'

---metabolomicsTimepoint
select 'CREATE' as q
union all
select CONCAT('(:MetabolomicsTimepoint{ID_Sample : "', ID_Sample, '", Timepoint : "', TimePoint, '", Identifier : "', Identifier, '", ID_Theoreo : ', ID_Theoreo, ', Center : "', Center, '",  Classe : "', Classe, '"}),') as q from  metabolomics_metadata 

select Center, ID_Theoreo, ID_sample, Classe, Gender, Age_in_Months, Date_of_Dx from metabolomics_metadata 



---collego i MetabolomicsTimepoint ai GemmaPerson
select CONCAT('MATCH (p:GemmaPerson {Identifier: "', Identifier, '"}),(mt:MetabolomicsTimepoint{Identifier: "', Identifier, '", Timepoint : "', TimePoint, '"}) CREATE (p) -[:metabolomicsTimepoint {Timepoint: "', Timepoint, '"}]-> (mt);') from metabolomics_metadata





drop table if exists gemma_cases_ctrl;
create table gemma_cases_ctrl (
CaseCtrl varchar(10),
Identifier varchar(10) not null primary key,
Sex varchar(6),
DateOfBirth date,
AgeAtDiagnosis int NULL,
Nationality varchar(4)
)
LOAD DATA LOCAL INFILE 'd:\\temp\\gemma_cases_ctrl.txt' INTO TABLE gemma_cases_ctrl FIELDS TERMINATED BY '\t'

update gemma_cases_ctrl set AgeAtDiagnosis = 0 where AgeAtDiagnosis = NULL


select 'CREATE' as q
union all
select CONCAT('(:GemmaPerson{identifier : "',Identifier,'", displayName : "', Identifier, '", caseCtrl : "',CaseCtrl, '",Sex : "',Sex, '",DateOfBirth : "', DateOfBirth, '",AgeAtDiagnosis : ', AgeAtDiagnosis, ',Nationality : "', Nationality, '"}),') 
as q from  gemma_cases_ctrl


select * from gemma_cases_ctrl





MATCH (m:ReferenceMolecule {identifier: "15428"}),(mt:MetabolomicsTimepoint{ID_Theoreo: 130}) CREATE (m) <-[:metabolite{Value: 76.48065824}]- (mt);



/*VERTICA*/
SELECT ID_Theoreo, EXPLODE(ARRAY[_6643,_6857,_1316] USING PARAMETERS explode_count=1, skip_partitioning=true)OVER() as Metabolite 
FROM ebris.ft_metabolomics_raw

select * from ebris.ft_metabolomics

---creo le connessioni tra Timepoints e metaboliti ChEBI
select 'MATCH (m:ReferenceMolecule {identifier: "' || Metabolite || '"}),(mt:MetabolomicsTimepoint{ID_Theoreo: ' || ID_Theoreo || '}) CREATE (m) <-[:metabolite{Value: ' || Value || '}]- (mt);' from ebris.ft_metabolomics
order by ID_Theoreo, Metabolite LIMIT 100  OFFSET 0 
select 'MATCH (m:ReferenceMolecule {identifier: "' || Metabolite || '"})' from ebris.ft_metabolomics 





/*nuovo database MySQL 2025*/

SELECT * FROM ft_metabolomics f where left(f.Metabolite ,1) = '_'

2-3-Butanediol
2-Hydroxy-3-methylbutyric acid
2-Hydroxyglutaric acid
2-Hydroxyisocaproic acid
2-Methylbenzoic acid
2-Methyl-Butyric acid
2-Oxovaleric acid
3-Hydroxybutyric acid
3-Methyl-2-oxovaleric acid
3-Phenyllactic acid





select f.Interventistico_SI__NO, count(distinct(f.ID_sample)) as Occurrences from ft_metabolomics f group by f.Interventistico_SI__NO 


427 samples from observational 
150 distinct enrolled person

209 samples from interventional
48 distinct enrolled person



select distinct LEFT(f.ID_sample,6) as GEMMA_PERSON from ft_metabolomics f where Interventistico_SI__NO = 'NO'
---150 observational


select distinct LEFT(f.ID_sample,6) as GEMMA_PERSON from ft_metabolomics f where Interventistico_SI__NO = 'SI'
---48 observational


---quanti hanno sia interventistico che observational
43 sovrapposti





create table genomic_patients(
Sample varchar(20),
Patient varchar(20)
)
insert into genomic_patients values
('01-010-GMA-FA'	,'01-010-GMA-FA'),
('01-010-GMA-MA'	,'01-010-GMA-MA'),
('01-010-GMA-S13'	,'01-010-GMA-S13'),
('01-010-GMA-12M'	,'01-010-GMA-12M'),
('01-011-GMA-FA'	,'01-011-GMA-FA'),
('01-011-GMA-MA'	,'01-011-GMA-MA'),
('01-013-GMA-FA'	,'01-013-GMA-FA'),
('01-013-GMA-MA'	,'01-013-GMA-MA'),
('01-013-GMA-S14'	,'01-013-GMA-S14'),
('01-013-GMA-12M'	,'01-013-GMA-12M'),
('01-014-GMA-FA'	,'01-014-GMA-FA'),
('01-014-GMA-MA'	,'01-014-GMA-MA'),
('01-016-GMA-MA'	,'01-016-GMA-MA'),
('01-016-GMA-S12'	,'01-016-GMA-S12'),
('01-016-GMA-12M'	,'01-016-GMA-12M'),
('02-001-GMA-FA'	,'02-001-GMA-FA'),
('02-001-GMA-MA'	,'02-001-GMA-MA'),
('02-001-GMA-SI5'	,'02-001-GMA-SI5'),
('02-006-GMA-FA'	,'02-006-GMA-FA'),
('02-006-GMA-MA'	,'02-006-GMA-MA'),
('02-016-GMA-12M'	,'02-016-GMA-12M'),
('02-018-GMA-12M'	,'02-018-GMA-12M'),
('02-020-GMA-FA'	,'02-020-GMA-FA'),
('02-020-GMA-MA'	,'02-020-GMA-MA'),
('02-022-GMA-FA'	,'02-022-GMA-FA'),
('02-022-GMA-MA'	,'02-022-GMA-MA'),
('02-022-GMA-SI19'	,'02-022-GMA-SI19'),
('02-022-GMA-SS18'	,'02-022-GMA-SS18'),
('02-022-GMA-12M'	,'02-022-GMA-12M'),
('02-023-GMA-FA'	,'02-023-GMA-FA'),
('02-023-GMA-MA'	,'02-023-GMA-MA'),
('02-023-GMA-SI3'	,'02-023-GMA-SI3'),
('02-023-GMA-12M'	,'02-023-GMA-12M'),
('02-024-GMA-FA'	,'02-024-GMA-FA'),
('02-024-GMA-MA'	,'02-024-GMA-MA'),
('02-025-GMA-FA'	,'02-025-GMA-FA'),
('02-025-GMA-MA'	,'02-025-GMA-MA'),
('02-030-GMA-FA'	,'02-030-GMA-FA'),
('02-030-GMA-MA'	,'02-030-GMA-MA'),
('02-031-GMA-FA'	,'02-031-GMA-FA'),
('02-031-GMA-MA'	,'02-031-GMA-MA'),
('02-031-GMA-SI4'	,'02-031-GMA-SI4'),
('02-031-GMA-12M'	,'02-031-GMA-12M'),
('03-002-GMA-FA'	,'03-002-GMA-FA'),
('03-002-GMA-MA'	,'03-002-GMA-MA'),
('03-002-GMA-SI6'	,'03-002-GMA-SI6'),
('03-002-GMA-M49'	,'03-002-GMA-M49'),
('03-009-GMA-59M'	,'03-009-GMA-59M'),
('03-013-GMA-FA'	,'03-013-GMA-FA'),
('03-013-GMA-MA'	,'03-013-GMA-MA'),
('03-013-GMA-SI9'	,'03-013-GMA-SI9'),
('03-013-GMA-61M'	,'03-013-GMA-61M'),
('03-020-GMA-MA'	,'03-020-GMA-MA'),
('03-020-GMA-SI3'	,'03-020-GMA-SI3'),
('03-020-GMA-34M'	,'03-020-GMA-34M'),
('03-022-GMA-FA'	,'03-022-GMA-FA'),
('03-022-GMA-MA'	,'03-022-GMA-MA'),
('03-022-GMA-SI13'	,'03-022-GMA-SI13'),
('03-023-GMA-FA'	,'03-023-GMA-FA'),
('03-023-GMA-MA'	,'03-023-GMA-MA'),
('03-024-GMA-FA'	,'03-024-GMA-FA'),
('03-024-GMA-MA'	,'03-024-GMA-MA'),
('03-030-GMA-MA'	,'03-030-GMA-MA'),
('03-030-GMA-SI12'	,'03-030-GMA-SI12'),
('03-034-GMA-FA'	,'03-034-GMA-FA'),
('03-034-GMA-MA'	,'03-034-GMA-MA'),
('03-034-GMA-SI5'	,'03-034-GMA-SI5'),
('03-034-GMA-25M'	,'03-034-GMA-25M'),
('03-037-GMA-FA'	,'03-037-GMA-FA'),
('03-037-GMA-MA'	,'03-037-GMA-MA'),
('03-037-GMA-SI6'	,'03-037-GMA-SI6'),
('03-040-GMA-FA'	,'03-040-GMA-FA'),
('03-040-GMA-MA'	,'03-040-GMA-MA'),
('03-040-GMA-SI4'	,'03-040-GMA-SI4'),
('03-040-GMA-12M'	,'03-040-GMA-12M'),
('03-041-GMA-SI5'	,'03-041-GMA-SI5'),
('03-041-GMA-24M'	,'03-041-GMA-24M'),
('03-042-GMA-FA'	,'03-042-GMA-FA'),
('03-042-GMA-MA'	,'03-042-GMA-MA'),
('03-042-GMA-SI7'	,'03-042-GMA-SI7'),
('03-042-GMA-28M'	,'03-042-GMA-28M'),
('03-046-GMA-FA'	,'03-046-GMA-FA'),
('03-046-GMA-MA'	,'03-046-GMA-MA'),
('03-046-GMA-SI8'	,'03-046-GMA-SI8'),
('03-047-GMA-FA'	,'03-047-GMA-FA'),
('03-047-GMA-MA'	,'03-047-GMA-MA'),
('03-047-GMA-SI4'	,'03-047-GMA-SI4'),
('03-048-GMA-SI4'	,'03-048-GMA-SI4'),
('03-052-GMA-FA'	,'03-052-GMA-FA'),
('03-052-GMA-MA'	,'03-052-GMA-MA'),
('03-052-GMA-SI7'	,'03-052-GMA-SI7'),
('03-053-GMA-FA'	,'03-053-GMA-FA'),
('03-053-GMA-MA'	,'03-053-GMA-MA'),
('03-053-GMA-SI8'	,'03-053-GMA-SI8'),
('03-054-GMA-FA'	,'03-054-GMA-FA'),
('03-054-GMA-MA'	,'03-054-GMA-MA'),
('03-054-GMA-SI7'	,'03-054-GMA-SI7'),
('03-057-GMA-FA'	,'03-057-GMA-FA'),
('03-057-GMA-MA'	,'03-057-GMA-MA'),
('03-057-GMA-SI2'	,'03-057-GMA-SI2'),
('03-057-GMA-41M'	,'03-057-GMA-41M'),
('03-058-GMA-FA'	,'03-058-GMA-FA'),
('03-058-GMA-MA'	,'03-058-GMA-MA'),
('03-058-GMA-SI9'	,'03-058-GMA-SI9'),
('03-060-GMA-FA'	,'03-060-GMA-FA'),
('03-060-GMA-MA'	,'03-060-GMA-MA'),
('03-060-GMA-SI3'	,'03-060-GMA-SI3'),
('03-063-GMA-FA'	,'03-063-GMA-FA'),
('03-063-GMA-MA'	,'03-063-GMA-MA'),
('03-063-GMA-SI11'	,'03-063-GMA-SI11'),
('03-065-GMA-FA'	,'03-065-GMA-FA'),
('03-065-GMA-MA'	,'03-065-GMA-MA'),
('03-068-GMA-FA'	,'03-068-GMA-FA'),
('03-068-GMA-MA'	,'03-068-GMA-MA'),
('03-068-GMA-SI5'	,'03-068-GMA-SI5'),
('03-068-GMA-33M'	,'03-068-GMA-33M'),
('03-073-GMA-MA'	,'03-073-GMA-MA'),
('03-073-GMA-SI7'	,'03-073-GMA-SI7'),
('03-074-GMA-FA'	,'03-074-GMA-FA'),
('03-074-GMA-MA'	,'03-074-GMA-MA'),
('03-074-GMA-SI4'	,'03-074-GMA-SI4'),
('03-074-GMA-18M'	,'03-074-GMA-18M'),
('03-076-GMA-FA'	,'03-076-GMA-FA'),
('03-076-GMA-MA'	,'03-076-GMA-MA'),
('03-077-GMA-FA'	,'03-077-GMA-FA'),
('03-077-GMA-MA'	,'03-077-GMA-MA'),
('03-090-GMA-FA'	,'03-090-GMA-FA'),
('03-090-GMA-MA'	,'03-090-GMA-MA'),
('03-090-GMA-SI14'	,'03-090-GMA-SI14'),
('03-091-GMA-FA'	,'03-091-GMA-FA'),
('03-091-GMA-MA'	,'03-091-GMA-MA'),
('03-091-GMA-SI9'	,'03-091-GMA-SI9'),
('03-092-GMA-FA'	,'03-092-GMA-FA'),
('03-092-GMA-MA'	,'03-092-GMA-MA'),
('03-092-GMA-SI2'	,'03-092-GMA-SI2'),
('03-095-GMA-FA'	,'03-095-GMA-FA'),
('03-095-GMA-MA'	,'03-095-GMA-MA'),
('03-095-GMA-SI10'	,'03-095-GMA-SI10'),
('03-096-GMA-FA'	,'03-096-GMA-FA'),
('03-096-GMA-MA'	,'03-096-GMA-MA'),
('03-096-GMA-SI3'	,'03-096-GMA-SI3'),
('03-103-GMA-FA'	,'03-103-GMA-FA'),
('03-103-GMA-MA'	,'03-103-GMA-MA'),
('03-103-GMA-SI6'	,'03-103-GMA-SI6'),
('03-105-GMA-FA'	,'03-105-GMA-FA'),
('03-105-GMA-MA'	,'03-105-GMA-MA'),
('03-106-GMA-FA'	,'03-106-GMA-FA'),
('03-106-GMA-MA'	,'03-106-GMA-MA'),
('03-106-GMA-SI7'	,'03-106-GMA-SI7'),
('03-109-GMA-MA'	,'03-109-GMA-MA'),
('03-109-GMA-SI3'	,'03-109-GMA-SI3'),
('03-110-GMA-FA'	,'03-110-GMA-FA'),
('03-110-GMA-MA'	,'03-110-GMA-MA'),
('03-110-GMA-SI3'	,'03-110-GMA-SI3'),
('03-110-GMA-12M'	,'03-110-GMA-12M'),
('03-111-GMA-FA'	,'03-111-GMA-FA'),
('03-111-GMA-MA'	,'03-111-GMA-MA'),
('03-111-GMA-SI9'	,'03-111-GMA-SI9'),
('03-111-GMA-12M'	,'03-111-GMA-12M'),
('03-115-GMA-FA'	,'03-115-GMA-FA'),
('03-115-GMA-MA'	,'03-115-GMA-MA'),
('03-115-GMA-6M'	,'03-115-GMA-6M'),
('03-137-GMA-FA'	,'03-137-GMA-FA'),
('03-137-GMA-MA'	,'03-137-GMA-MA'),
('03-137-GMA-SI4'	,'03-137-GMA-SI4'),
('03-137-GMA-22M'	,'03-137-GMA-22M'),
('03-138-GMA-FA'	,'03-138-GMA-FA'),
('03-138-GMA-MA'	,'03-138-GMA-MA'),
('03-138-GMA-24M'	,'03-138-GMA-24M'),
('03-139-GMA-FA'	,'03-139-GMA-FA'),
('03-139-GMA-MA'	,'03-139-GMA-MA'),
('03-139-GMA-SI4'	,'03-139-GMA-SI4'),
('03-139-GMA-20M'	,'03-139-GMA-20M'),
('03-150-GMA-FA'	,'03-150-GMA-FA'),
('03-150-GMA-MA'	,'03-150-GMA-MA'),
('03-150-GMA-SI5'	,'03-150-GMA-SI5'),
('03-150-GMA-12M'	,'03-150-GMA-12M')


load data infile 'c:\\temp\\Metadata.csv' into table metabolomics_metadata fields terminated by ';' null as '' IGNORE 1 LINES


update metabolomics_metadata set ID_sample_clean = ID_sample 

update metabolomics_metadata m set ID_sample_clean = replace(m.ID_sample_clean, '-ST-THE1', '')

---genomic and metabolomics overlap
select count(*) as occurrences, ID from (
select distinct LEFT(m.ID_sample,6) as ID, 'meta' as source from metabolomics_metadata m 
union all
select distinct LEFT(g.Patient,6) as ID, 'geno' as source from genomic_patients g  
) d group by ID having occurrences > 1



----NUOVO SCHEMA POSTGRES
create schema bio

