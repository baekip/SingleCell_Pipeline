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


###preparation process
basic.path = paste(c(output.path,"/Basic/"), collapse="")

###load Norm.Rda
sample.norm = readRDS (file = paste(c(input.path,"/Rdata/",sample.id,".Norm.Rda"), collapse=""))



###Draw VariableGenes Plot 
CairoPNG (file = paste(c(basic.path, "gene_dispersion.png"), collapse=""), width=800, height=600)
sample.fvg <- FindVariableGenes(object = sample.norm, mean.function = ExpMean,
                              dispersion.function = LogVMR,
                              x.low.cutoff = 0.0125, x.high.cutoff = 3, y.cutoff = 0.5)
dev.off()


###PCA Analysis
sample.scale <- ScaleData(object = sample.fvg, vars.to.regress = c("nGene", "nUMI", "percent.mito"))
sample.pca <- RunPCA(object = sample.scale, pc.genes = sample.scale@var.genes, 
                   do.print = TRUE, pcs.print = 1:5, genes.print = 5)

# Examine and visualize PCA results a few different ways
PrintPCA(object = sample.pca, pcs.print = 1:5, genes.print = 5, use.full = FALSE)
VizPCA(object = sample.pca, pcs.use = 1:6)

CairoPNG (file = paste(c(basic.path, "PCA_plot.png"), collapse=""),
    width=800, height=600)
PCAPlot(object = sample.pca, dim.1 = 1, dim.2 = 2)
dev.off()


sample.project.pca <- ProjectPCA(object = sample.pca, do.print = FALSE)
PCHeatmap(object = sample.project.pca, pc.use = 1, cells.use = 500, 
          do.balanced = TRUE, label.columns = FALSE)

# ProjectPCA scores each gene in the dataset (including genes not included in the PCA) based on their correlation with the calculated components.
PCHeatmap(object = sample.project.pca, pc.use = 1:12, cells.use = 500, do.balanced = TRUE, 
          label.columns = FALSE, use.full = FALSE)
PCElbowPlot(object = sample.project.pca)

sample.cluster <- FindClusters(object = sample.project.pca, reduction.type = "pca", dims.use = 1:10, resolution = 0.6, print.output = 0, save.SNN = TRUE)
PrintFindClustersParams(object = sample.cluster)

sample.cluster.pca <- RunTSNE(object = sample.cluster, 
                            dims.use = 1:10, do.fast = TRUE)

# save.SNN = T saves the SNN so that the clustering algorithm can be rerun using the same graph but with a different resolution value (see docs for full details)

CairoPNG (file = paste (c(basic.path, "cluster_plot.png"), collapse=""),
    width=800, height=600)
TSNEPlot(object = sample.cluster.pca, do.label = TRUE)
dev.off()


saveRDS (sample.cluster.pca, file = paste(c(output.path,"/Rdata/",sample.id,".Cluster.Rda"), collapse=""))
