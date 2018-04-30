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

merge.path = paste(c(output.path,"/QC/"), collapse="")

###load Merge.Rda
sample.merge = readRDS (file = paste(c(output.path,"/Rdata/",sample.id,".Merge.Rda"), collapse=""))

##Summary of total expression per merged single cell
expression.sum <- (colSums(sample.merge@data))
capture.output (expression.sum, file = paste(c(merge.path, "expression.sum.per.cell.txt"), collapse=""))

at_least_one <- apply (sample.merge@data, 2, function(x) sum (x>0))
at.least.one <- summary (at_least_one)
capture.output (at.least.one, file = paste (c(merge.path, "at.least.one.txt"), collapse=""))

###Draw Plot
CairoPNG(file = paste(c(merge.path, "Distribution_of_detected_genes.png"), collapse=""), width=800, heigh=600)
hist(at_least_one, breaks=100,
    main = paste(c("Merge Distribution of detected of genes - ", sample.id), collapse=""),
    xlab = "Genes with at least one tag")
dev.off()

CairoPNG(file = paste(c(merge.path, "Expression_sum_per_cell.png"), collapse=""), width=800, height=600)
hist(expression.sum, breaks=100,
     main = paste(c("Merge Expression sum per cell - ", sample.id), collapse=""),
     xlab = "Sum expression")
dev.off()

###Filtration of Single Cell (percent.mito, ngene, nUMI)
mito.genes <- grep(pattern = "^MT-", x = rownames(x = sample.merge@raw.data), value = TRUE)
percent.mito <- Matrix::colSums(sample.merge@raw.data[mito.genes, ]) / Matrix::colSums(sample.merge@raw.data)

sample.merge.meta <- AddMetaData(object = sample.merge, 
                            metadata = percent.mito,
                            col.name = "percent.mito")

CairoPNG (file = paste(c(merge.path, "vlnplot.png"), collapse=""), width=800, height=600)
VlnPlot(object = sample.merge.meta,
        features = c("nGene", "nUMI", "percent.mito"),
        nCol = 3)
dev.off()

CairoPNG (file = paste(c(merge.path, "Geneplot.png"), collapse=""), width=800, height=600)
par(mfrow = c(1,2))
GenePlot(object = sample.merge.meta, gene1 = "nUMI", gene2 = "percent.mito")
GenePlot(object = sample.merge.meta, gene1 = "nUMI", gene2 = "nGene")
dev.off()


saveRDS (sample.merge.meta, file = paste(c(output.path,"/Rdata/",sample.id,".QC.Rda"), collapse=""))
