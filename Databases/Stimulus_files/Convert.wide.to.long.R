library(tidyr)

convert.to.long <- function(fname)
{
  wide = read.table(fname,header=T)
  names(wide)
  conds = paste(names(wide)[-(1:2)],collapse=",")
  long = eval(parse(text = paste("gather(wide, cond, prime,  ", conds, ")")))
  head(long)
  long$Target<-tolower(long$Target)
  colnames(long)<-tolower(colnames(long))
  write.table(long,gsub(".txt",".eNd",fname),quote=F,row.names=F)
}

f.list=dir(".", pattern = ".txt", full.names = TRUE, recursive = TRUE,
             include.dirs = TRUE, 
             ignore.case = TRUE)
d=data.frame()

for (i in f.list) d = rbind(d, convert.to.long(i))

