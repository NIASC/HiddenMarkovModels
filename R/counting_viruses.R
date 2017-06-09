
args <- commandArgs(TRUE)

output_path = args[1]
sequence_path = args[2]

output.names <- dir(output_path)
sequence.names <- dir(sequence_path)


project_name = c()
identified_viruses = c()
original_sequence_number = c()
identified_average = c()
not_identified_average = c()
not_identified_min = c()
not_identified_max = c()
whole_viruses_rate = data.frame()

for (i in 1:length(sequence.names)) {

  sequence_file = sequence.names[i]
   
  sequence = paste(sequence_path, sequence_file, sep="/")
  sequences_tab = read.table(sequence, fill=TRUE)
  colnames(sequences_tab)<-c("sequences","Sequence");

  result_file =  gsub("^\\.+|\\.[^.]*$", ".output", sequence.names[i], perl=TRUE);	  
  output_file = paste(output_path, result_file, sep = "/")

   if (file.exists(output_file)) {

         results = read.table(output_file, header = TRUE, sep = ",")

 	 identified_viruses[i] = length(results$sequences)

	 identified_average[i] = round(mean(results$Length), 1)

	 not_identified = sequences_tab [ ! sequences_tab$sequences %in% results$sequences, ]

 	 not_identified$Length = nchar(as.character(not_identified$Sequence))

 	 not_identified_average [i] =round(mean(not_identified$Length), 1)

 	 not_identified_min [i] =min(not_identified$Length)

 	 not_identified_max [i] =max(not_identified$Length)
 	 
 	 viruses = data.frame(table(results$VirusesFamily), result_file)

	 colnames(viruses) = c("family", "number", "pr_name")
    
 	 whole_viruses_rate = rbind (whole_viruses_rate, viruses)
  
         project_name[i] = result_file
 
         original_sequence_number [i] = length(sequences_tab$sequences)
    }
}

final_results = data.frame(project_name, identified_viruses, original_sequence_number, identified_average, not_identified_average, not_identified_min, not_identified_max)
write.table(final_results, args[3], row.names=FALSE, sep=",", quote=FALSE)




library(Epi)
virus_by_project<-stat.table(index=list(family, pr_name),contents=list(sum(number)),data = whole_viruses_rate);
virus_by_project<-data.frame(virus_by_project[1,1:length(dimnames(virus_by_project)[[2]]),1:length(dimnames(virus_by_project)[[3]])]);
virus_by_project[is.na(virus_by_project)] <- 0

family = rownames(virus_by_project)
virus_by_project = cbind (family, virus_by_project)



write.table(virus_by_project, args[4], row.names=F, sep=",", quote=FALSE)

