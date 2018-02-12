###################################################################
# Functional Genomics Center Zurich
# This code is distributed under the terms of the GNU General
# Public License Version 3, June 2007.
# The terms are available here: http://www.gnu.org/licenses/gpl.html
# www.fgcz.ch

EzAppDiffPeaks <-
  setRefClass("EzAppDiffPeaks",
              contains = "EzApp",
              methods = list(
                initialize = function()
                {
                  "Initializes the application using its specific defaults."
                  runMethod <<- ezMethodDiffPeaks
                  name <<- "EzAppDiffPeaks"
                  #appDefaults <<- rbind(refBuildHOMER=ezFrame(Type="character", DefaultValue="hg38", Description="Genome version to use from HOMER: hg38, mm10, danRer10, etc.")
                  #)
                }
              )
  )

ezMethodDiffPeaks = function(input=NA, output=NA, param=NA, 
                             htmlFile="00index.html"){
  require(Rsamtools)
  
  stopifnot(param$sampleGroup != param$refGroup)
  
  firstSamples <- input$getNames()[input$getColumn(param$grouping) %in% 
                                     param$sampleGroup]
  secondSamples <- input$getNames()[input$getColumn(param$grouping) %in% 
                                      param$refGroup]
  
  useSamples = c(firstSamples, secondSamples)
  input <- input$subset(useSamples)
  
  if (ezIsSpecified(param$grouping2) && length(param$grouping2) == 1){
    grouping2 = input$getColumn(param$grouping2)
  }
  
  bamFiles <- input$getFullPaths("BAM")
  localBamFiles <- sapply(bamFiles, getBamLocally)
  
  bamConditions <- paste0(c(param$sampleGroup, param$refGroup),
                          "-", Sys.getpid(),".bam")
  names(bamConditions) <- c(param$sampleGroup, param$refGroup)
  
  mcmapply(mergeBam,
           list(localBamFiles[firstSamples], localBamFiles[secondSamples]),
           bamConditions, mc.cores = 2)
  
  ## Run Macs2 on pooled bam file.
  ## This parameter is tune for ATAC-seq data
  cmd = paste("macs2", "callpeak -t", bamConditions,
              "-g", gSizeMacs2(unique(input$getColumn("Species")), 
                               param$ezRef["refFastaFile"]),
              "--nomodel --bw 200",
              "--extsize 200", "-n", names(bamConditions))
  ezMclapply(cmd, ezSystem, mc.cores = 2)
  
  
}


