###################################################################
# Functional Genomics Center Zurich
# This code is distributed under the terms of the GNU General
# Public License Version 3, June 2007.
# The terms are available here: http://www.gnu.org/licenses/gpl.html
# www.fgcz.ch

ezMethodGatkDnaHaplotyper = function(input=NA, output=NA, param=NA){
  bamFile = input$getFullPaths("BAM")
  ezSystem(paste("rsync -va", bamFile, "local.bam"))
  ezSystem(paste("rsync -va", paste0(bamFile, ".bai"), "local.bam.bai"))
  knownSites = list.files(param$ezRef["refVariantsDir"],pattern='vcf.gz$',full.names = T)
  dbsnpFile = knownSites[grep('dbsnp.*vcf.gz$', knownSites)]
  javaCall = paste0(JAVA, " -Djava.io.tmpdir=. -Xmx", param$ram, "g")
  
  genomeSeq = param$ezRef["refFastaFile"]
  sampleName = names(bamFile)
  if(param$addReadGroup){
    cmd = paste0(javaCall, " -jar ", PICARD_JAR, " AddOrReplaceReadGroups",
               " TMP_DIR=. MAX_RECORDS_IN_RAM=2000000", " I=local.bam",
               " O=withRg.bam SORT_ORDER=coordinate",
               " RGID=RGID_", sampleName, " RGPL=illumina RGSM=", sampleName, " RGLB=RGLB_", sampleName, " RGPU=RGPU_", sampleName,
               " VERBOSITY=WARNING")
    ezSystem(cmd) } else {
    ezSystem('mv local.bam withRg.bam')
  }
  
  if(param$markDuplicates){
    cmd = paste0(javaCall, " -jar ", PICARD_JAR, " MarkDuplicates ",
                 " TMP_DIR=. MAX_RECORDS_IN_RAM=2000000", " I=withRg.bam",
                 " O=dedup.bam",
                 " REMOVE_DUPLICATES=false",
                 " ASSUME_SORTED=true",
                 " VALIDATION_STRINGENCY=SILENT",
                 " METRICS_FILE=" ,"dupmetrics.txt",
                 " VERBOSITY=WARNING")
    ezSystem(cmd)
    ezSystem('mv dedup.bam withRg.bam')
  }
  
  ezSystem(paste(SAMTOOLS, "index", "withRg.bam"))
  #BaseRecalibration
  baseRecalibration1 = paste(javaCall,"-jar", GATK_JAR, " -T BaseRecalibrator")
  #knownSitesCMD = ''
  #for (j in 1:length(knownSites)){
  #  knownSitesCMD = paste(knownSitesCMD,paste("--knownSites", knownSites[j], collapse=','))
  #}
  
  cmd = paste(baseRecalibration1, "-R", genomeSeq,
              "-I withRg.bam",
              "--knownSites", dbsnpFile,
              "--out recal.table", 
              "-nct", param$cores)
  
  if(param$targetFile != ''){
    cmd = paste(cmd,
                "-L", param$targetFile)
  }
  ezSystem(cmd)
  
  baseRecalibration2 = paste(javaCall,"-jar", GATK_JAR, " -T PrintReads")
  cmd = paste(baseRecalibration2, "-R", genomeSeq,
              "-I withRg.bam",
              "-BQSR recal.table",
              "-o recal.bam",
              "-nct", param$cores)
  
  if(param$targetFile != ''){
    cmd = paste(cmd,
                "-L", param$targetFile)
  }
  ezSystem(cmd)

  ########### haplotyping
  haplotyperCall = paste(javaCall,"-jar", GATK_JAR, " -T HaplotypeCaller")
  outputFile = paste0(sampleName, "-HC_calls.g.vcf")
  cmd = paste(haplotyperCall, "-R", genomeSeq,
              "-I recal.bam",
              "--emitRefConfidence GVCF",
              "--max_alternate_alleles 2",
              "--dbsnp", dbsnpFile,
              "-o", outputFile)
  
  if(param$targetFile != ''){
    cmd = paste(cmd,
                "-L", param$targetFile)
  }
  if(param$getRealignedBam){
    cmd = paste(cmd,
              "-bamout", paste0(sampleName, "-realigned.bam"),
              "-forceActive",
              "-disableOptimizations", 
              "-ip 100")
  } else {
    cmd = paste(cmd,
                "-nct", param$cores)
  }
  ezSystem(cmd)
  ezSystem(paste(file.path(HTSLIB_DIR,"bgzip"),"-c",outputFile, ">",paste0(outputFile,".gz")))
  ezSystem(paste(file.path(HTSLIB_DIR,"tabix"),"-p vcf",paste0(outputFile,".gz")))
  
  return("Success")
}

##' @template app-template
##' @templateVar method ezMethodGatkDnaHaplotyper(input=NA, output=NA, param=NA)
##' @description Use this reference class to run 
EzAppGatkDnaHaplotyper <-
  setRefClass("EzAppGatkDnaHaplotyper",
              contains = "EzApp",
              methods = list(
                initialize = function()
                {
                  "Initializes the application using its specific defaults."
                  runMethod <<- ezMethodGatkDnaHaplotyper
                  name <<- "EzAppGatkDnaHaplotyper"
                  appDefaults <<- rbind(addReadGroup = ezFrame(Type="logical",  DefaultValue=FALSE, Description="add ReadGroup to BAM"),
                                        getRealignedBam = ezFrame(Type="logical",  DefaultValue=FALSE, Description="for IGV check"),
                                        targetFile = ezFrame(Type="character",  DefaultValue="", Description="restrict to targeted genomic regions"),
                                        markDuplicates = ezFrame(Type="logical",  DefaultValue=TRUE, Description="not recommended for gene panels, exomes"))
                }
              )
  )