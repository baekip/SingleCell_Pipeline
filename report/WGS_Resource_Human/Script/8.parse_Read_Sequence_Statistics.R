library(ggplot2)
library(reshape2)
library(grid)
library(Cairo)

args = commandArgs(TRUE)

input_table = args[1]
output_png = args[2]

Alignment_table <- read.table( input_table, sep="\t", header=TRUE, skip=1,colClasses="character")
col2cvt <- 2:6
Alignment_table[,col2cvt] <- lapply(Alignment_table[,col2cvt],function(x){as.numeric(gsub(",","",x))})
Alignment <- melt(Alignment_table)

CairoPNG (output_png, width=2200, height=1200, res=480)
#png ( output_png, width=2200, height=1200, res=480)

ggplot(data=Alignment, aes(x=Sample.ID, y=value, fill=variable)) + 
  geom_bar(stat="identity", position="dodge", width=.5) +
 #  theme_bw() +
 # colour="black",
  theme(axis.title.x = element_blank(),
	axis.title.x = element_text(size=9, face="bold"),
	axis.text.x = element_text(angle=-90, size=5),
	axis.title.y = element_blank(),
	axis.title.y = element_text(size=9, face="bold"),
	axis.text.y = element_text(size=5),
	legend.key.width = unit (1,"mm"),
	legend.key.height = unit (3, "mm"),
	legend.title = element_blank(),
	legend.title = element_text (size=9, face = "bold"),
	legend.text = element_text (size=5),
	legend.position = "right") + 
scale_x_discrete(limits = Alignment_table$Sample.ID)


#  scale_x_discrete(breaks = c("TN1508D0113","TN1508D0114","TN1508D0115","TN1508D0116","TN1508D0117"),
#                        labels = c("Theragen01","Theragen02","Theragen03","Theragen04","Theragen05"))

#  xlab("Sample ID") + ylab("Number of Sequence Read")
#  scale_fill_brewer(palette="Set3") 

dev.off()
