#/TBI/Tools/R/current/bin/R
#load(file = "~/Projects/datasets/pbmc3k_final.Rda")
###Preparation of Seurat Process###
suppressMessages({
    library(Seurat)
    library(dplyr)
    library(Matrix)
    library(Cairo)
})

args = commandArgs(TRUE)
options (bitmapType='cairo')

###analysis argument
sample.id = args[1]
input.path = args[2]
output.path = args[3]

###options argument
#min.nGene = as.numeric(args[4])
#max.nGene = as.numeric(args[5])
#min.nUMI = as.numeric(args[6])
#max.nUMI = as.numeric(args[7])
#min.mito = as.numeric(args[8])
#max.mito = as.numeric(args[9])

min.nGene = noquote(args[4])
max.nGene = noquote(args[5])
min.nUMI = noquote(args[6])
max.nUMI = noquote(args[7])
min.mito = noquote(args[8])
max.mito = noquote(args[9])

#n.gene = as.numeric(nGene)
#n.UMI = as.numeric(nUMI)
filt.path = paste(c(output.path,"/Filt/"), collapse="")


###load QC.Rda
sample.add.meta = readRDS (file = paste(c(input.path,"/Rdata/",sample.id,".QC.Rda"), collapse=""))

###Filtration of Single Cell (percent.mito, ngene, nUMI)
FiltCells = table(sample.add.meta@meta.data$percent.mito < max.mito & sample.add.meta@meta.data$nGene < max.nGene & sample.add.meta@meta.data$nUMI < max.nUMI )
write.table (FiltCells, file = paste(c(filt.path,"/FiltCells.txt"), collapse=""), sep="\t", quote = FALSE, row.names = FALSE, col.names = FALSE )

sample.filt <- FilterCells(object = sample.add.meta, subset.names = c("nGene", "nUMI", "percent.mito"), low.thresholds = c(min.nGene, min.nUMI, min.mito), high.thresholds = c(max.nGene, max.nUMI, max.mito))

#sample.filt <- FilterCells(object = sample.add.meta, subset.names = c("nGene", "nUMI", "percent.mito"), low.thresholds = c(-Inf, -Inf, -Inf), high.thresholds = c(Inf, Inf, Inf))

###Summary of total expression per single cell
expression.sum <- summary (colSums(sample.filt@data))
capture.output (expression.sum, file = paste(c(filt.path, "Filtered.expression.sum.per.cell.txt"), collapse=""))

at_least_one <- apply (sample.filt@data, 2, function(x) sum(x>0))
at.least.one <- summary (at_least_one)
capture.output (at.least.one, file = paste(c(filt.path, "Filtered.at.least.one.txt"), collapse=""))


###Draw filtered Expression
CairoPNG (file = paste(c(filt.path, "Filtered_Distribution_of_detected_genes.png"), collapse=""), width=800, height=600)
hist(at_least_one, breaks=100,
    main = paste(c("Filtered_Distribution of detected genes - ", sample.id), collapse=""),
    xlab = "Genes with at least one tag")
dev.off()



CairoPNG (file = paste(c(filt.path, "Filtered_Expresssion_sum_per_cell.png"), collapse=""), width=800, height=600)
par(mfrow = c(1, 1))
hist(colSums(sample.filt@data), breaks = 100,
main = paste(c("Filtered Expression sum per cell - ", sample.id), collapse=""), xlab = "Sum of expression")
dev.off()


###Normalization of Cell Expression 
sample.norm <- NormalizeData(object = sample.filt, normalization.method = "LogNormalize", scale.factor = 10000)

CairoPNG(file = paste(c(filt.path, "Filtered_normalisation_distribution.png"), collapse=""), width=800, height=600)
par(mfrow = c(1, 1))
hist(colSums(sample.norm@data), breaks = 100, main = paste(c("Total expression after normalisation - ", sample.id), collapse=""), xlab = "Sum of expression")
dev.off()

CairoPNG(file = paste(c(filt.path, "Filtered_gene_dispersion.png"), collapse=""), width=800, height=600)
sample.fvg <- FindVariableGenes(object = sample.norm, mean.function = ExpMean, dispersion.function = LogVMR, x.low.cutoff = 0.0125, x.high.cutoff = 3, y.cutoff = 0.5)
dev.off()

saveRDS (sample.norm, file = paste(c(output.path,"/Rdata/",sample.id,".Norm.Rda"), collapse=""))
