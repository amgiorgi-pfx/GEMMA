lk_infusion_drugsreferenze

    Source DATABASE identifier, e.g. UniProt, ENSEMBL, NCBI Gene OR ChEBI identifier
     Reactome Pathway Stable identifier
    URL
    EVENT (Pathway OR Reaction) NAME
    Evidence CODE
    Species


CREATE TABLE uniprot(
InternalID VARCHAR(20),
PathwayID VARCHAR(15),
URL VARCHAR(150),
EventName VARCHAR(100),
EvidenceCode VARCHAR(5),
Species VARCHAR(20)
)

TRUNCATE uniprot
LOAD DATA INFILE 'd:\\temp\\ongoing_projects\\EBRIS\\ReactomeGraphDB\\\\Main_datasets\\UniProt2Reactome.txt' INTO TABLE uniprot FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'
---keep only homo sapiens

DELETE FROM uniprot WHERE Species <> 'Homo sapiens'

SELECT DISTINCT EvidenceCode, Species FROM uniprot



CREATE TABLE ncbi(
InternalID VARCHAR(20),
PathwayID VARCHAR(15),
URL VARCHAR(150),
EventName VARCHAR(250),
EvidenceCode VARCHAR(5),
Species VARCHAR(30)
)

TRUNCATE ncbi
LOAD DATA INFILE 'd:\\temp\\ongoing_projects\\EBRIS\\ReactomeGraphDB\\\\Main_datasets\\NCBI2Reactome.txt' INTO TABLE ncbi FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'

SELECT DISTINCT EvidenceCode, Species FROM ncbi

DELETE FROM ncbi WHERE Species <> 'Homo sapiens'



SELECT * FROM chebi WHERE EventName LIKE 'PGG2 is reduced to PGH2 by PTGS1'
SELECT * FROM ncbi WHERE EventName LIKE 'PGG2 is reduced to PGH2 by PTGS1'
SELECT * FROM uniprot WHERE EventName LIKE 'PGG2 is reduced to PGH2 by PTGS1'



CREATE TABLE chebi(
InternalID VARCHAR(20),
PathwayID VARCHAR(15),
URL VARCHAR(150),
EventName VARCHAR(250),
EvidenceCode VARCHAR(5),
Species VARCHAR(30)
)

TRUNCATE chebi
LOAD DATA INFILE 'd:\\temp\\ongoing_projects\\EBRIS\\ReactomeGraphDB\\Main_datasets\\ChEBI2Reactome.txt' INTO TABLE chebi FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'

SELECT DISTINCT EvidenceCode, Species FROM ncbi

SELECT DISTINCT species FROM uniprot
SELECT DISTINCT species FROM ncbi
SELECT DISTINCT species FROM chebi

TRUNCATE TABLE lk_chebi_metabolites
SELECT * FROM lk_chebi_metabolites WHERE chebiID = '47828'

/*esempio di crossnavigazione*/
SELECT * FROM lk_chebi_metabolites WHERE chebiID IN (SELECT InternalID FROM chebi WHERE PathwayID = 'R-HSA-156582')
SELECT * FROM lk_chebi_metabolites WHERE chebiID IN (SELECT InternalID FROM chebi WHERE PathwayID = 'R-HSA-1257604')



SELECT * FROM lk_chebi_metabolites WHERE Metabolite LIKE '%glycolic%'


DELETE FROM lk_chebi_metabolites WHERE ChebiID IS NULL OR ChebiID = ''
SELECT COUNT(*) AS ricorrenze, ChebiID FROM (SELECT DISTINCT * FROM lk_chebi_metabolites) d GROUP BY ChebiID HAVING COUNT(*) > 1
SELECT * FROM lk_chebi_metabolites WHERE ChebiID IN('133096','131924','1030794')

UPDATE chebi c INNER JOIN lk_chebi_metabolites m ON c.INternalID = m.ChebiID
SET c.Metabolite = m.Metabolite WHERE c.Species = 'Homo sapiens'

SELECT * FROM chebi WHERE PathwayID = 'R-HSA-156582'
SELECT * FROM chebi WHERE PathwayID = 'R-HSA-1257604'

47828	R-HSA-196791	Vitamin D (calciferol) metabolism

SELECT * FROM chebi WHERE PathwayID LIKE '%R-HSA-73843%'ncbi


