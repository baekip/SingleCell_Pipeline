#/TBI/People/tbi/isaac/R-3.4.2/bin/R
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

min.nGene = noquote(args[4])
max.nGene = noquote(args[5])
min.nUMI = noquote(args[6])
max.nUMI = noquote(args[7])
min.mito = noquote(args[8])
max.mito = noquote(args[9])

filt.path = paste(c(output.path,"/Filt/"), collapse="")

###load Merge.Rda
sample.merge.meta = readRDS (file = paste(c(input.path, "/Rdata/", sample.id, ".QC.Rda"), collapse=""))


###Filtration of Merge Single Cell (percent.mito, ngene, nUMI)
FiltCells = table(min.mito < sample.merge.meta@meta.data$percent.mito &
                  min.nGene < sample.merge.meta@meta.data$nGene &
                  min.nUMI < sample.merge.meta@meta.data$nUMI &
                  sample.merge.meta@meta.data$percent.mito < max.mito & 
                  sample.merge.meta@meta.data$nGene < max.nGene & 
                  sample.merge.meta@meta.data$nUMI < max.nUMI )

write.table (FiltCells, file = paste(c(filt.path,"/FiltCells.txt"), collapse=""), sep="\t", quote = FALSE, row.names = FALSE, col.names = FALSE )


sample.filt <- FilterCells(object = sample.merge.meta, subset.names = c("nGene", "nUMI", "percent.mito"), low.thresholds = c(min.nGene, min.nUMI, min.mito), high.thresholds = c(max.nGene, max.nUMI, max.mito))

###Summary of total expression per single cell
expression.sum <- summary (colSums(sample.filt@data))
capture.output (expression.sum, file = paste(c(filt.path, "Filtered.expression.sum.per.cell.txt"), collapse=""))

at_least_one <- apply (sample.filt@data, 2, function(x) sum(x>0))
at.least.one <- summary (at_least_one)
capture.output (at.least.one, file = paste(c(filt.path, "Filtered.at.least.one.txt"), collapse=""))

###Draw filtered Expression
CairoPNG (file = paste(c(filt.path, "Filtered_Distribution_of_detected_genes.png"), collapse=""), width=800, height=600)
hist(at_least_one, breaks=100,
    main = paste(c("Filted Merge Distribution of detected genes - ", sample.id), collapse=""),
    xlab = "Genes with at least one tag")
dev.off()


CairoPNG (file = paste(c(filt.path, "Filtered_normalisation_distribution.png"), collapse=""), width=800, height=600)
par(mfrow = c(1, 1))
hist(colSums(sample.filt@data), breaks = 100,
main = paste(c("Filtered Merge Expression sum per cell - ", sample.id), collapse=""), xlab = "Sum of expression")
dev.off()


###FindVariableGenes
CairoPNG (file = paste(c(filt.path, "Filtered_gene_dispersion.png"), collapse=""), width=800, height=600)
sample.fvg <- FindVariableGenes(object = sample.filt,
                          mean.function = ExpMean,
                          dispersion.function = LogVMR,
                          x.low.cutoff = 0.0125,
                          x.high.cutoff = 3,
                          y.cutoff = 0.8)
dev.off()

sample.scale <- ScaleData(object = sample.fvg, vars.to.regress = c("nGene", "nUMI", "percent.mito"))

CairoPNG (file = paste(c(filt.path, "Filtered_vlnplot.png"), collapse=""), width=800, height=600)
VlnPlot(object = sample.fvg, 
        features.plot = c("nGene", "nUMI", "percent.mito"), 
        nCol = 3)
dev.off()

CairoPNG (file = paste(c(filt.path, "Filtered_Geneplot.png"), collapse=""), width=800, height=600)
par(mfrow = c(1, 2))
GenePlot(object = sample.fvg, gene1 = "nUMI", gene2 = "percent.mito")
GenePlot(object = sample.fvg, gene1 = "nUMI", gene2 = "nGene")
dev.off()


saveRDS (sample.scale, file = paste(c(output.path,"/Rdata/",sample.id,".Scale.Rda"), collapse=""))

