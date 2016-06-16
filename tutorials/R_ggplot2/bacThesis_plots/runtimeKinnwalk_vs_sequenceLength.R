library("ggplot2")
library("scales")
library("grid")
library("plyr")




data <- read.table(file= "data/kinwalkRuntime/runtimeKinwalk_vs_SequenceLength",sep =' ', head=T)
p <- ggplot(data, aes(seq_len,runtime))
p<- p + ggtitle("kinwalker runtime by sequence length\n")
p<- p + geom_point(size=7)
p <- p + geom_line()

p <- p + ylab("Kinwalker Runtime [s]")                         
p <- p + xlab("Sequence Length")

p <- p + scale_x_discrete( limits = data["seq_len"])
p <- p + scale_y_discrete( limits = data["runtime"])
p

ggsave(file="pictures/kinwalkRuntimeSequenceLength/kinwalker_runtime.svg", plot=p)

