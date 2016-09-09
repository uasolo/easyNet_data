function(                                                      # EXTRACT NODES RESPONDING TO A STIMULUS
  df=factor(levels=dataframes(eN))[[1]],                  # Dataframe                      # data frame (observer), e.g. (words default_observer)
 activity_threshold=c(0, 0.01, 0.03, 0.05, 0.1)      # Activity threshold          # Min increase in activity from resting level to yield a response (theta_y in the paper) 
) {
  tryCatch(
    {  
      if (nrow(df) < 1) stop ("input table is empty")
      if ("trial_counter" %in% colnames(df)) stop("this function works for single trials only")
      df = df[!is.na(df$time), colnames(df) != "time"]
      res <- as.data.frame(matrix(data=NA, nrow=length(activity_threshold), ncol=ncol(df)))
      colnames(res) <- colnames(df)
      
      # Eq. (1) in the paper
      response = function(x, thr) {max(x) - x[1] > thr}
      for (i in 1:length(activity_threshold))
      {
        res[i,] <- apply(df, 2, response, thr=activity_threshold[i])
      }
      return (res)
    }, warning = function(w) { print(w); 
      
    }, error = function(e) { print(e); err<-data.frame(error=as.character(e$message));err$error=as.character(err$error); return(err)
    
    }, finally = { 
      
    }
  )  
}
