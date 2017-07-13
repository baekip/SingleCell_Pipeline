library(ggplot2)
library(reshape2)
library(grid)
library(Cairo)

args = commandArgs(TRUE)

input_table = args[1]
output_png = args[2]

options(bitmapType='cairo')
Variant_table <- read.table( input_table, sep="\t", header = TRUE, skip=1, colClasses="character")
col2cvt <- 2:13
Variant_table[,col2cvt] <- lapply(Variant_table[,col2cvt],function(x){as.numeric(gsub(",", "", x))})

Variant_table_malted <- melt(Variant_table[,-13])

#png ( output_png, res=200, heigh=398, width=549)
#png ( output_png, width=550, height=300, res=120)
#png ( output_png, width=1100, height=600, res=240)
#png ( output_png, width= 1500, height=900, res=120)


CairoPNG( output_png, width=2200, height=1200, res=480)
#png ( output_png, width=2200, height=1200, res=480)

ggplot(data=Variant_table_malted, aes(x=Sample.ID, y=value, fill=variable))  + 
  geom_bar(stat="identity", width=.5) + 
#  theme_bw() +
  theme(
	axis.title.x=element_text(size=9, face="bold"),
	axis.text.x=element_text(angle=-90, size=5),

	axis.title.y=element_text(size=9, face="bold"),
	axis.text.y=element_text(size=5),
	legend.key.width = unit(1,"mm"),
	legend.key.height = unit(3,"mm"),

	legend.title = element_text(size=9, face="bold"),
	legend.text = element_text(size=5),
	legend.position = "right") + 
    scale_x_discrete(limits = Variant_table$Sample.ID)
# +

#  scale_x_discrete(breaks = c("TN1508D0113","TN1508D0114","TN1508D0115","TN1508D0116","TN1508D0117"),
#                        labels = c("Theragen01","Theragen02","Theragen03","Theragen04","Theragen05"))

#  scale_fill_continuous(guide=guide_legend(title=NULL))
#  xlab("Sample ID") + 
#  ylab("Number of variants")

#  ggtitle("The Barplot of Variants") + 
#  scale_fill_gradientn() 

dev.off()
