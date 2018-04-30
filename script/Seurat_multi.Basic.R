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

basic.path = paste(c(output.path,"/Basic/"), collapse="")

###load Merge.Rda
sample.scale = readRDS (file = paste(c(input.path,"/Rdata/",sample.id,".Scale.Rda"), collapse=""))

###PCA Analysis
sample.pca <- RunPCA(object = sample.scale,
                     pc.genes = sample.scale@var.genes,
                     do.print = TRUE,
                     pcs.print = 1:5,
                     genes.print = 5)

CairoPNG (file = paste(c(basic.path, "PCA_plot.png"), collapse=""),width=800, height=600)
PCAPlot (object = sample.pca, dim.1 =1, dim.2 =2)
dev.off()


###JackStraw
sample.jack <- JackStraw(object = sample.pca, num.replicate=100)

CairoPNG (file = paste(c(basic.path, "JackStraw_plot.png"), collapse=""),width=800, height=600)
JackStrawPlot(object = sample.jack, PCs = 1:12)
dev.off()

CairoPNG (file = paste(c(basic.path, "PCElbow_plot.png"), collapse=""),width=800, height=600)
PCElbowPlot (object = sample.jack)
dev.off()


###tSNE Analysis
sample.tsne <- RunTSNE (object = sample.jack,
                        dims.use = 1:12,
                        do.fast = TRUE)

CairoPNG (file = paste(c(basic.path, "tSNE_plot.png"), collapse=""),width=800, height=600)
TSNEPlot(object = sample.tsne, do.label = TRUE)
dev.off()

sample.project.pca <- ProjectPCA(object = sample.tsne, do.print = FALSE)

sample.cluster <- FindClusters(object = sample.project.pca, reduction.type = "pca", dims.use = 1:12, resolution = 0.6, print.output = 0, save.SNN = TRUE)

CairoPNG (file = paste(c(basic.path, "cluster_plot.png"), collapse=""),width=800, height=600)
TSNEPlot(object = sample.cluster, do.label = TRUE)
dev.off()


CairoPNG (file = paste(c(basic.path, "compare_plot.png"), collapse=""),width=800, height=600)
p1 <- TSNEPlot(object = sample.cluster, do.return = TRUE, do.label = TRUE)
p2 <- TSNEPlot(object = sample.cluster, 
         group.by = "orig.ident", do.label = T, do.return =T)
plot_grid(p1, p2)
dev.off()

###Phylogenetic Tree Analysis
CairoPNG (file = paste(c(basic.path, "Phylogenetic_Tree.png"), collapse=""),width=800, height=600)
BuildClusterTree(sample.cluster, do.reorder = FALSE, reorder.numeric = FALSE, pcs.use = 1:12)
dev.off()

sample.markers <- FindAllMarkers(object = sample.cluster, logfc.threshold = 0.5)
write.table (sample.markers, file = paste(c(basic.path, "expression.cluster.xls"), collapse=""), col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")

###Save Top 10 Gene 
#top10.genes <- sample.markers %>% group_by(cluster) %>% top_n(10, avg_logFC)
top10.genes <- sample.markers %>% group_by(cluster) %>% filter(avg_logFC > 0) %>% top_n(10, avg_logFC)
write.table (top10.genes, file = paste(c(basic.path, "high.top10.gene.expression.cluster.xls"), collapse=""), col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")

CairoPNG (file = paste(c(basic.path, "High_Top10Gene_Heatmap.png"), collapse=""),width=800, height=600)
DoHeatmap(object = sample.cluster, 
          genes.use = top10.genes$gene, slim.col.label = TRUE, remove.key = TRUE)
dev.off()


btm10.genes <- sample.markers %>% group_by(cluster) %>% filter(avg_logFC < 0) %>% top_n(-10, avg_logFC)
write.table (btm10.genes, file = paste(c(basic.path, "low.top10.gene.expression.cluster.xls"), collapse=""), col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")

CairoPNG (file = paste(c(basic.path, "Low_Top10Gene_Heatmap.png"), collapse=""),width=800, height=600)
DoHeatmap(object = sample.cluster, 
          genes.use = btm10.genes$gene, slim.col.label = TRUE, remove.key = TRUE)
dev.off()

###Save Top 2 Gene (feature plot)
#top2.genes <- sample.markers %>% group_by(cluster) %>% top_n(2, avg_logFC)
top2.genes <- sample.markers %>% group_by(cluster) %>% filter(avg_logFC > 0) %>% top_n(2, avg_logFC)

CairoPNG (file = paste(c(basic.path, "High_Top2Gene_FeaturePlot.png"), collapse=""),width=800, height=600)
FeaturePlot(sample.cluster, 
            features.plot = c(top2.genes$gene),
            min.cutoff = "q05", max.cutoff = "q95", 
            cols.use = c("lightgrey", "blue"), 
            pt.size = 0.5)
dev.off()

btm2.genes <- sample.markers %>% group_by(cluster) %>% filter(avg_logFC < 0) %>% top_n(-2, avg_logFC)

CairoPNG (file = paste(c(basic.path, "Low_Top2Gene_FeaturePlot.png"), collapse=""),width=800, height=600)
FeaturePlot(sample.cluster, 
            features.plot = c(btm2.genes$gene),
            min.cutoff = "q05", max.cutoff = "q95", 
            cols.use = c("lightgrey", "blue"), 
            pt.size = 0.5)
dev.off()




###Save RDS file
saveRDS (sample.cluster, file = paste(c(output.path,"/Rdata/",sample.id,".Merge.Cluster.Rda"), collapse=""))

