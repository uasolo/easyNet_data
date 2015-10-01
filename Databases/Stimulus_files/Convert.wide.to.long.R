library(tidyr)
wide = read.table("Davis_Lupker_06_Exp1_4LWs_in.txt",header=T)
names(wide)
conds = names(wide)[-(1:2)]
long = gather(wide, cond, prime,  RW, URW, RN, URN)
head(long)
long$Target<-tolower(long$Target)
colnames(long)<-tolower(colnames(long))
write.table(long,"Davis_Lupker_06_Exp1_4LWS.eNd",quote=F,row.names=F)
