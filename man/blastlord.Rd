\name{blastlord}
\alias{blastlord}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{BLASTlord}
\description{
A script for the processing of BLASTn data. See https://github.com/maxlcummins/BLASTlord for more
}
\usage{
blastlord(file, output, identity = 90, length = 90, writecsv = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{file}{
The BLAST input file. Make sure it is in the right format. Parameter defaults are shown below in square brackets
}
  \item{output}{
Output prefix
}
  \item{identity}{
Nucleotide identity cut-off [90]
}
  \item{length}{
Length/coverage cut-off [90]
}
  \item{writecsv}{
Boolean for writing to CSV [FALSE]
}
}
\details{
PASS and FAIL files will show which hits met and didn't meet cut-offs, respectively.
Simple summary shows the genes that met cut-offs, condensing alleles into a single column given appropriate name formatting
Full summary shows all gene hits that met cut-offs
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
blastlord(file = "Resfinder.txt", output = "Resfinder_31-12", identity = 95, length = 95, writecsv = TRUE)

## The function is currently defined as
function (file, output, identity = 90, length = 90, writecsv = FALSE)
{
    require(readr)
    name <- output
    file <- read_delim(file = file, delim = "\t", col_names = FALSE)
    colnames_blastout <- c("scaffold", "gene_title", "gene_id",
        "match_(\%)", "query_hit_length", "subject_length", "subject_end",
        "subject_start", "query_start", "query_end", "scaffold_length",
        "mismatches", "gaps", "e-value", "bitscore", "sample_name")
    colnames(file) <- colnames_blastout
    file$scaffold <- gsub(pattern = "(scaffold|unitig)_?([0-9]{1,4})(\\.|\\|\\w*)?1?",
        replacement = "scaffold_\\2", x = file$scaffold)
    file$length_match <- file$query_hit_length/file$subject_length *
        100
    file <- file[c(16, 1:15, 17)]
    file$gene_present <- rep(x = 1, times = nrow(file))
    file$sample_name <- gsub(pattern = "\\.fasta.*", replacement = "",
        x = file$sample_name)
    file$gene_id <- gsub(pattern = "(^v|^r|^p|^i)[a-z]+_([^:]+):?.*",
        replacement = "\\1_\\2", x = file$gene_id, perl = TRUE)
    file1 <- subset.data.frame(file, file$`match_(\%)` >= identity &
        file$length_match >= length)
    assign(paste(name, paste("N", identity, sep = ""), paste("L",
        length, sep = ""), "PASS", sep = "."), file1, envir = globalenv())
    file2 <- subset.data.frame(file, file$`match_(\%)` < identity &
        file$length_match < length)
    assign(paste(name, paste("N", identity, sep = ""), paste("L",
        length, sep = ""), "FAIL", sep = "."), file2, envir = globalenv())
    require("reshape2")
    file3 <- dcast(data = file1, sample_name ~ gene_id, value.var = "gene_present",
        drop = FALSE)
    assign(paste(name, "_simple_summary_", "N", identity, "L",
        length, sep = ""), file3, envir = globalenv())
    file4 <- dcast(data = file1, sample_name ~ gene_title, value.var = "gene_present",
        drop = FALSE)
    assign(paste(name, "_full_summary_", "N", identity, "L",
        length, sep = ""), file4, envir = globalenv())
    if (writecsv == TRUE) {
        message("Writing objects to csv file...")
        write.csv(file1, paste(paste(name, paste("N", identity,
            sep = ""), paste("L", length, sep = ""), "PASS",
            sep = "."), ".csv", sep = ""))
        write.csv(file2, paste(paste(name, paste("N", identity,
            sep = ""), paste("L", length, sep = ""), "FAIL",
            sep = "."), ".csv", sep = ""))
        write.csv(file3, paste(paste(name, "_simple_summary_",
            "N", identity, "L", length, sep = ""), ".csv", sep = ""))
        write.csv(file4, paste(paste(name, "_full_summary_",
            "N", identity, "L", length, sep = ""), ".csv", sep = ""))
        message("Writing complete; script finished.")
    }
    else {
        message("Files not written to disk; script finished.")
    }
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
