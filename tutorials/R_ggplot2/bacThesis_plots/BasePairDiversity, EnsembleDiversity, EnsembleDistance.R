library("ggplot2")
library("scales")
library("grid")
library("plyr")

#BPCountScore For reference Sequence without time
##BPdiversity without Time

input="X01074.1_170-275"
name="SRP"
input="CP001509.3_3136785-3136410"
name="TRP"
input="AE005174.2_2263095-2263188"
name="RNAseP"


filename= paste0("data/SimpleSequenceScores/refSequenceScore/WithoutTime/",input)
data <- read.table(file=filename,sep ='\t', head=T)

p <- ggplot(data, aes(transcription_rate,Score,color=as.character(dangle),shape=(barrier_heuristic)))
p <- p + geom_point(size=5)
p <- p + geom_line()
title= paste0("base pair diversity (without time)")
#p <- p + ggtitle(title)
p <- p + theme(axis.text.x = element_text(size=35,face="bold",angle=90),legend.position="top",legend.title = element_blank(),axis.text.y = element_text(size=35,face="bold"),axis.title=element_text(size=25,face="bold"),legend.text=element_text(size=20), legend.background=element_rect(colour="black"),panel.background=element_rect(fill="white"),panel.grid.major = element_line(colour = "lightgray"),panel.grid.minor = element_line(colour = "#dddddd"), axis.title.x = element_text(colour="black"), axis.title.y = element_text(colour="black"), axis.line = element_line(size=1))
#


p <- p + ylab("bp diversity")                         
p <- p + xlab("transcription rate nt/s")
p <- p + scale_y_continuous(expand=c(0,0),limits=c(0,0.010))
#p <- p + scale_x_discrete( limits = data["transcription_rate"])
p <- p + scale_x_continuous(expand=c(0,0),limits = c(0,510), breaks = c(0,50,100,150,200,250,300,350,400,450,500), minor_breaks = seq(0,510,10))

p <- p + scale_color_manual(name    = "dangle model",  #legende name
                            breaks  = c("0", "2"),	# Werte der Tabelle
                            labels  = c("dangle=0", "dangle=2"),  # Werte beschreiben
                            values  = c("#ec4000","darkblue"))
p <- p + scale_shape_manual(name = "barrier heuristic",
                            values=c(8,1),
                            labels = c("findpath","morgan higgs"))
p

outputFile=paste0("pictures/base pair diversity/",name,"-WithoutTime.pdf")
ggsave(file=outputFile, plot=p)

#efefef


###BP Diversity with Time

input="X01074.1_170-275"
name="SRP"
input="CP001509.3_3136785-3136410"
name="TRP"
input="AE005174.2_2263095-2263188"
name="RNAseP"

filename= paste0("data/SimpleSequenceScores/refSequenceScore/",input)
data <- read.table(file=filename,sep ='\t', head=T)

p <- ggplot(data, aes(transcription_rate,Score,color=as.character(dangle),shape=(barrier_heuristic)))
p <- p + geom_point(size=5)
p <- p + geom_line()
title= paste0("base pair diversity (without time)")
#p <- p + ggtitle(title)
p <- p + theme(axis.text.x = element_text(size=35,face="bold",angle=90),legend.position="top",legend.title = element_blank(),axis.text.y = element_text(size=35,face="bold"),axis.title=element_text(size=25,face="bold"),legend.text=element_text(size=20), legend.background=element_rect(colour="black"),panel.background=element_rect(fill="white"),panel.grid.major = element_line(colour = "lightgray"),panel.grid.minor = element_line(colour = "#dddddd"), axis.title.x = element_text(colour="black"), axis.title.y = element_text(colour="black"), axis.line = element_line(size=1))
#
p <- p + ylab("bp diversity")                         
p <- p + xlab("transcription rate nt/s")
p <- p + scale_y_continuous(expand=c(0,0),limits=c(0,0.010))
#p <- p + scale_x_discrete( limits = data["transcription_rate"])
p <- p + scale_x_continuous(expand=c(0,0),limits = c(0,510), breaks = c(0,50,100,150,200,250,300,350,400,450,500), minor_breaks = seq(0,510,10))
p <- p + scale_color_manual(name    = "dangle model",  #legende name
                            breaks  = c("0", "2"),	# Werte der Tabelle
                            labels  = c("dangle=0", "dangle=2"),  # Werte beschreiben
                            values  = c("#ec4000","darkblue"))
