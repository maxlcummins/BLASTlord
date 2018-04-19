# BLASTlord
A script facilitating filtering of BLAST data

Note: Requires the use of a custom BLAST outfmt:

blastn -num_threads 2 -evalue 0.001 -db $DB -query $INPUT -out $OUTPUT -outfmt "6 qseqid stitle sseqid pident length slen sstart send qstart qend qlen mismatch gapopen evalue bitscore"

For more information on BLAST outfmt refer to the following https://www.ncbi.nlm.nih.gov/books/NBK279684/
