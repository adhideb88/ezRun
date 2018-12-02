###################################################################
# Functional Genomics Center Zurich
# This code is distributed under the terms of the GNU General
# Public License Version 3, June 2007.
# The terms are available here: http://www.gnu.org/licenses/gpl.html
# www.fgcz.ch


ezMethodMothurStep2Dataset = function(input=NA, output=NA, param=NA, 
                                        htmlFile="00index.html"){
  
  require(rmarkdown)
  require(ShortRead)
  require(phyloseq)
  require(plyr)
  require(ape)
  require(ggplot2)
  library(scales)
  dataset = input$meta
  sampleName = input$getNames() 
  
  ### Merge align and group files from Mothur
  alignFiles <- input$getFullPaths("alignedFile")
  catStringAl <- paste(alignFiles,collapse = " ")
  ezSystem(paste("cat",catStringAl,"> merged.align"))
  groupFiles <- input$getFullPaths("groupFile")
  catStringGr <- paste(groupFiles,collapse = " ")
  ezSystem(paste("cat",catStringGr,"> merged.group"))

  ### is there at least a mock sample for the error estimate? The error estimates for the Non-mock samples will be ignored downstream
  ## TODO : fix this properly
  if(param$mockSample){
    if (input$getColumn("Mock") == "Yes") {
      copyRefCmd <- paste("cp", param$referenceFasta,"./", sep = " ")
      ezSystem(copyRefCmd)
      mockString = "seq.error" 
      refString = param$referenceFasta
      oldErrFile <- paste(sampleName,
                          "unique.good.good.good.filter.unique.precluster.pick.pick.error.count",
                          sep = ".")
    }else{
      mockString = "###seq.error"  
      oldErrFile <- "mockErrorFileNotForDownstreamAnalysis.txt"
      write("There is no relevant info in this file",oldErrFile)
    }
  }else{
    mockString = "###seq.error"
  }
  ###
  
  ### update batch file  with parameters and run mothur: step 2 and, precluster, remove non-bacterial reads and generate final cluster
  updateBatchCmd_step3 <- paste0("sed -e s/\"CUTOFF_TAXON\"/", param$cutOffTaxonomy, "/g",
                                   " -e s/\"REFERENCE\"/", basename(param$referenceFasta), "/g",
                                   " -e s/\"CUTOFF_CLUST\"/", param$cutOffCluster, "/g",
                                   " -e s/\"DIFFS\"/", param$diffs, "/g",
                                   " -e s/\"Mothur\"/" ,sampleName, "/g",
                                   " -e s/\"###seq.error\"/", mockString,"/g ",
                                 file.path(METAGENOMICS_ROOT,FINAL_MOTHUR_WORKFLOW_TEMPLATE_STEP3),
                                   " > ", FINAL_MOTHUR_WORKFLOW_TEMPLATE_STEP3)
  ezSystem(updateBatchCmd_step3)
  cmdMothur_step3= paste(MOTHUR_EXE,FINAL_MOTHUR_WORKFLOW_TEMPLATE_STEP3)
  ezSystem(cmdMothur_step3)
  
  ## rename output files
  ## Files needed for the report 
  #5) 
  oldChimeraPlotFileName <- paste(sampleName,
                                  "merged.filter.unique.precluster.denovo.vsearch.chimeras",
                                  sep = ".")
  newChimeraPlotFileName <- basename(output$getColumn("ChimeraPlot"))
  ezSystem(paste("mv",oldChimeraPlotFileName,newChimeraPlotFileName))
  
  #6) 
  oldPreClusteredAndChimeraFileName <- paste(sampleName,
                                             "merged.filter.unique.precluster.pick.summary",
                                             sep = ".")
  newPreClusteredAndChimeraFileName <- basename(output$getColumn("PreClusteredAndChimeraSummary"))
  ezSystem(paste("mv",oldPreClusteredAndChimeraFileName,newPreClusteredAndChimeraFileName))
  
  #7) 
  if(param$mockSample) {
    newErrFile <- basename(output$getColumn("ErrorFile"))
    ezSystem(paste("mv",oldErrFile,newErrFile))
  }
  #8) 
  oldStepConvFile <- paste(sampleName,
                           "merged.filter.unique.precluster.pick.pick.opti_mcc.steps",
                           sep = ".")
  newStepConvFile <- basename(output$getColumn("stepConvergenceSummary"))
  ezSystem(paste("mv",oldStepConvFile,newStepConvFile))
  
  ### Files needed for Phyloseq
  #9)  
  oldOTUsToTaxFileName <- paste(sampleName,
                                "merged.filter.unique.precluster.pick.pick.opti_mcc",
                                param$cutOffCluster, "cons.taxonomy",
                                sep = ".")
  newOTUsToTaxFileName <- basename(output$getColumn("OTUsToTaxonomyFile"))
  ezSystem(paste("mv",oldOTUsToTaxFileName,newOTUsToTaxFileName))
  
  #10)
  oldOTUsToCountFileName <- paste(sampleName,
                                  "merged.filter.unique.precluster.pick.pick.opti_mcc.shared",
                                  sep = ".")
  newOTUsToCountFileName <- basename(output$getColumn("OTUsCountTable"))
  ezSystem(paste("mv",oldOTUsToCountFileName,newOTUsToCountFileName))
}

##' @template app-template
##' @templateVar method ezMethodMothurStep2Dataset()
##' @templateVar htmlArg )
##' @description Use this reference class to run 
EzAppMothurStep2Dataset <-
  setRefClass("EzAppMothurStep2Dataset",
              contains = "EzApp",
              methods = list(
                initialize = function()
                {
                  "Initializes the application using its specific defaults."
                  runMethod <<- ezMethodMothurStep2Dataset
                  name <<- "EzAppMothurStep2Dataset"
                  appDefaults <<- rbind(cutOffTaxonomy = ezFrame(Type="integer",  DefaultValue="80",Description="Cut-off for taxonomy assignment"),
                                        diffs= ezFrame(Type="integer",  DefaultValue="2",Description="Differences allowed in the pre.cluster step.Should be 1 every 100 bases"),
                                        minLen = ezFrame(Type="integer",  DefaultValue="290",Description="Min length"),     
                                        maxLen= ezFrame(Type="integer",  DefaultValue="330",Description="Max length"),
                                        cutOffCluster = ezFrame(Type="numeric",  DefaultValue="0.03",Description="Cut-off for OTU clustering."),
                                        referenceFasta = ezFrame(Type="character",  DefaultValue="",Description="Mock reference seqeuences.")
                  )
                }
              )
  )