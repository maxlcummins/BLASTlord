library(magrittr)
library(dplyr)

new <- combined.N90.L90.PASS

new$gene_title <- gsub(pattern = "(_([A-Z][0-9]+.*)|:.*)", replacement = "", new$gene_title)


new %>% group_by(sample_name, scaffold) %>% summarise(same_scaff=paste(gene_title, collapse=" ")) %>% filter(grepl("IS26",same_scaff)) %>% View()

dplyr::filter(new, grepl("Inc",same_scaff))

new %>% group_by(sample_name, scaffold) %>%
  summarise(same_scaff=paste(unique(gene_title), collapse=" ")) %>%
  filter(grepl("",same_scaff)) %>%
  filter(grepl("Inc",same_scaff)) %>%
  View()

#Tiz
#       - Virulence resistance plasmids - search for intI1 and incFIB
#       - has an potential IncB IncF hybrid plasmid
#Ronnie - Same as above
#       - Has Colicin plasmids carrying qnr genes
#       - Has an IncI plasmid with an integron and CTX-M, sul2, dfrA, aadA
#       - Has Colicin plasmids carrying tet genes
#       - has an IncX plasmid carrying O_type genes
#       - has an IncY plasmid carrying fimH gene (or more likely an IncY integrated into chromosome)
#       - has an potential IncB IncF hybrid plasmid
#       - has an potential IncI IncF hybrid plasmid
#Denmark
#       - blaCMY2 containing IncFIB plasmid
#