p <- p + scale_shape_manual(name = "barrier heuristic",
                            values=c(8,1),
                            labels = c("findpath","morgan higgs"))

p

outputFile=paste0("pictures/base pair diversity/",name,"WithTime.pdf")
ggsave(file=outputFile, plot=p)






###############
###Base pair diversity for alignment (With time)


input="RF00169_realigned"
#input="RF00513_realigned"
#input="extended.RF00010"

curBarrier="B"
#curBarrier="M"
curDangle="2"
#curDangle="0"


filename= paste0("data/SimpleSequenceScores/familySimpleScore/",input)
data <- read.table(file=filename,sep ='\t', head=T)

#p <- ggplot(subset(data,dangle==curDangle & barrier_heuristic==curBarrier), aes(transcription_rate,Score,group=SequenceName,color=SequenceName))



# for special sequences of SRP, for better visualization
#structs0_transient= c(         )

#not decreasing between 250 and 300 
SRPseqNoDecreaseAt250_300nts=c("CP000712.1/1786696-1786793","CP000076.1/2115321-2115418","CP000090.1/2325066-2325165","CP000075.1/2101610-2101707","CP000058.1/2086711-2086808","ACIS01000002.1/252560-252659","CP000086.1/2494952-2495047","CP000013.1/484623-484720","CP001068.1/1100816-1100717","CP000450.1/597363-597461","AE009952.1/1179172-1179269","AL590842.1/3498558-3498461","CP001048.1/1157694-1157791","AL157959.1/1147858-1147765","AE016795.3/3219836-3219740","CP000010.1/1421960-1421865","CU633749.1/2046219-2046315","CP000720.1/3460787-3460690","CP000116.1/544561-544656","CP000671.1/1242908-1242809","BX571662.1/289282-289380", "CP000570.1/2200688-2200593","AE016825.1/2560853-2560754","CP000086.1/2494952-2495047")

SRPseqDecrease250_300nts = c("*X01074.1/170-275","CP001127.1/532559-532656","U00096.2/475680-475777","FM180568.1/436931-437028","CP001138.1/505976-506073")

SRPseqDecreaseOver300nts = c("CP000020.2/1087907-1087810","X14404.1/127-224")

trpSeq = c("*AE005174.2/2263095-2263188","M60741.1/37-130","CP000653.1/2394233-2394327","J01557.1/117-211","J01739.1/99-194")


#shownSequences = SRPseqNoDecreaseAt250_300nts
shownSequences = SRPseqDecrease250_300nts
#shownSequences = SRPseqDecreaseOver300nts

#shownSequences = trpSeq

p <- ggplot(subset(data,dangle==curDangle & barrier_heuristic==curBarrier & SequenceName %in% shownSequences), aes(transcription_rate,Score,group=SequenceName,color=SequenceName))

p<- p + geom_point(size=3) 
p<- p + geom_line(aes(group=SequenceName))

p <- p + theme(axis.text.x = element_text(size=35,face="bold",angle=90),axis.text.y = element_text(size=35,face="bold"),axis.title=element_text(size=25,face="bold"),legend.position="top", legend.background=element_rect(colour="black"),panel.background=element_rect(fill="white"),panel.grid.major = element_line(colour = "lightgray"),panel.grid.minor = element_line(colour = "#dddddd"), axis.title.x = element_text(colour="black"), axis.title.y = element_text(colour="black"), axis.line = element_line(size=1))
#

