\name{writeAnnotationFromGtf}
\alias{writeAnnotationFromGtf}
\alias{aggregateGoAnnotation}
\alias{aggregateFeatAnno}
\title{Feature annotation file operations}
\description{
Gets the sequence annotation from annotation (gtf or gff) and sequence (fasta) information.
Sequence annotation files are on the isoform level. 
If the analysis is to be done at the gene level, the annotation for the isoforms is aggregated.
}
\usage{
  writeAnnotationFromGtf(param, featureFile = param$ezRef@refFeatureFile,
                         featAnnoFile = param$ezRef@refAnnotationFile)
  aggregateGoAnnotation(seqAnno, genes,
                        goColumns = c("GO BP", "GO CC", "GO MF"))
}
\arguments{
\item{param}{the parameters to load the annotation and sequence files from and possibly write to.}

\item{ids}{a character vector containing the gene ID's to return.}

\item{dataFeatureType}{either \code{"isoform"} or \code{"gene"}.}
}
\value{
Returns a data.frame containing information about the genes in an easily readable way.
}

\section{Functions}{
\itemize{
\item \code{writeAnnotationFromGtf}: Gets the annotation from a .gtf file and transforms it into a tab-separated tabular .txt file.

\item \code{aggregateGoAnnotation}: Aggregates the Go annotation.
}}

\examples{
param = ezParam()
param$ezRef["refFeatureFile"] = system.file("extdata/genes.gtf", package="ezRun", mustWork=TRUE)
param$ezRef["refFastaFile"] = system.file("extdata/genome.fa", package="ezRun", mustWork=TRUE)
annoFile = system.file("extdata/genes_annotation.txt", package="ezRun", mustWork=TRUE)
param$ezRef["refAnnotationFile"] = annoFile
seqAnno = writeAnnotationFromGtf(param)
seqAnno2 = ezFeatureAnnotation(param, rownames(seqAnno), dataFeatureType="gene")
}
\author{
Rehrauer, Hubert

Schmid, Peter
}
