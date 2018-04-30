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

sample.id = args[1]
input.path = args[2]
output.path = args[3]
work.path = paste(c(input.path,"/",sample.id,"/outs/filtered_gene_bc_matrices/hg19/"), collapse="")
#work.path = paste(c(input.path,"/",sample.id,"/",sample.id,"/outs/filtered_gene_bc_matrices/hg19/"), collapse="")
qc.path = paste(c(output.path,"/QC/"), collapse="")

print (work.path)
###Road 10X Genomics Data
sample.data <- Read10X(data.dir = work.path)


###Summary of total expression per single cell
expression.sum <- summary (colSums(sample.data))
capture.output (expression.sum, file = paste(c(qc.path, "expression.sum.per.cell.txt"), collapse=""))

at_least_one <- apply (sample.data, 2, function(x) sum(x>0))
at.least.one <- summary (at_least_one)
capture.output (at.least.one, file = paste(c(qc.path, "at.least.one.txt"), collapse=""))


###Check how many genes have at least one transcript in each cell 
CairoPNG (file = paste(c(qc.path, "Distribution_of_detected_genes.png"), collapse=""), width=800, height=600)
hist(at_least_one, breaks=100,
    main = paste(c("Distribution of detected genes - ", sample.id), collapse=""),
    xlab = "Genes with at least one tag")
dev.off()

CairoPNG (file = paste(c(qc.path, "Expression_sum_per_cell.png"), collapse=""), width=800, height=600)
hist(colSums(sample.data), breaks = 100, 
     main = paste(c("Expression sum per cell - ", sample.id), collapse=""),
          xlab = "Sum expression")
dev.off()


# Initialize the Seurat object with the raw (non-normalized data).  Keep all genes expressed in >= 3 cells (~0.1% of the data). Keep all cells with at least 200 detected genes
sample.orig <- CreateSeuratObject(raw.data = sample.data, min.cells = 3, min.genes = 200, 
                           project = paste(c("10X_", sample.id), collapse=""))

mito.genes <- grep(pattern = "^MT-", x = rownames(x = sample.orig@data), value = TRUE)
percent.mito <- Matrix::colSums(sample.orig@raw.data[mito.genes, ])/Matrix::colSums(sample.orig@raw.data)


# AddMetaData adds columns to object@meta.data, and is a great place to stash QC stats
sample.add.meta <- AddMetaData(object = sample.orig, metadata = percent.mito,col.name = "percent.mito")
CairoPNG (file = paste(c(qc.path, "vlnplot.png"), collapse=""), width=800, height=600)
VlnPlot(object = sample.add.meta, 
        features.plot = c("nGene", "nUMI", "percent.mito"), 
        nCol = 3)
dev.off()


# GenePlot is typically used to visualize gene-gene relationships, but can
# be used for anything calculated by the object, i.e. columns in
# object@meta.data, PC scores etc.  Since there is a rare subset of cells
# with an outlier level of high mitochondrial percentage and also low UMI
# content, we filter these as well
CairoPNG (file = paste(c(qc.path, "Geneplot.png"), collapse=""), width=800, height=600)
par(mfrow = c(1, 2))
GenePlot(object = sample.add.meta, gene1 = "nUMI", gene2 = "percent.mito")
GenePlot(object = sample.add.meta, gene1 = "nUMI", gene2 = "nGene")
dev.off()

saveRDS (sample.add.meta, file = paste(c(output.path,"/Rdata/",sample.id,".QC.Rda"), collapse=""))
