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

merge.path = paste(c(output.path,"/Merge/"), collapse="")

###load Merge.Rda
sample.merge = readRDS (file = paste(c(output.path,"/Rdata/",sample.id,".Merge.Rda"), collapse=""))

##Summary of total expression per merged single cell
expression.sum <- (colSums(sample.merge@data))
capture.output (expression.sum, file = paste(c(merge.path, "Merge_expression.sum.per.cell.txt"), collapse=""))

at_least_one <- apply (sample.merge@data, 2, function(x) sum (x>0))
at.least.one <- summary (at_least_one)
capture.output (at.least.one, file = paste (c(merge.path, "Merge_at.least.one.txt"), collapse=""))

###Draw Plot
CairoPNG(file = paste(c(merge.path, "Merge_Distribution_of_detected_genes.png"), collapse=""), width=800, heigh=600)
hist(at_least_one, breaks=100,
    main = paste(c("Merge Distribution of detected of genes - ", sample.id), collapse=""),
    xlab = "Genes with at least one tag")
dev.off()

CairoPNG(file = paste(c(merge.path, "Merge_Expresssion_sum_per_cell.png"), collapse=""), width=800, height=600)
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

CairoPNG (file = paste(c(merge.path, "Merge_vlnplot.png"), collapse=""), width=800, height=600)
VlnPlot(object = sample.merge.meta,
        features = c("nGene", "nUMI", "percent.mito"),
        nCol = 3)
dev.off()

CairoPNG (file = paste(c(merge.path, "Merge_GenePlot.png"), collapse=""), width=800, height=600)
par(mfrow = c(1,2))
GenePlot(object = sample.merge.meta, gene1 = "nUMI", gene2 = "percent.mito")
GenePlot(object = sample.merge.meta, gene1 = "nUMI", gene2 = "nGene")
dev.off()

###Filtration of Merge Single Cell (percent.mito, ngene, nUMI)
FiltCells = table(sample.merge.meta@meta.data$percent.mito < max.mito & sample.merge.meta@meta.data$nGene < max.nGene & sample.merge.meta@meta.data$nUMI < max.nUMI )
write.table (FiltCells, file = paste(c(merge.path,"/Merge_FiltCells.txt"), collapse=""), sep="\t", quote = FALSE, row.names = FALSE, col.names = FALSE )


sample.filt <- FilterCells(object = sample.merge.meta, subset.names = c("nGene", "nUMI", "percent.mito"), low.thresholds = c(min.nGene, min.nUMI, min.mito), high.thresholds = c(max.nGene, max.nUMI, max.mito))

###Summary of total expression per single cell
expression.sum <- summary (colSums(sample.filt@data))
capture.output (expression.sum, file = paste(c(merge.path, "Filtered.Merge.expression.sum.per.cell.txt"), collapse=""))

at_least_one <- apply (sample.filt@data, 2, function(x) sum(x>0))
at.least.one <- summary (at_least_one)
capture.output (at.least.one, file = paste(c(merge.path, "Filtered.Merge.at.least.one.txt"), collapse=""))

###Draw filtered Expression
CairoPNG (file = paste(c(merge.path, "Filtered_Merge_Distribution_of_detected_genes.png"), collapse=""), width=800, height=600)
hist(at_least_one, breaks=100,
    main = paste(c("Filted Merge Distribution of detected genes - ", sample.id), collapse=""),
    xlab = "Genes with at least one tag")
dev.off()


CairoPNG (file = paste(c(merge.path, "Filtered_Merge_Expresssion_sum_per_cell.png"), collapse=""), width=800, height=600)
par(mfrow = c(1, 1))
hist(colSums(sample.filt@data), breaks = 100,
main = paste(c("Filtered Merge Expression sum per cell - ", sample.id), collapse=""), xlab = "Sum of expression")
dev.off()


###FindVariableGenes
CairoPNG (file = paste(c(merge.path, "Merge_gene_dispersion.png"), collapse=""), width=800, height=600)
sample.fvg <- FindVariableGenes(object = sample.filt,
                          mean.function = ExpMean,
                          dispersion.function = LogVMR,
                          x.low.cutoff = 0.0125,
                          x.high.cutoff = 3,
                          y.cutoff = 0.8)
dev.off()

sample.scale <- ScaleData(object = sample.fvg, vars.to.regress = c("nGene", "nUMI", "percent.mito"))

###PCA Analysis
sample.pca <- RunPCA(object = sample.scale,
                     pc.genes = sample.scale@var.genes,
                     do.print = TRUE,
                     pcs.print = 1:5,
                     genes.print = 5)

CairoPNG (file = paste(c(merge.path, "Merge_PCA_plot.png"), collapse=""),width=800, height=600)
PCAPlot (object = sample.pca, dim.1 =1, dim.2 =2)
dev.off()

###tSNE Analysis
sample.tsne <- RunTSNE (object = sample.pca,
                        dims.use = 1:10,
                        do.fast = TRUE)

CairoPNG (file = paste(c(merge.path, "Merge_tSNE_plot.png"), collapse=""),width=800, height=600)
TSNEPlot(object = sample.tsne, do.label = TRUE)
dev.off()

sample.project.pca <- ProjectPCA(object = sample.tsne, do.print = FALSE)

sample.cluster <- FindClusters(object = sample.project.pca, reduction.type = "pca", dims.use = 1:10, resolution = 0.6, print.output = 0, save.SNN = TRUE)


CairoPNG (file = paste(c(merge.path, "Merge_compare_plot.png"), collapse=""),width=800, height=600)
p1 <- TSNEPlot(object = sample.cluster, do.return = TRUE, do.label = TRUE)
p2 <- TSNEPlot(object = sample.cluster, 
         group.by = "orig.ident", do.label = T, do.return =T)
plot_grid(p1, p2)
dev.off()

CairoPNG (file = paste(c(merge.path, "Merge_Phylogenetic_Tree.png"), collapse=""),width=800, height=600)
plotClusterTree(sample.cluster)
dev.off()


saveRDS (sample.cluster, file = paste(c(output.path,"/Rdata/",sample.id,".Merge.Cluster.Rda"), collapse=""))

####Normalization of Cell Expression 
#sample.norm <- NormalizeData(object = sample.filt, normalization.method = "LogNormalize", scale.factor = 10000)
#
#CairoPNG(file = paste(c(filt.path, "Filtered_normalisation_distribution.png"), collapse=""), width=800, height=600)
#par(mfrow = c(1, 1))
#hist(colSums(sample.norm@data), breaks = 100, main = paste(c("Total expression after normalisation - ", sample.id), collapse=""), xlab = "Sum of expression")
#dev.off()
#
#CairoPNG(file = paste(c(filt.path, "Filtered_gene_dispersion.png"), collapse=""), width=800, height=600)
#sample.fvg <- FindVariableGenes(object = sample.norm, mean.function = ExpMean, dispersion.function = LogVMR, x.low.cutoff = 0.0125, x.high.cutoff = 3, y.cutoff = 0.5)
#dev.off()
#
#saveRDS (sample.norm, file = paste(c(output.path,"/Rdata/",sample.id,".Norm.Rda"), collapse=""))
