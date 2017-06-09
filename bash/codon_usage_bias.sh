#!/bin/sh

export path_htsa_dir=/media/StorageOne/HTS #path to HTSA analysis dir
export path_pipeline=viralmeta_bioifo


file_directory=$1
fasta_file=$2

if [ ! -d "$file_directory" ]; then
        mkdir "$file_directory"
fi


/usr/local/bin/getorf -sequence $fasta_file  -outseq $file_directory/sequences.pos  -find 3 -minsize 120

cat $file_directory/sequences.pos  | awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' | grep -v 'REVERSE'| awk -F'\t' '{sub(/ .*/,"", $1); print $1,$2 }'  | awk '{sub(/.fasta.*/,"", $1); print $1"\n"$2 }' > $file_directory/forward.orfs


cat $file_directory/sequences.pos | awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' | grep -i 'REVERSE'| awk -F'\t' '{sub(/ .*/,"", $1); print $1,$2 }'  | awk '{sub(/.fasta.*/,"", $1); print $1"\n"$2 }' > $file_directory/reverse.orfs


mkdir $file_directory/forward_orfs
cd $file_directory/forward_orfs
cat $file_directory/forward.orfs | awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' | awk '{ gsub("_","@", $0); print $0}' | awk -F'@' '{ print $1,$0  }' | awk '{ print $1"\t"$3  }' | awk -F"\t" '{ gsub (">","",$1); print > $1".fasta"}'
ls ./ | grep '\.fasta$' | while read FILE
do
  # start each line with >
  sed -i 's/^/>/g' $FILE
  # and now finally make fasta format (id and sequences on separate lines)
  sed -i 's/ /\n/g' $FILE
done

####
#Create gi_list.txt file
cat $file_directory/forward.orfs | awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' | awk '{ gsub("_","@", $0); print $0}' | awk -F'@' '{ print $1 }' | awk '{ gsub(">","", $1); print $1 }' | awk '!x[$1]++' > seq_list.txt

python $path_htsa_dir/$path_pipeline/codon_usage/estimates_codon_usage_localfasta.py seq_list.txt > forward_RCSU.txt



mkdir $file_directory/machine_learning

awk -F"\t" '{print $1}' $file_directory/forward_orfs/forward_RCSU.txt | tail -n +2 > $file_directory/machine_learning/forward_matrix_id.txt
Rscript /media/StorageOne/zurbzh/bash_scripts/Rrscu.R $file_directory/forward_orfs/forward_RCSU.txt $file_directory/machine_learning/forward_matrix.txt




mkdir $file_directory/reverse_orfs
cd $file_directory/reverse_orfs
cat $file_directory/reverse.orfs | awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' | awk '{ gsub("_","@", $0); print $0}' | awk -F'@' '{ print $1,$0  }' | awk '{ print $1"\t"$3  }' | awk -F"\t" '{ gsub (">","",$1); print > $1".fasta"}'
ls ./ | grep '\.fasta$' | while read FILE
do
  # start each line with >
  sed -i 's/^/>/g' $FILE
  # and now finally make fasta format (id and sequences on separate lines)
  sed -i 's/ /\n/g' $FILE
done

####
#Create gi_list.txt file
cat $file_directory/reverse.orfs | awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' | awk '{ gsub("_","@", $0); print $0}' | awk -F'@' '{ print $1 }' | awk '{ gsub(">","", $1); print $1 }' | awk '!x[$1]++' > seq_list.txt

python $path_htsa_dir/$path_pipeline/codon_usage/estimates_codon_usage_localfasta.py seq_list.txt > reverse_RCSU.txt



awk -F"\t" '{print $1}' $file_directory/reverse_orfs/reverse_RCSU.txt | tail -n +2 > $file_directory/machine_learning/reverse_matrix_id.txt
Rscript /media/StorageOne/zurbzh/bash_scripts/Rrscu.R $file_directory/reverse_orfs/reverse_RCSU.txt $file_directory/machine_learning/reverse_matrix.txt


########