p <- p + ylab("bp diversity")                         
p <- p + xlab("transcription rate nt/s")
p <- p + scale_y_continuous(expand=c(0,0),limits=c(0,0.005))
p <- p + scale_x_continuous(expand=c(0,0),limits = c(0,510), breaks = c(0,50,100,150,200,250,300,350,400,450,500), minor_breaks = seq(0,510,10))
p
 
#outputFile=paste0("pictures/base pair diversity/","SRPseqNoDecreaseAt250_300nts",".png")
outputFile=paste0("pictures/base pair diversity/","SRPseqDecrease250_300nts",".pdf")
#outputFile=paste0("pictures/base pair diversity/","SRPseqDecreaseOver300nts",".png")
#outputFile=paste0("pictures/base pair diversity/",input,".pdf")
ggsave(file=outputFile, plot=p)




###timeDependedBPCountScore For REFERENCE SEQUENCES with Time period

timePeriod=2
timePeriod=5
timePeriod=10

#name="SRP"
#input=paste0("X01074.1_170-275_TimePeriod_",timePeriod)

name="TRP"
input=paste0("AE005174.2_2263095-2263188_TimePeriod_",timePeriod)


#name="RNAseP"
#input=paste0("CP001509.3_3136785-3136410_TimePeriod_",timePeriod)


filename= paste0("data/SimpleSequenceScores/refSequenceScore/perTimePeriod/",input)
data <- read.table(file=filename,sep ='\t', head=T)

p <- ggplot(data, aes(transcription_rate,Score,color=as.character(dangle),shape=(barrier_heuristic)))
p <- p + geom_point(size=5)
p <- p + geom_line()
p <- p + theme(axis.text.x = element_text(size=35,face="bold",angle=90),legend.position="top",legend.title = element_blank(),axis.text.y = element_text(size=35,face="bold"),axis.title=element_text(size=25,face="bold"),legend.text=element_text(size=20), legend.background=element_rect(colour="black"),panel.background=element_rect(fill="white"),panel.grid.major = element_line(colour = "lightgray"),panel.grid.minor = element_line(colour = "#dddddd"), axis.title.x = element_text(colour="black"), axis.title.y = element_text(colour="black"), axis.line = element_line(size=1))

p <- p + ylab("ensemble diversity")                         
p <- p + xlab("transcription rate nt/s")
p <- p + scale_y_continuous(expand=c(0.02,0),limits=c(0,0.1))
p <- p + scale_x_continuous(expand=c(0,0),limits = c(0,510), breaks = c(0,50,100,150,200,250,300,350,400,450,500), minor_breaks = seq(0,510,10))
p <- p + scale_color_manual(name    = "dangle model",  #legende name
                            breaks  = c("0", "2"),	# Werte der Tabelle
                            labels  = c("dangle=0", "dangle=2"),  # Werte beschreiben
                            values  = c("#ec4000","darkblue"))
p <- p + scale_shape_manual(name = "barrier heuristic",
                            values=c(8,1),
                            labels = c("findpath","morgan higgs"))
			   
p

outputFile=paste0("pictures/base pair diversity/TimePeriod/",input,".pdf")
ggsave(file=outputFile, plot=p)

######Ensemble Distance

#structureUsed = "AE005174.2.alternative1.str"
#structureUsed = "AE005174.2.alternative2.str"
#structureUsed = "CP001509.3.functional_withoutPseudoloop.str"
#structureUsed = "CP001509.3.functional.str_with Pseudoloop.str"
structureUsed = "X01074.1.functional.str"
#structureUsed = "X01074.1.transient.str"



inputFile= paste0("data/BP AppearenceInFamilyPerParaset/",structureUsed);
data <- read.table(file= inputFile,sep ='\t', head=T)


p <- ggplot(data, aes(transcription_rate,Score,color=as.character(dangle),shape=(barrier_heuristic)))
p<- p + geom_point(size=5) 
p<- p + geom_line() 

