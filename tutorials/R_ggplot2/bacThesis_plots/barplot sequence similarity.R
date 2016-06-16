library("ggplot2")
library("scales")
library("grid")
library("plyr")


input = "extended.RF00010"

input = "RF00169_realigned"

input = "RF00513_realigned"

filename=paste0("data/sequence similarity/",input)
data<-read.table(file=filename,sep='\t',head=T)
p<- ggplot(data,aes(accession_number,sequence_similarity))
p<- p + geom_bar(stat="identity")
p <- p + theme(axis.text.x = element_text(size=25,face="bold",angle=90),axis.title=element_text(size=20,face="bold"),axis.text.y = element_text(size=25,face="bold")) 
p <- p + ylab("sequence similarity")                         
p <- p + xlab("accession number")

#title= paste0("sequence similarity to ",input," reference sequence\n")
#p <- p + ggtitle(title)

p

outputFile=paste0("pictures/sequence similarity/",input,".pdf")
ggsave(file=outputFile, plot=p)

