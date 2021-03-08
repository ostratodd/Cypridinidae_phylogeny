#!/bin/bash

echo "uses bioperl which is only in base conda"

#First pull current names of orthogroups into file
../../scripts/og2txt.pl > og.txt

input="og.txt"
while IFS= read -r line
do
  echo "$line"
  
  #Number in next command is minimum number of species to include ortholog
  perl ../../scripts/ogsql2fasta.pl $line 20 genetrees/$line.fa
  mafft genetrees/$line.fa > genetrees/$line.aln.fa

   
  fasttree genetrees/$line.aln.fa > genetrees/$line.treefile

#option for iqtree
#  iqtree -s genetrees/$line.iq.fa -nt 4 --redo


done < "$input"

