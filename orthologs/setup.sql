#mysql.server start

DROP DATABASE ellis2021;
CREATE DATABASE ellis2021;
USE ellis2021;

CREATE TABLE orthogroup
(
og varchar(50),
assemblyid varchar(300)
);

CREATE TABLE aaseqs
(
id int unsigned not null auto_increment primary key,
sampleid varchar(100),
geneid varchar(50),
assemblyid varchar(300),
cluster varchar(5),
gene varchar(4),
isoform varchar(4),
gstatus varchar(50),
aa text
);

