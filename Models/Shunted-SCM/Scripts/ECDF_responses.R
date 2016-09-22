ECDF_responses = function (resp= NULL, # a dataframe or a list of dataframes.
                           # Each dataframe has as many rows as theta_y and N = number of units columns
                         alpha = c(2), # as many as the resp dataframes, one per value of alpha tested
                         theta_y =  c(0, 0.01, 0.03, 0.05, 0.1),
                         selected_theta_y = 4, # if one ECDF per alpha, the index of theta_y to pick from every resp dataframe
                         xlim = c(0,30),
                         dv_lab = "R" # just a way to indicate the letter subscrit of N, i.e. number of ...
                         ) {
  if (!is.list(resp)) stop ("provide a response df or a list of them as resp= argument")
 
if (!is.data.frame(resp) & length(resp) != length(alpha)) stop ("response dataframes should correspond to alpha levels")
if (length(alpha) > 1 & length(selected_theta_y) != 1) stop ("either multiple levels of alpha or of theta_y can be plotted")



# give more room at the top of the plot to include labels
op = par(mar= c(5.1, 5.1, 6, 2.1))
line_sep = 0.1
first_line_level = 1.2
# 3 rows of parameters at the top of the plot
plot(xlim, c(0,1), type= 'n', las=1, xlab = eval(substitute(expression(N[x]), list(x = dv_lab))),
     ylab = eval(substitute(expression(paste("ECDF", (N[x]))), list(x = dv_lab))))
if (length(alpha)==1) {
  text(0 , first_line_level + line_sep, expression(paste(theta[y], "=")),  xpd = TRUE, pos = 2)
} else {
  text(0 , first_line_level + line_sep, expression(paste(alpha, "=")),  xpd = TRUE, pos = 2)
}
segments(0, first_line_level - line_sep *0.5 , 0, first_line_level + line_sep *2.5 , xpd = TRUE)
segments(0,first_line_level - line_sep *0.5,0.5, first_line_level - line_sep *0.5, xpd = TRUE)
segments(0,first_line_level + line_sep *2.5,0.5, first_line_level + line_sep *2.5, xpd = TRUE)

# mark the median
abline(h = 0.5, lty=2)
text(xlim[2], 0.5, "median", adj =c(1,-0.2))

# plot the ECDF, plus some heuristics on where to place the label on each curve
do_ecdf <- function (v, param=NULL, param_index=1) {
  x <- sort(v)
  n <- length(x)
  lines(x, (1:n)/n, type = 's')
  # placement of label
  if (!is.null(param)) {
    # print medians
    print(paste("median", param, x[round(n/2)]))
    max_x <- as.numeric(x[n])
    if (max_x > xlim[2]) {
      max_x <- xlim[2]
    }
    lab_x <- max_x * (1 - 0.1*(param_index -1))
    lab_y <- length(x[x<=lab_x])/n
    segments(lab_x, lab_y, lab_x, first_line_level + line_sep * ((param_index -1) %% 3), xpd = TRUE, lty = 3)
    text(lab_x,  first_line_level + line_sep * ((param_index - 1) %% 3), param, xpd = TRUE, pos = 4)
  }
}

# if testing alpha, one curve for each alpha, pick the selected theta_y (Fig. 4)
if (length(alpha) > 1) {
  for (i in seq_along(alpha)) {
    do_ecdf(resp[[i]][selected_theta_y,-1], alpha[i], i)
    }
  }
else { # else all theta_y levels (Fig. 2 and 3)
  for (i in seq_along(theta_y)) {
    do_ecdf(resp[i, -1], theta_y[i], i)
    }
  }
par(op)
}

#data_dir <- "C:/Users/mm14722/Dropbox/scambio_temp/work/easyNet_data/single unit paper/"
#resp <- Reduce('+', lapply(c("1a","1b","1c","1d","2","3","4"), function(x) {read.csv(paste0(data_dir,"responses_SCM_all",x,".csv"))}))
#ECDF_responses(resp)