SELECT * FROM ncbi WHERE EventName IN (SELECT DISTINCT EventName FROM uniprot)  /*215139*/
SELECT * FROM uniprot WHERE EventName IN (SELECT DISTINCT EventName FROM ncbi)  /*286674*/
SELECT * FROM chebi WHERE EventName IN (SELECT DISTINCT EventName FROM ncbi) /*91097*/
SELECT * FROM chebi WHERE EventName IN (SELECT DISTINCT EventName FROM uniprot) /*91093*/
SELECT * FROM ncbi WHERE InternalID IN (SELECT DISTINCT GeneID FROM lk_gene_info) /*2600*/
SELECT * FROM ncbi WHERE Species LIKE 'Homo sapiens' /*46658*/
SELECT DISTINCT Symbol FROM lk_gene_info
/*Pathway vertex*/
SELECT DISTINCT PathwayID, URL, EventName AS PathwayName FROM chebi WHERE Species LIKE 'Homo sapiens' UNION SELECT DISTINCT PathwayID, URL, EventName AS PathwayName FROM ncbi WHERE Species LIKE 'Homo sapiens' UNION SELECT DISTINCT PathwayID, URL, EventName AS PathwayName FROM uniprot WHERE Species LIKE 'Homo sapiens'


/*metabolite vertex*/
SELECT * FROM 
SELECT COUNT(*), MetaboliteID FROM ( 
SELECT ChebiID AS MetaboliteID, Metabolite AS MetaboliteName FROM lk_chebi_metabolites WHERE chebiID IN (SELECT InternalID FROM chebi)
) d GROUP BY MetaboliteID HAVING COUNT(*) > 1


SELECT DISTINCT InternalID AS MetaboliteID, Metabolite AS MetaboliteName FROM chebi WHERE Metabolite IS NOT NULL


/*recursively create edges*/
SELECT CONCAT('CREATE EDGE PathwayToMetabolite FROM (SELECT FROM pathway WHERE PathwayID = \'', PathwayID, '\') TO (SELECT FROM metabolite WHERE MetaboliteID = \'', InternalID, '\');') FROM chebi WHERE species LIKE 'Homo sapiens' AND Metabolite IS NOT NULL

/*gene vertex*/
UPDATE ncbi n INNER JOIN lk_gene_info g ON n.InternalID = g.GeneID SET n.GeneDesc = g.Full_name_from_nomenclature_authority, n.GeneType = g.type_of_gene, n.GeneCode = g.Symbol
SELECT DISTINCT  InternalID AS GeneID, GeneDesc AS GeneName, GeneType, GeneCode FROM ncbi WHERE GeneDesc IS NOT NULL


/*recursively create edges*/
SELECT DISTINCT CONCAT('CREATE EDGE PathwayToGene FROM (SELECT FROM pathway WHERE PathwayID = \'', PathwayID, '\') TO (SELECT FROM gene WHERE GeneID = \'', InternalID, '\');') FROM ncbi WHERE GeneCode IS NOT NULL  AND Species LIKE 'Homo sapiens' 


SELECT PAthwayID FROM ncbi WHERE GeneType IS NOT NULL AND PathwayID IN (SELECT PathwayID FROM chebi WHERE Metabolite IS NOT NULL)


/*demographics*/
LOAD DATA INFILE 'd:\\temp\\ongoing_projects\\EBRIS\\ReactomeGraphDB\\demographics.txt' INTO TABLE demographics FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r\n'
UPDATE demographics SET Sex = CASE WHEN Sex = '1' THEN 'F' WHEN Sex = '2' THEN 'M' ELSE 'U' END 
UPDATE demographics SET GlutenIntroduction = NULL WHERE GlutenIntroduction = 'Never?'
UPDATE demographics SET GlutenIntroduction = NULL WHERE GlutenIntroduction = 'Never'
UPDATE demographics SET GlutenIntroduction = NULL WHERE GlutenIntroduction = '#N/A'
UPDATE demographics SET GlutenIntroduction =  REPLACE(GlutenIntroduction, ' Months', '')


SELECT PersonID, Sex, BreastFeeding, DeliveryMode, GlutenIntroduction, DiseaseOnset, DOB FROM demographics
UPDATE demographics SET DOB = NULL WHERE DOB = ''

/*GENE VARIANTS*/
gene_variants_reduced


SELECT DISTINCT Chr_pos, Consequence, Classification, Gene AS GeneCode, Hgvsc FROM gene_variants_reduced WHERE Hgvsc IS NOT NULL


UPDATE gene_variants_reduced SET PersonID = LEFT(RIGHT(FileName,16),11)
UPDATE gene_variants_reduced SET PersonID = UPPER(PersonID)

SELECT COUNT(*) FROM gene_variants_reduced WHERE PersonID  IN (SELECT PersonID FROM demographics)

SELECT LEFT(RIGHT(FileName,16),11) FROM gene_variants_reduced

SELECT * FROM gene_variants_reduced WHERE Gene NOT IN (SELECT Symbol FROM lk_gene_info)

SELECT COUNT(*) AS occurrences, Chr_pos FROM gene_variants_reduced GROUP BY Chr_pos HAVING COUNT(*) > 1

SELECT * FROM gene_variants_reduced WHERE Chr_pos = 'chr10:124988395'
SELECT DISTINCT assessment_status FROM gene_variants_reduced

SELECT * FROM gene_variants_reduced WHERE Chr_pos IN('chr1:16759176','chr9:137882854','chr1:16757511')

