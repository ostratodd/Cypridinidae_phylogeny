echo "Next add sequences "
mysql -u root -p9DogsinaTree < setup.sql

#Genome has different headers use modified script #3
../../scripts/aa2sql3.pl pep/Darwinula_stevensoni.fas.transdecoder.pep

#Recent transcriptomes have different specific headers, use modified script
for FILENAME in pep/*Niko*.pep
do
../../scripts/aa2sql2.pl  $FILENAME
done


for FILENAME in pep/*.fa
do
../../scripts/aa2sql.pl  $FILENAME
done

#Add index
mysql -u root -p9DogsinaTree < index.sql



echo "Now adding orthogroups to sql"
../../scripts/orthtable2sql.pl /Users/oakley/Documents/GitHub/Cypridinidae_phylogeny/orthologs/pep/Orthofinder/Results_Feb27_1/Orthogroups/Orthogroups.tsv

#Name of genome orthogroups do not match
mysql -u root -p < replace.sql

