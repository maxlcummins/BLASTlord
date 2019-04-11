blastlord <- function(file, output, identity = 90, length = 90, writecsv = FALSE) {
  
  require(readr)
  
  #provides a name for downstream files based on user input
  name <- output
  #reads input file (BLAST output in tab separated format.
  #                   Note: MUST BE GENERATED USING CUSTOM
  #                   PROVIDED BLAST SUBMISSION SCRIPT)
  read_delim(file = file, delim = "\t",col_names = FALSE) -> file
  
  # Creates a list of column headers called colnames_blastout.
  # Ensure that these are correct for your blast output.
  # If you are using Max's blast.qsub script they should be the same...
  c("scaffold","gene_title",	"gene_id",	"match_(%)",	"query_hit_length",	
    "subject_length",	"subject_end",	"subject_start",	"query_start",	
    "query_end",	"scaffold_length",	"mismatches",	"gaps",	"e-value",	
    "bitscore",	"sample_name") -> colnames_blastout
  
  # Assigns the previous column names to the data frame created by read.delim in line 4
  colnames(file) <- colnames_blastout
  
  # Standardises the scaffold names for column "scaffold". 
  # This is because various assembly pipelines have generated different scaffold name formats
  # This script will clean any that are formatted as "scaffoldxyz.1", 
  # where .1 is tacked onto the end in assembly and xyz is scaffold number
  # It should also work on any that HGAP assembled "unitigs".
  # This should be confirmed. The script needs to be modified for any other scaffold formats/fasta headers
  gsub(pattern = "(scaffold|unitig)_?([0-9]{1,4})(\\.|\\|\\w*)?1?",replacement = "scaffold_\\2", 
       x = file$scaffold) -> file$scaffold
  
  # Adds a column called 'Length Match' that contains the length match of a given gene 
  # (ie. length of reference gene/length of gene hit in sample)
  # Numbers greater than 100% indicate insertions.
  file$`query_hit_length`/file$`subject_length`*100 -> 
    file$`length_match`
  
  # Rearranges columns to put sample name in the first column
  file[c(16,1:15,17)] -> file
  
  # appends a 1 to the final column of each row (used later by dcast)
  rep(x = 1, times = nrow(file)) -> file$gene_present
  
  # Removes .fasta* in column sample name
  gsub(pattern = "\\.fasta.*", replacement = "", x = file$sample_name) -> 
    file$sample_name
  
  # makes simple gene name from gene_id and replaces column with this value
  # Note: This assumes fasta headers are in the format suggested.
  gsub(pattern = "(^v|^r|^p|^i)[a-z]+_([^:]+):?.*", replacement = "\\1_\\2", x = file$gene_id, perl = TRUE) -> file$gene_id
  
  # Assigns all hits meeting criteria of 
  # X% Nucleotide match and Y% Length Match to variable filename.NX.LY.PASS
  # (tweak arguments 3 and 4 of blastlord to change the nucleotide and length criteria)
  file1 <- subset.data.frame(file, file$`match_(%)` >= identity & file$length_match >= length) 
  assign(paste(name, paste("N", identity, sep = ""), paste("L", length, sep =""), "PASS", sep = "."), file1, envir=globalenv())
  
  # Assigns all hits NOT meeting criteria of 
  # X% Nucleotide match and Y% Length Match to variable filename.NX.LY.FAIL
  # (tweak arguments 3 and 4 of blastlord to change the nucleotide and length criteria)
  file2 <-  subset.data.frame(file, file$`match_(%)` < identity & file$length_match < length)
  assign(paste(name, paste("N", identity, sep = ""), paste("L", length, sep =""), "FAIL", sep = "."), file2, envir=globalenv())
  
  require("reshape2")
  
  # Generates a simple summary table of genes (not including allele variants) from
  # file1 (PASS file) that contains hits that passed the set criteria
  dcast(data = file1, sample_name ~ gene_id, 
        value.var = 'gene_present', drop = FALSE) -> file3
  assign(paste(name, "_simple_summary_", "N", identity, "L", length, sep = ""), file3, envir =globalenv())
  
  # Generates a full summary table of all reference sequences from
  # file1 (PASS file) that contains all hits that passed the set criteria 
  file4 <- dcast(data = file1, sample_name ~ gene_title, 
                 value.var = 'gene_present', drop = FALSE)
  assign(paste(name, "_full_summary_", "N", identity, "L", length, sep= ""), file4, envir=globalenv())
 
  if(writecsv == TRUE) {
  message("Writing objects to csv file...")
    write.csv(file1, paste(paste(name, paste("N", identity, sep = ""), paste("L", length, sep =""), "PASS", sep = "."),".csv", sep = ""))
    write.csv(file2, paste(paste(name, paste("N", identity, sep = ""), paste("L", length, sep =""), "FAIL", sep = "."),".csv", sep = ""))
    write.csv(file3, paste(paste(name, "_simple_summary_", "N", identity, "L", length, sep = ""),".csv", sep = ""))
    write.csv(file4, paste(paste(name, "_full_summary_", "N", identity, "L", length, sep= ""),".csv", sep = ""))
  message("Writing complete; script finished.")
}
  else {
    message("Files not written to disk; script finished.")
  }
}
#***Changelog***
# blastlord4.0  - added an option to write PASS, FAIL and summary files to disk in CSV format. Default of write = FALSE
# blastlord5.0  - changed read.delim to read_delim from readr package.
#                 This greatly improves read time of the original CSV file - the most time consuming step
#               - added a change log
# 