p<-p + theme(axis.text.x = element_text(size=16,face="bold"),axis.text.y = element_text(size=16,face="bold"), legend.background=element_rect(colour="black"),panel.background=element_rect(fill="white"),panel.grid.major = element_line(colour = "lightgray"),panel.grid.minor = element_line(colour = "#dddddd"), axis.title.x = element_text(colour="black"), axis.title.y = element_text(colour="black"),axis.line = element_line(size=1))


p <- p + ylab("ensemble distance")                         
p <- p + xlab("transcription rate nt/s")
p <- p + scale_y_continuous(expand=c(0,0),limits=c(0,1))
p <- p + scale_x_continuous(expand=c(0,0),limits = c(0,510), breaks = c(0,50,100,150,200,250,300,350,400,450,500), minor_breaks = seq(0,510,10))
p <- p + scale_color_manual(name    = "dangle model",  #legende name
                            breaks  = c("0", "2"),	# Werte der Tabelle
                            labels  = c("dangle=0", "dangle=2"),  # Werte beschreiben
                            values  = c("#ec4000","darkblue"))
p <- p + scale_shape_manual(name = "barrier heuristic",
                            values=c(8,1),
                            labels = c("findpath","morgan higgs"))




p


outputFile= paste0("pictures/foldingEnsembleToReferenceSimilarity/",structureUsed,".png")
ggsave(p,file = outputFile)


##Ensemble distance for each alignment sequence

#structureUsed="refAppearence_SRP_functional"
#structureUsed="refAppearence_SRP_transient"
#structureUsed="refAppearence_AntiTerminator"
#structureUsed="refAppearence_Terminator"

#structureUsed="ensembleDistance_terminator"
structureUsed="ensembleDistance_alternative1"
structureUsed="ensembleDistance_alternative2"

#structureUsed="ensembleDistance_SRPFunctional"
#structureUsed="ensembleDistance_SRPtransient"
structureUsed="ensembleDistance_RNAseP"



#structureUsed= "ensembleDistance"
#structureUsed = "AE005174.2.alternative1.str"
# structureUsed = "AE005174.2.alternative2.st"
#structureUsed = "CP001509.3.functional_withoutPseudoloop.str"
#structureUsed = "CP001509.3.functional.str_with Pseudoloop.str"
#structureUsed = "X01074.1.functional.str"
#structureUsed = "X01074.1.transient.str"


#SRPseqDecrease250_300nts =c("X01074.1/170-275","CP001127.1/532559-532656","FM180568.1/436931-437028","U00096.2/475680-475777","CP001138.1/505976-506073")                              

TRPseqDecrease250_300nts =c("AALF02000036.1/7566-7465","AAPS01000055.1/16549-16446","M24960.1/62-157")


curBarrier="B"
#curBarrier="M"
curDangle="2"
#curDangle="0
# inputFile= paste0("data/BP AppearenceInFamilyPerParaset/ForEachHomolog/",structureUsed);
inputFile= paste0("data/EnsembleDistance/AllSequences/",structureUsed);
#inputFile= "data/EnsembleDistance/AllSequences/ensembleDistance"

data <- read.table(file= inputFile,sep ='\t', head=T)

#p <- ggplot(subset(data,dangle==curDangle & barrier_heuristic==curBarrier & acessionNumber %in% TRPseqDecrease250_300nts), aes(transcription_rate,Score,group=acessionNumber,color=acessionNumber))
p <- ggplot(subset(data,dangle==curDangle & barrier_heuristic==curBarrier), aes(transcription_rate,Score,group=acessionNumber,color=acessionNumber))

p<- p + geom_line(size=1,position=position_jitter(width=0,height=0.01))

#title = paste0("ensemble distance: TRP to trpL terminator")
#title = paste0("ensemble distance: SRP to transient")
#title = paste0("ensemble distance: RNAseP to functional")