SELECT PersonID, Gene AS GeneCode, Classification, Consequence, Chr_pos, HGVSC, HGVSP, GT FROM gene_variants_reduced


SELECT DISTINCT InternalID AS GeneID, GeneDesc AS GeneName, GeneType, GeneCode FROM ncbi WHERE GeneDesc IS NOT NULL



/*create VariantToGene edge*/
/*recursively create edges*/
SELECT DISTINCT CONCAT('CREATE EDGE VariantToGene FROM (SELECT FROM gene_variant WHERE GeneCode = \'', GeneCode, '\') TO (SELECT FROM gene WHERE GeneCode = \'', GeneCode, '\');') FROM ncbi WHERE GeneCode IS NOT NULL AND Species LIKE 'Homo sapiens' 

SELECT DISTINCT CONCAT('CREATE EDGE HasVariant FROM (SELECT FROM person WHERE PersonID = \'', PersonID, '\') TO (SELECT FROM gene_variant WHERE PersonID = \'', PersonID, '\');') FROM gene_variants_reduced 

SELECT COUNT(*) FROM metabolomics
/*7434*/

SELECT COUNT(*) FROM metabolomics WHERE MetaboliteID IN (SELECT ChebiID FROM lk_chebi_metabolites)
/*5664*/
SELECT DISTINCT MetaboliteID FROM metabolomics WHERE MetaboliteID NOT IN (SELECT ChebiID FROM lk_chebi_metabolites)


/*Metabolomics2Metabolite*/
SELECT DISTINCT CONCAT('CREATE EDGE MetabolomicsToMetabolite FROM (SELECT FROM metabolomics WHERE MetaboliteID = \'', MetaboliteID, '\') TO (SELECT FROM metabolite WHERE MetaboliteID = \'', MetaboliteID, '\');') FROM metabolomics 


/*MetabolomicsSample*/
SELECT DISTINCT CONCAT('CREATE EDGE MetabolomicsSample FROM (SELECT FROM person WHERE PersonID = \'', PersonID, '\') TO (SELECT FROM metabolomics WHERE PersonID = \'', PersonID, '\');') FROM demographics



/*metabolomics*/
LOAD DATA INFILE 'd:\\temp\\ongoing_projects\\EBRIS\\ReactomeGraphDB\\metabolomics_data_converted.txt' INTO TABLE metabolomics FIELDS TERMINATED BY '|' LINES TERMINATED BY '\r\n'

SELECT CONCAT('create vertex metabolomics CONTENT { \"PersonID\" : \"', PersonID, '\", \"Month\" : \"', MONTH, '\", \"MetaboliteID\" : \"', MetaboliteID, '\", \"Value\" : \"', VALUE, '\"}') FROM metabolomics


/*#########################################################################################################################################################################*/
/*#########################################################################################################################################################################*/
/*#########################################################################################################################################################################*/
/*orientDB queries*/
SELECT MetaboliteName, MetaboliteID, IN('PathwayToMetabolite').OUT('PathwayToGene').GeneName, IN('PathwayToMetabolite').OUT('PathwayToGene').GeneType FROM metabolite LIMIT 1

SELECT FROM (
SELECT BreastFeeding, Sex, DeliveryMode, OUT('MetabolomicsSample').Value AS VL, OUT('MetabolomicsSample').Month, OUT('MetabolomicsSample').MetaboliteID FROM person WHERE PersonID LIKE '02-GEMM-030') WHERE VL > 0.1


SELECT expand(path) FROM (SELECT shortestPath(#53:28, #53:27) AS path )

SELECT expand($path) FROM ( TRAVERSE BOTH() FROM #53:28 WHILE $depth <= 20 ) WHERE @rid = #53:37

---filtro per attributi di un edge
SELECT expand(outE('consumes_drug')[QTY > 1].inV()) FROM person


#56:23 / #56:26
SELECT DISTINCT PersonID, CaseControl FROM metabolomics WHERE PersonID IN (SELECT DISTINCT PersonID FROM gene_variants_reduced)


SELECT Gene, COUNT(DISTINCT PersonID) AS riocrrenze FROM gene_variants_reduced GROUP BY Gene ORDER BY  COUNT(DISTINCT PersonID) ASC






TRUNCATE pathways
CREATE TABLE pathways
(
PathwayID VARCHAR(15),
PathwayName VARCHAR(300),
Species VARCHAR(30)
)


LOAD DATA INFILE 'c:\\temp\\ReactomePathways.txt' INTO TABLE pathways FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'


gene_variants

SELECT COUNT(*) FROM ncbi WHERE InternalID IN (SELECT GeneID FROM lk_gene_info)
SELECT COUNT(*) FROM chebi WHERE InternalID NOT IN (SELECT ChebiID FROM lk_chebi_metabolites)

SELECT * FROM metabolomics WHERE MetaboliteID NOT IN (SELECT ChebiID FROM lk_chebi_metabolites)




SELECT * FROM lk_chebi_metabolites WHERE ChebiID = 803536








