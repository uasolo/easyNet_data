mf = .45
vocab.name = "SCM-CELEX.eNd"
vocab=read.table(paste0("../Databases/Vocab_files/scm/",vocab.name),head=T,stringsAsFactors = F)
head(vocab)
vocab$len = nchar(as.character(vocab$Word))
vocab$MF = 1 + (vocab$len - 4) * mf
vocab$RMF = 1/vocab$MF
write.table(vocab,paste0("../Databases/Vocab_files/scm/","mf.",format(mf,2),".",vocab.name),
                    row.names = F,quote = F)
