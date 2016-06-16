library("ggplot2")
library("scales")
library("grid")
library("plyr")


#input = "tableExonR.t"
#input = "tableExonF.t"
#input = "tableIntronR.t"
#input = "tableIntronF.t"
input = "all.table"


filename=paste0("data/",input)


data<-read.table(file=filename,sep='\t',head=T)


p <- ggplot(data, aes(x=s,y=free_energy,group=s))
p <- p+ geom_boxplot()


#p<-ggplot(data, aes(free_energy)) 

#p<- p + ggtitle("exonic region of complementary reverse strand")
#p<- p + ggtitle("exonic region of forward strand")
#p<- p + ggtitle("intronic region of complementary reverse strand")
#p<- p + ggtitle("intronic region of forward strand")

#p<- p + ggtitle("boxplot")


p <- p + theme(axis.text.x = element_text(size=24,face="bold"),axis.text.y = element_text(size=24,face="bold"), axis.title.x= element_text(size=24,face="bold"),axis.title.y= element_text(size=24,face="bold"),title=element_text(size=24,face="bold"))
p<-  p + geom_histogram(binwidth=0.3)
p <- p + ylab("free energy * (-1) ");
p <- p + xlab("");

p



outputFile=paste0("pictures/",input,".svg")
ggsave(file=outputFile, plot=p)
 