#p <- p+ ggtitle(title)

p <- p + theme(axis.text.x = element_text(size=35,face="bold",angle=90),axis.text.y = element_text(size=35,face="bold"),axis.title=element_text(size=25,face="bold"),legend.position="none", legend.background=element_rect(colour="black"),panel.background=element_rect(fill="white"),panel.grid.major = element_line(colour = "lightgray"),panel.grid.minor = element_line(colour = "#dddddd"), axis.title.x = element_text(colour="black"), axis.title.y = element_text(colour="black"), axis.line = element_line(size=1))
#

p <- p + ylab("ensemble distance")      
#p <- p + ylab("terminator bp appearence %")      

p <- p + xlab("transcription rate nt/s")
p <- p + scale_y_continuous(expand=c(0,0),limits=c(-0.01,1.1))
p <- p + scale_x_continuous(expand=c(0,0),limits = c(0,510), breaks = c(0,50,100,150,200,250,300,350,400,450,500), minor_breaks = seq(0,510,10))
p
 
# outputFile= paste0("pictures/foldingEnsembleToReferenceSimilarity/forEachSequence/",structureUsed,".png")
outputFile= paste0("pictures/ensembleDistance/",structureUsed,".pdf")

ggsave(p,file = outputFile)


######ENsemble distance for few sequences, for better visualization
#structureUsed = "AE005174.2.alternative1.str"
#structureUsed = "AE005174.2.alternative2.str"
#structureUsed = "CP001509.3.functional_withoutPseudoloop.str"
#structureUsed = "CP001509.3.functional.str_with Pseudoloop.str"
#structureUsed = "X01074.1.functional.str"
structureUsed = "X01074.1.transient.str"

curBarrier="B"
#curBarrier="M"
curDangle="2"
#curDangle="0


inputFile= paste0("data/BP AppearenceInFamilyPerParaset/ForEachHomolog/",structureUsed);
data <- read.table(file= inputFile,sep ='\t', head=T)


structs0_transient= c("ACIS01000002.1/252560-252659","CP000086.1/2494952-2495047","CP000013.1/484623-484720","CP001068.1/1100816-1100717","CP000020.2/1087907-1087810",           "CP000450.1/597363-597461","AE009952.1/1179172-1179269","AL590842.1/3498558-3498461","CP001048.1/1157694-1157791","AL157959.1/1147858-1147765","AE016795.3/3219836-3219740" ,"CP000010.1/1421960-1421865","CU633749.1/2046219-2046315","CP000720.1/3460787-3460690","CP000116.1/544561-544656","CP000671.1/1242908-1242809","BX571662.1/289282-289380", "CP000570.1/2200688-2200593","AE016825.1/2560853-2560754","CP000086.1/2494952-2495047")

structs50_transient= c("CP000076.1/2115321-2115418","CP000090.1/2325066-2325165","CP000075.1/2101610-2101707","CP000058.1/2086711-2086808","X14404.1/127-224")

structs75_transient = c("CP001127.1/532559-532656","*X01074.1/170-275","FM180568.1/436931-437028","U00096.2/475680-475777","CP000712.1/1786696-1786793","CP001138.1/505976-506073")

structs_alternative2 = c("M24960.1/62-157","FM200053.1/1217752-1217657","AM286415.1/2419797-2419898","BX950851.1/2602822-2602926")
                            
SRPseqDecrease250_300nts =c("X01074.1/170-275","CP001127.1/532559-532656","FM180568.1/436931-437028","U00096.2/475680-475777","CP001138.1/505976-506073")                              

 
 




trpSeq75_alternative1=c("*AE005174.2/2263095-2263188","M60741.1/37-130","J01739.1/99-194")
trpSeq50_alternative1=c("M24960.1/62-157","BX571867.1/113873-113973","CP000826.1/2936614-2936717","AM286415.1/2419797-2419898","AAOJ01000014.1/31576-31482","FM200053.1/1217752-1217657","AALF02000036.1/7566-7465","AALD02000034.1/37477-37578")

