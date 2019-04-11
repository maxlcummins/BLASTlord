# BLASTlord
An R script facilitating filtering of BLAST data.


BLAST and some subsequent data processing takes place in bash before hit filtering is run in R.


Note: Requires the use of a custom BLAST outfmt:

blastn -num_threads 2 -evalue 0.001 -db $DB -query $INPUT -out $OUTPUT -outfmt "6 qseqid stitle sseqid pident length slen sstart send qstart qend qlen mismatch gapopen evalue bitscore"


For more information on BLAST outfmt refer to the following https://www.ncbi.nlm.nih.gov/books/NBK279684/

# Installation:
First install devtools:

```
install.packages("devtools")
```

Now install BLASTlord:
```
devtools::install_github("maxlcummins/BLASTlord")
```

# Usage

blastlord(file = "~/Path_to_file/File.txt", output = "Test_run", identity = 95, length = 95, writecsv = TRUE)

