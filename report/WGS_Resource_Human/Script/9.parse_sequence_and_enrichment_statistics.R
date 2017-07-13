library(ggplot2)
library(reshape2)
library(grid)
library(Cairo)

args = commandArgs(TRUE)

input_table = args[1]
output_png = args[2]

Variant_table <- read.table( input_table, sep="\t", header = TRUE, skip=1 )
col2cvt <- c(3,5)
Sample.ID <- as.character(Variant_table[,1])
Variant_table_malted <- melt(cbind (Sample.ID,(Variant_table[,col2cvt])))

#-------------generate PNG file----------------
CairoPNG (output_png, width=2200, height=1200, res=480)
ggplot(data=Variant_table_malted, aes(x=Sample.ID, y=value, fill=variable)) + 
  geom_bar(stat="identity", position="dodge", width=.5) +  
#  theme_bw() +
  theme(axis.title.x = element_text(size=9, face="bold"),
        axis.text.x = element_text(angle=-90, size=5),
        axis.title.y = element_text(size=9, face="bold"),
        axis.text.y = element_text(size=5),
        legend.key.width = unit (1,"mm"),
        legend.key.height = unit (3, "mm"), 
        legend.title = element_text (size=9, face = "bold"),
        legend.text = element_text (size=5),
        legend.position = "right") + 
scale_x_discrete(limits = Variant_table$Sample.ID)

#  scale_x_discrete(breaks = c("TN1508D0113","TN1508D0114","TN1508D0115","TN1508D0116","TN1508D0117"),
#                        labels = c("Theragen01","Theragen02","Theragen03","Theragen04","Theragen05"))

#       plot.background = element_rect(),
#	panel.grid.major = element_line(colour = "red", linetype = "dotted"),
#	panel.grid.minor = element_line(colour = "red", linetype = "dotted"))

#  xlab("Sample ID") + ylab("Depth") 
#  scale_fill_gradientn() 
dev.off()
