library(ezRun)
# Report
## input
input = '/home/miquel/dataset.tsv'
## output
output = list()
output[['Name']] = 'Count_QC'
output[['Species']] = ''
output[['refBuild']] = 'Homo_sapiens/UCSC/hg38'
output[['Static Report [Link]']] = 'p3093/Excerpt_38298_2019-12-19--09-55-33/Excerpt_Report/00index.html'
output[['Report [File]']] = 'p3093/Excerpt_38298_2019-12-19--09-55-33/Excerpt_Report'
## param
param=list()
param$name='Excerpt_Report'
param$process_mode='DATASET'
param$dataRoot='/srv/gstore/projects'

## run report app
EzAppExceRptReport$new()$run(input=input, output=output, param=param)

# p2598
setwd("/scratch/gtan/dev/quickdev")
library(ezRun)
param = list()
param[['cores']] = '1'
param[['ram']] = '2'
param[['scratch']] = '10'
param[['node']] = 'fgcz-c-042,fgcz-c-045,fgcz-c-046,fgcz-c-048,fgcz-c-056,fgcz-c-063,fgcz-c-065,fgcz-h-004,fgcz-h-006,fgcz-h-007,fgcz-h-008,fgcz-h-009,fgcz-h-010,fgcz-h-011,fgcz-h-012,fgcz-h-013,fgcz-h-014,fgcz-h-015,fgcz-h-016,fgcz-h-017,fgcz-h-018,fgcz-h-019'
param[['process_mode']] = 'DATASET'
param[['samples']] = 'LNCaP-2D_1,LNCaP-2D_2,LNCaP-2D_3,LNCaP-3D_1,LNCaP-3D_2,LNCaP-3D_3,PNT1_2D_1,PNT1_2D_2,PNT1_2D_3,PNT1_3D_1,PNT1_3D_2,PNT1_3D_3,PC3_2D_1,PC3_2D_2,PC3_2D_3,PC3_3D_1,PC3_3D_2,PC3_3D_3'
param[['name']] = 'Excerpt_Report'
param[['mail']] = 'ge.tan@fgcz.ethz.ch'
param[['dataRoot']] = '/srv/gstore/projects'
param[['resultDir']] = 'p2598/ExceRptReport_46606_2020-05-26--22-15-20'
param[['isLastJob']] = TRUE
output = list()
output[['Name']] = 'Excerpt_Report'
output[['Species']] = 'Homo sapiens (human)'
output[['refBuild']] = ''
output[['Static Report [Link]']] = 'p2598/ExceRptReport_46606_2020-05-26--22-15-20/Excerpt_Report/00index.html'
output[['Report [File]']] = 'p2598/ExceRptReport_46606_2020-05-26--22-15-20/Excerpt_Report'
input = '/srv/gstore/projects/p2598/ExceRptReport_46606_2020-05-26--22-15-20/input_dataset.tsv'
# debug(ezMethodExceRptReport)
# debug(processSamples)
debug(readData)
EzAppExceRptReport$new()$run(input=input, output=output, param=param)

