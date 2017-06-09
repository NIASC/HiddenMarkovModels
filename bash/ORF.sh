#!/bin/sh

export path_htsa_dir=/media/StorageOne/HTS #path to HTSA analysis dir
export path_pipeline=viralmeta_bioifo

file_directory=$1
fasta_file=$2


if [ ! -d "$file_directory" ]; then
        mkdir "$file_directory"
fi

cd $file_directory
cat $fasta_file | awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' | awk '{ gsub("_","@", $0); print $0}' | awk -F'@' '{ print $1,$0  }' | awk '{ print $1"\t"$3  }' | awk -F"\t" '{ gsub (">","",$1); print > $1".fasta"}'
ls ./ | grep '\.fasta$' | while read FILE
do
  # start each line with >
  sed -i 's/^/>/g' $FILE
  # and now finally make fasta format (id and sequences on separate lines)
  sed -i 's/ /\n/g' $FILE
done

####
#Create gi_list.txt file
cat $fasta_file | awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' | awk '{ gsub("_","@", $0); print $0}' | awk -F'@' '{ print $1 }' | awk '{ gsub(">","", $1); print $1 }' | awk '!x[$1]++' > seq_list.txt

python $path_htsa_dir/$path_pipeline/codon_usage/estimates_codon_usage_localfasta.py seq_list.txt > RCSU.txt























