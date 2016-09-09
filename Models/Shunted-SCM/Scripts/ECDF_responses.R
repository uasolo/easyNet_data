ECDF_activity = function (au,
                         dv = "active_units",
                         theta_y =  c(0, 0.01, 0.03, 0.05, 0.1, 0.2, 0.5),
                         xlim = NULL,
                         dv_lab = "A") {
# un/comment the relevant explored parameter, activity_threshold or spoc.excitation
  
n = nrow(au)/length(unique(au$activity_threshold)) 
#n = nrow(au)/length(unique(au$spoc.excitation)) 

max_A = max(au[[dv]][au$activity_threshold == theta_y[1]])
#max_A = max(au[[dv]])

if (is.null(xlim)) {xlim = c(0,10*(ceiling(max_A/10)))}


# plot params
op = par(mar= c(5.1, 5.1, 6, 2.1))
line_sep = 0.1
first_line_level = 1.2
# 3 rows of parameters at the top of the plot
plot(xlim, c(0,1), type= 'n', las=1, xlab = eval(substitute(expression(N[x]), list(x = dv_lab))),
     ylab = eval(substitute(expression(paste("ECDF", (N[x]))), list(x = dv_lab))))
text(0 , first_line_level + line_sep, expression(paste(theta[y], "=")),  xpd = TRUE, pos = 2)
#text(0 , first_line_level + line_sep, expression(paste(alpha, "=")),  xpd = TRUE, pos = 2)
segments(0, first_line_level - line_sep *0.5 , 0, first_line_level + line_sep *2.5 , xpd = TRUE)
segments(0,first_line_level - line_sep *0.5,0.5, first_line_level - line_sep *0.5, xpd = TRUE)
segments(0,first_line_level + line_sep *2.5,0.5, first_line_level + line_sep *2.5, xpd = TRUE)

abline(h = 0.5, lty=2)
text(xlim[2], 0.5, "median", adj =c(1,-0.2))

#spocs = sort(unique(au$spoc.excitation))

for (i in 1:length(theta_y))
#for (i in 1:length(spocs))
{
    N_A = sort(au[[dv]][au$activity_threshold == theta_y[i]])
    #N_A = sort(au[[dv]][au$spoc.excitation == spocs[i]])
    lines(N_A,
                   (1:n)/n, type = 's') #, lwd = 1 + 2*(i %% 2))
    max_Ai = max(au[[dv]][au$activity_threshold == theta_y[i]])
    #max_Ai = max(au[[dv]][au$spoc.excitation == spocs[i]])
    max_ECDF <- 1
    if (max_Ai > xlim[2]) {
      max_Ai <- xlim[2]
      max_ECDF <- length(N_A[N_A<=xlim[2]])/n
    }
    
 
    segments(max_Ai, max_ECDF, max_Ai, first_line_level + line_sep * ((i -1) %% 3), xpd = TRUE, lty = 3)
    text(max_Ai,  first_line_level + line_sep * ((i - 1) %% 3), theta_y[i], xpd = TRUE, pos = 4)
    #text(max_Ai,  first_line_level + line_sep * ((i - 1) %% 3), spocs[i], xpd = TRUE, pos = 4)
    }
par(op)
}