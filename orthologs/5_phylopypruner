#!/bin/bash

echo "*****************/n*******DON'T FORGET conda activate phylopy"

#echo "deleting old fasta files"
#find ./phylopydir -name '*.aln.fa' -exec rm {} \;
#echo "deleting old treefiles"
#find ./phylopydir -name '*.treefile' -exec rm {} \;
#
##SUBSET of files for debugging
##cp ./genetrees/*0080*.aln.fa ./phylopydir/
##cp ./genetrees/*0080*.treefile ./phylopydir/
#
##Too many files for straight cp 
#echo "Copying aligned files...."
#find ./genetrees -name '*.aln.fa' -exec cp {} ./phylopydir \;
#echo "Copying genetrees...."
#find ./genetrees -name '*.treefile' -exec cp {} ./phylopydir \;
#
##Delete empty files (which are written even if they don't make the threhold for OTU number)
#find ./phylopydir -name '*.aln.fa' -size 0 -print -delete
#find *.treefile -size 0 -print -delete
#find ./phylopydir -name '*.treefile' -size 0 -print -delete
#
##Format file for phylopypruner format which is species|gene
#echo "altering files to ppp format"
#perl -p -i -e 's/\_OG/\|OG/g' ./phylopydir/*.fa
#perl -p -i -e 's/\_OG/\|OG/g' ./phylopydir/*.treefile


phylopypruner --dir phylopydir --min-taxa 20 --min-support 0.7 --min-len 100 --mask pdist --trim-lb 3 --trim-divergent 0.75 --trim-freq-paralogs 7 --min-pdist 0.01 --prune LS --outgroup Dstev_ENA --no-plot --overwrite