trpSeq0_alternative1 = c("CP000653.1/2394233-2394327","J01557.1/117-211","AAWP01000078.1/5392-5495","AAMR01000069.1/10988-11102","AAPS01000055.1/16549-16446","BA000037.2/1235781-1235679","BX950851.1/2602822-2602926","CP000720.1/2235898-2235999","AY027546.1/150-252","CP001233.1/1206524-1206422","X17149.1/292-395")




trpSeq75_alternative2=c("*AE005174.2/2263095-2263188","M60741.1/37-130","J01739.1/99-194","AALF02000036.1/7566-7465","AM286415.1/2419797-2419898","CP000653.1/2394233-2394327","J01557.1/117-211","AAMR01000069.1/10988-11102","AAPS01000055.1/16549-16446","BA000037.2/1235781-1235679","BX950851.1/2602822-2602926","CP000720.1/2235898-2235999","AY027546.1/150-252","CP001233.1/1206524-1206422","X17149.1/292-395")
trpSeq50_alternative2=c("AAOJ01000014.1/31576-31482","AALD02000034.1/37477-37578","M24960.1/62-157","BX571867.1/113873-113973","CP000826.1/2936614-2936717","FM200053.1/1217752-1217657")
trpSeq0_alternative2 =c("AAWP01000078.1/5392-5495")


#usedStruct=trpSeq0_alternative1
#usedStruct=trpSeq50_alternative1
#usedStruct=trpSeq75_alternative1
#usedStruct=trpSeq0_alternative2
#usedStruct=trpSeq50_alternative2
#usedStruct=trpSeq75_alternative2

usedStruct=SRPseqDecrease250_300nts
#usedStruct= structs75_transient
#usedStruct= structs50_transient
#usedStruct= structs0_transient
#usedStruct= structs_alternative2

p <- ggplot(subset(data,dangle==curDangle & barrier_heuristic==curBarrier & acessionNumber %in% usedStruct), aes(transcription_rate,Score,group=acessionNumber,color=acessionNumber))


p<- p + geom_line(size=1,position=position_jitter(width=0.01,height=0.01))
p<- p + theme(legend.text = element_text(size = 10))
p<-p + theme(axis.text.x = element_text(size=16,face="bold"),axis.text.y = element_text(size=16,face="bold"), legend.background=element_rect(colour="black"),panel.background=element_rect(fill="white"),panel.grid.major = element_line(colour = "lightgray"),panel.grid.minor = element_line(colour = "#dddddd"), axis.title.x = element_text(colour="black"), axis.title.y = element_text(colour="black"),axis.line = element_line(size=1))


p <- p + ylab("bp diversity")                         
p <- p + xlab("transcription rate nt/s")
p <- p + scale_y_continuous(expand=c(0,0),limits=c(-0.01,1))
p <- p + scale_x_continuous(expand=c(0,0),limits = c(0,510), breaks = c(0,50,100,150,200,250,300,350,400,450,500), minor_breaks = seq(0,510,10))
p


#outputFile= paste0("pictures/refStructSimilarityScorefForFamily/AE005174.2.alternative1.str_special_sequences2.png")

outputFile= paste0("pictures/refStructSimilarityScorefForFamily/bpAppearence_",structureUsed,"SRPseqDecrease250_300nts.png")
#outputFile= paste0("pictures/refStructSimilarityScorefForFamily/bpAppearence_",structureUsed,"Group0.png")
#outputFile= paste0("pictures/refStructSimilarityScorefForFamily/bpAppearence_",structureUsed,"Group0.50.png")
#outputFile= paste0("pictures/refStructSimilarityScorefForFamily/bpAppearence_",structureUsed,"Group0.75.png")
ggsave(p,file =outputFile)






