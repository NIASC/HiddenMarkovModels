#!/bin/sh



#nohup ./markovchains.sh fasta_directory /full_path/output_directory

Fasta_dir=$1
output_dir=$2


if [ ! -d $output_dir ]; then
	mkdir $output_dir
fi

mkdir $output_dir/ORF
mkdir $output_dir/TAB
mkdir $output_dir/R_output
mkdir $output_dir/hmmout
mkdir $output_dir/clustered
mkdir $output_dir/final_results

cd $Fasta_dir
Fastas=`ls *.fa`

for fasta in "$Fastas"; do 

	/usr/local/bin/getorf -sequence $fasta -outseq $output_dir/ORF/"$fasta".orf -find 1 -minsize 120

	cat $fasta | awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print $0}' > $output_dir/TAB/"$fasta".tab

	hmmsearch --domtblout $output_dir/hmmout/"$fasta".out /media/StorageOne/zurbzh/vFam-A_2014.hmm $output_dir/ORF/"$fasta".orf > $output_dir/hmmout/"$fasta".csv

	Rscript /media/StorageOne/zurbzh/Rscripts/analyze_hmmout.R  $output_dir/hmmout/"$fasta".out $output_dir/TAB/"$fasta".tab $output_dir/R_output/"$fasta".output

	rm $output_dir/hmmout/"$fasta".csv 

done



Rscript /media/StorageOne/zurbzh/Rscripts/counting_viruses.R $output_dir/TAB $output_dir/R_output $output_dir/final_results/final_results.csv $output_dir/final_results/virus_by_project.csv


cat $output_dir/R_output/*output | awk -F"," '{print ">"$1"\n"$4}' | sed 's/"//g' > $output_dir/clustered/all_sequences.fasta


nohup /media/StorageOne/HTS/viralmeta_bioifo/public_programs/cd-hit/cd-hit-est -i $output_dir/clustered/all_sequences.fasta -o $output_dir/clustered/all_sequences_clustered.fasta -d 100 -T 0 -r 1 -g 1 -c 0.98 -G 0 -aS 0.95 -G 0 -M 0

