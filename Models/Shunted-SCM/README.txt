This folder contains the implementation of Shunted-SCM, a model described in
the paper:

Gubian et al. "Comparing single-unit recordings taken from a localist model to single-cell recording data: a good match"
Language, Cognition and Neuroscience, Special Issue

This folders also contains scripts and data sets that allow you to replicate
all the results reported in the paper. 

Please read the paper first.

REQUIREMENTS
- You need to have a version of easyNet installed
http://adelmanlab.org/easyNet/

- In order to reproduce the ECDF figures you also need to have R installed, i.e.
  your own copy of R (e.g. RStudio), independently of the one that is shipped
and embedded in easyNet.

INSTRUCTIONS
The original SCM is available from the standard easyNet installation.
The modified SCM described in Simulation 2 in the paper, here called Shunted-SCM, is
available in this folder. From easyNet, load the model script Shunted-SCM.eNm, which will load
the right vocabulary and will set the parameters as described in the paper.

Fig. 1 and 5 can be obtained by simply running a 'present' trial on the words
"sink" or "zebra" using SCM (Fig. 1) or Shunted-SCM (Fig. 5). 
Before running the trials, right click on the 'words' layer and select Plot ->
state -> by_time.


In order to compute selectivity a few steps are required. 
Eq. (1) is implemented in the R script number_of_responses.R. 
IMPORTANT: in order to let easyNet retrieve this script you have to copy it
into the directory:
$EASYNET_HOME/bin/R-library/dataframe_views/
where $EASYNET_HOME is the top directory of easyNet, i.e. where you start the
program (e.g. on Windows, where the file easyNet.exe is located). 

The script number_of_responses.R computes Eq. (1) for a single stimulus,
for all nodes and for your choice of activity thresholds theta_y.
In order to collect a large number of responses, the simulator script 
number_of_responses.eNs loops over several stimuli and accumulates results.
You can run this script from easyNet by loading it in the Scripts tab
available in the Expert window (use the glasses icon).
The output of this script is an R dataframe (a table saved as CSV file) with
as many columns as word units (plus one) and as many rows as threshold levels
theta_y. See the comments inside that script in order to extract the
realisations of the quantity N_R (number of responses) for the different
conditions found in the paper. 

In order to plot ECDFs as in the paper (Fig. 2-4), you can take the CSV
files that comes as results from active_nodes.eNs and input (df argument) them
to the R script ECDF_responses.R that you can run in your R environment (e.g.
import ths CSV file in RStudio; NOT in easyNet). See details inside the script.

Finally, in subfolder Stimuli/ you find the 1000 words and 1000 nonwords used for the 
identification and lexical decision tasks described in the last part of
Simulation 2. Load those stimuli in easyNet and run an 'id' or an 'ldt' task
on them.
