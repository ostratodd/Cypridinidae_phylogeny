./download_data.pl data_table.tab 50
rm -rf OrthoFinder_results	#remove old results
orthofinder -t 4 -I 2.1 -M msa -T fasttree -f ./pep -o ./OrthoFinder_results
