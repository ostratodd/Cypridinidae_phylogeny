#Script by Rebecca Varney

#Ortholog Searching:
orthofinder -t 20 -I 2.1 -M msa -T fasttree -f ./pep -o ./OrthoFinder_results

#OrthoFinder CleanUp:

### FIRST CHANGE THESE:
MIN_SEQUENCE_LENGTH = 20
MIN_TAXA = 15 #I usually pick 50% of my total taxa
CORES = 32 # or whatever you have

#The rest of this should just RUN:

#Delete sequences shorter than $MIN_SEQUENCE_LENGTH
echo "Deleting sequences shorter than $MIN_SEQUENCE_LENGTH AAs..."
for FILENAME in *.fa
do
grep -B 1 "[^>].\{$MIN_SEQUENCE_LENGTH,\}" $FILENAME > $FILENAME.out
sed -i 's/--//g' $FILENAME.out
sed -i '/^$/d' $FILENAME.out
rm -rf $FILENAME
mv $FILENAME.out $FILENAME
done
echo Done

#If fewer than $MIN_TAXA different species are represented in the file, move that file to a "rejected_few_taxa" directory.
echo "Removing groups with fewer than $MIN_TAXA taxa..."
mkdir -p rejected_few_taxa_1
for FILENAME in *.fa
do
awk -F"|" '/^>/{ taxon[$1]++ } END{for(o in taxon){print o,taxon[o]}}' $FILENAME > $FILENAME\.taxon_count #Creates temporary file with taxon abbreviation and number of sequences for that taxon in $FILENAME
taxon_count=`grep -v 0 $FILENAME\.taxon_count | wc -l` #Counts the number of lines with an integer >0 (= the number of taxa with at least 1 sequence)
if [ "$taxon_count" -lt "$MIN_TAXA" ] ; then
echo $FILENAME
mv $FILENAME ./rejected_few_taxa_1/
fi
done
rm -rf *[0-9].fa.taxon_count
echo Done
echo


#Remove redundant sequences using uniqHaplo (http://doi.org/10.5281/zenodo.166024)
mkdir preUniqHaplo
cp *.fa preUniqHaplo
echo "Removing redundant sequences using uniqHaplo..."
ls *[0-9].fa | parallel -j $CORES 'perl /usr/bin/uniqHaplo.pl -a {} > {}.uniq'
rm -rf *.fa
rename 's/.fa.uniq/.fa/g' *.fa.uniq
echo Done
echo

#Align the remaining sequences using Mafft.
echo "Aligning sequences using Mafft (auto)..."
mkdir backup_alignments
ls *[0-9].fa | parallel -j $CORES 'mafft --auto --localpair --maxiterate 1000 {} > {}.aln'
rm -rf *[0-9].fa
rename 's/.fa.aln/.fa/g' *.fa.aln
cp *.fa ./backup_alignments/
echo Done
echo

#Remove newlines.
echo "Removing linebreaks in sequences..."
for FILENAME in *.fa
do
sed -i ':a; $!N; /^>/!s/\n\([^>]\)/\1/; ta; P; D' $FILENAME
done
echo Done
echo

#Clean alignments with HmmCleaner
echo "Removing misaligned sequence regions with HmmCleaner..."
mkdir HmmCleaner_files
ls *.fa | parallel -j $CORES 'HmmCleaner.pl {} --specificity'
mv *.fa ./HmmCleaner_files
mv *.log ./HmmCleaner_files
mv *.score ./HmmCleaner_files
rename 's/_hmm.fasta/.fa/g' *_hmm.fasta
echo Done
echo


#Trim alignments with BMGE
echo "Trimming ambiguously aligned columns in the alignment with BMGE..."
mkdir backup_pre-BMGE
ls *.fa | parallel -j $CORES 'java -jar /usr/bin/BMGE-1.12/BMGE.jar -i {} -t AA -of {}.BMGE'
mv *.fa ./backup_pre-BMGE
cp *.BMGE ./backup_pre-BMGE
rename 's/.BMGE//g' *.BMGE
echo Done
echo

#Remove newlines.
echo "Removing linebreaks in sequences..."
for FILENAME in *.fa
do
sed -i ':a; $!N; /^>/!s/\n\([^>]\)/\1/; ta; P; D' $FILENAME
done
echo Done
echo

#Remove any sequences that don't overlap with all other sequences by at least 20 amino acids. 
for FILENAME in *.fa
do
java -cp /usr/bin AlignmentCompare $FILENAME
done
echo Done
echo
rm -rf myTempFile.txt

#If fewer than $MIN_TAXA different species are represented in the file, move that file to the "rejected_few_taxa" directory.
echo "Removing groups with fewer than $MIN_TAXA taxa..."
mkdir -p rejected_few_taxa_2
for FILENAME in *.fa
do
awk -F"|" '/^>/{ taxon[$1]++ } END{for(o in taxon){print o,taxon[o]}}' $FILENAME > $FILENAME\.taxon_count #Creates temporary file with taxon abbreviation and number of sequences for that taxon in $FILENAME
taxon_count=`grep -v 0 $FILENAME\.taxon_count | wc -l` #Counts the number of lines with an integer >0 (= the number of taxa with at least 1 sequence)
if [ "$taxon_count" -lt "$MIN_TAXA" ] ; then
echo $FILENAME
mv $FILENAME ./rejected_few_taxa_2/
fi
done
rm -rf *.fa.taxon_count
echo Done
echo

#Makes a tree for each OG with FastTree
echo "Making a tree for each OG using FastTreeMP..."
for FILENAME in *.fa
do
FastTreeMP -slow -gamma $FILENAME > $FILENAME.tre
done
rename 's/.fa.tre/.tre/g' *.fa.tre
echo Done

#PhyloPyPruner:
#Runs PhyloPyPruner 0.9.5
echo "Running PhyloPyPruner..."
phylopypruner --threads $CORES --dir . --min-taxa $MIN_TAXA --min-len $MIN_SEQUENCE_LENGTH --min-support 0.75 --mask pdist --trim-lb 3 --trim-divergent 0.75 --min-pdist 0.01 --trim-freq-paralogs 3 --prune MI
cd phylopypruner_output
FastTreeMP -slow -gamma supermatrix.fas > FastTree.tre
cd ..
### If desired, the phylopypruner output can also be put into IQTree2 for a more robust final analysis. :)