####NO IDEA WHAT THIS IS Ensemble Distance

input="RF00169_realigned"
#input="RF00513_realigned"
#input="extended.RF00010"


filename= paste0("data/EnsembleDistance/",input)
data <- read.table(file=filename,sep ='\t', head=T)

p <- ggplot(data, aes(transcription_rate,distance,color=as.character(dangle),shape=(barrier_heuristic)))
p <- p + geom_point(size=5)

p<-p + theme(axis.text.x = element_text(size=16,face="bold"),axis.text.y = element_text(size=16,face="bold"), legend.background=element_rect(colour="black"),panel.background=element_rect(fill="white"),panel.grid.major = element_line(colour = "lightgray"),panel.grid.minor = element_line(colour = "#dddddd"), axis.title.x = element_text(colour="black"), axis.title.y = element_text(colour="black"),axis.line = element_line(size=1))


p <- p + ylab("ensemble distance")                         
p <- p + xlab("transcription rate nt/s")
p <- p + scale_y_continuous(expand=c(01,0),limits=c(0,1))
p <- p + scale_x_continuous(expand=c(0,0),limits = c(0,510), breaks = c(0,50,100,150,200,250,300,350,400,450,500), minor_breaks = seq(0,510,10))
p <- p + scale_color_manual(name    = "dangle model",  #legende name
                            breaks  = c("0", "2"),	# Werte der Tabelle
                            labels  = c("dangle=0", "dangle=2"),  # Werte beschreiben
                            values  = c("#ec4000","darkblue"))
p <- p + scale_shape_manual(name = "barrier heuristic",
                            values=c(8,1),
                            labels = c("findpath","morgan higgs"))




p

outputFile=paste0("pictures/ensembleDistance/",input,".png")
ggsave(file=outputFile, plot=p)







####FOR AVERAGE PLOT

#input="RF00169_realigned"
#input="RF00513_realigned"
input="extended.RF00010"
curBarrier="B"
#curBarrier="M"
curDangle="2"
#curDangle="0"

filename=paste0("data/familyAPScore/",input);
data <- read.table(file= filename,sep ='\t', head=T)

p2 <- ggplot(subset(data,dangle==curDangle & barrier_heuristic==curBarrier), aes(transcription_rate,Score))
p2 <- p2 + theme(axis.text.x = element_text(size=10,face="plain",angle=90),axis.text.y = element_text(size=16,face="bold"))
p2 <- p2 + geom_line()
title = paste0("Average Score of ", input," family\nBarrier Heuristic = ",curBarrier," , Dangle = ",2,"\n")
p2 <- p2+ ggtitle(title)
p2 <- p2 + ylab("Score")                         
p2 <- p2 + xlab("Transcription Rate nt/s")
p2 <- p2 + scale_x_discrete( limits = data["transcription_rate"])
p2 <- p2 + scale_y_continuous(limits=c(0,0.01))
p2

outputfile=paste0("pictures/simpleScore_ForFamily/",input,"/average/",input,"_",curBarrier,"_",curDangle,"_AVERAGE.svg")
ggsave(file=outputfile, plot=p2, width =23,height=11)


multi <- multiplot(p,p2,pb,cols=2)
outputfile=paste0("pictures/timeDependedBPCountScoreForFamily/",input,"_",curBarrier,"_",curDangle,".jpeg")

jpeg(filename = outputfile,height=1500,width=3024, pointsize =12, bg = "white", res = NA)
multiplot(p,pb,cols=2)
dev.off()



## multiplot function
multiplot <- function(..., plotlist = NULL, file, cols = 1, layout = NULL) {
  require(grid)

  plots <- c(list(...), plotlist)

  numPlots = length(plots)

  if (is.null(layout)) {
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                    ncol = cols, nrow = ceiling(numPlots/cols))
  }

  if (numPlots == 1) {
    print(plots[[1]])

  } else {
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))

    for (i in 1:numPlots) {
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

