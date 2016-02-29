#A simple model

We are going to build a very simple model that represents the mapping between lower case (LC) letters and corresponding upper case (UC) letters. The model will consist of two layers and one connection between the two. One layer holds a localist representation of (a subset of) all LC letters of the English alphabet, i.e. one node for each letter, while the other layer holds the same type of representation for UC letters, and a connection from the former to the latter links every LC letter node to its corresponding UC letter node with an excitatory link. 
The LC letters layer will serve as input. This model expresses the idea that whenever a representation of a LC letter gets activated then the representation of its corresponding UC gets activated too, even though no UC letter is available as input to the model. Here we are not taking any position on this theory, but rather we are using it to illustrate the steps involved in modelling such theory using *lazyNut*.

In order to build the model architecture with *lazyNut* we will not use only layers and connections, but also other types of objects, such as  representations and conversions, which make it possible to automate the model construction and to determine its behaviour at run time. 

After that, we will also design a trial. In general terms a trial defines a task that a model can carry out. In our case, the trial consists in the exposition to a LC input stimulus for a specified amount of time. Even though this does not sound like a task, e.g. the model does not take any decision based on the input value, it gives the possibility to see the result of the exposition to an input by appreciating how the model state changes in time.    

## The model script
The first line in every *lazyNut* script defining a model looks like this:

	create model mini_uc
where you specify the name of the model. Under the hood, this instruction created the object `(mini_uc parameters)`, which is a dataframe object that will store all the model parameters (see [bracketed notation](bracketed_notation) for an explanation on how brackets are used in *lazyNut*). 

In order to set up the two layers and the connection the way we want, we need to tell *lazyNut* what each layer represents and how the connection is wired. These two goals are achieved by using representation and conversion objects, respectively. A representation specifies a data format. In this example we will use two types of representation, namely a `string_representation`, which represents a string of characters of unspecified length, and a `keyed_representation`, which represents a set of named units, such as the letters "a", "b" and "c". A layer is associated to one and only one representation, that is to say a layer codifies knowledge of a specific type. A conversion specifies the rules to convert from a source representation to a target representation. For example, a conversion can specify that the named units  "a", "b" and "c" of a `keyed_representation` map to their corresponding strings in a `string_representation`. Note that a conversion from a source to a target representation does not imply its inverse to exist, nor does say anything about the inverse when this exists. Moreover, more than a conversion can be defined between the same source and target representation.

Although representations and conversions can be created explicitly, in the majority of cases we let  *lazyNut* create them for us by means of a dataframe. A dataframe is a table of values that can be imported from a text file. The table we use looks like this:

<table style="width:50%">
	<tr>
    <th>lower_case</th>
	<th>upper_case</th>
	</tr>
	<tr>
    	<td>a</td>
		<td>A</td>
	</tr>
	<tr>
    	<td>b</td>
		<td>B</td>
	</tr>
	<tr>
    	<td>c</td>
		<td>C</td>
	</tr>
 </table>

In order to make this table available to *lazyNut* in the form of a dataframe, first we instantiate  an empty dataframe object, then we load the text file containing the table into the object:

	create dataframe_for_reps lc2uc_df	
	lc2uc_df load Databases/lc2uc.eNd

By declaring the dataframe to be of subtype `dataframe_for_reps` we are triggering the automatic generation of a number of default representations and conversions. Four representations have been created, two for each column in `lc2uc_df`. Since each column contains strings, a  `string_representation` is created for each of them. Then, since each column contains non numeric values, a `keyed_representation` is created for each column too. These two  representation subtypes are quite different from each other.

A `string_representation` is a vector of strings of arbitrary length. In our example the vector is uni-dimensional, i.e. it is just a string, since each column contains string values without spaces.  Any connected string, say "word", is a legal pattern for this representation, regardless of the fact that "word" is not a value in the   `lc2uc_df` column that originated the representation. 
Crucially, although the `string_representation`s originated from the two columns of `lc2uc_df` are in fact identical, they are distinct objects, which means that no rule says that the pattern "word" in one representation corresponds to the pattern "word" or "WORD" or anything else in the other. Such correspondences are established by conversions, as will be explained below.
  
A `keyed_representation` is conceptually a vector of binary values (keys) whose dimension are the (unique) keys of the corresponding  dataframe column. In our case the `lower_case` column generated a `keyed_representation` of length three where the pattern "a" means 1 in position "a", 0 in position "b", 0 in position "c", or <1, 0, 0>. Here the values "d" or "word" correspond to <0, 0, 0>. A `keyed_representation` is the natural way to define and set up a localist representation in a layer, i.e. each key corresponds to a named unit or node in a layer. 
The four representations created from  `lc2uc_df` have names like this:

	(lc2uc_df column_rep lower_case keyed_representation)
that more or less reads: "this is a `keyed_representation` obtained from the `lower_case` column of the  `lc2uc_df` table". 

Loading the table above into `lc2uc_df` triggered also the creation of six conversions, two pairs of conversions between the representations associated to each column of  `lc2uc_df` and a pair converting between the `keyed_representation`s of the two columns. For example, the conversion

	((lc2uc_df column_rep lower_case keyed_representation) conversion_key)
converts from the `string_representation` to the `keyed_representation` associated with the `lower_case` column, while the reverse conversion has a similar name ending with `conversion_unkey`. The conversions are established in the expected way, i.e. string "a" to key "a", etc.    These conversions will allow the user to input a keyed pattern like <1, 0, 0> by just typing "a".
Conversion

	(lc2uc_df conversion lower_case upper_case)
converts from `(lc2uc_df column_rep lower_case keyed_representation)` to `(lc2uc_db column_rep upper_case keyed_representation)` following the rules expressed in the `lc2uc_df` dataframe, i.e. key "a" to key "A", etc. These conversions allow *lazyNut* to infer the connectivity between the LC letter and the UC letter layer from the conversion operating between the corresponding representations. 

Once representations and conversions are in place, creating layers and connecting them takes a few lines of code. Layers are created as follows:

	create iac_layer lc_layer
	lc_layer represent (lc2uc_df column_rep lower_case keyed_representation)

	create iac_layer uc_layer
	uc_layer represent (lc2uc_df column_rep upper_case keyed_representation)

We are using a specific type of layer, the `iac_layer` or Interactive Activation and Competition layer, which contains activation units regulated by the  equations found in *Rumelhart & McClelland (1981)*. This type of layer has only one input port, called `net_input`, and its output is identical to the internal state, i.e. the level of activation of each of the nodes. The code snippet above says that layers `lc_layer` and `uc_layer` represent the `keyed_representation` of LC and UC letters, respectively, which in turn means that those layers contain  units named after the  keys of their internal `keyed_representation`, viz. units  "a", "b" and "c" for `lc_layer` and units "A" "B" and "C" for `uc_layer`. At this point those units are not connected to each other, neither within a layer nor between layers. A connection wiring from `lc_layer` to `uc_layer` is instantiated as follows:

	create connection lc_uc_connection
	lc_uc_connection autoconnect lc_layer uc_layer

where the 'magic' command `autoconnect` will try and find a conversion between the internal representation of `lc_layer` and the one of `uc_layer` (in this direction) and use that rule to determine which nodes in the source layer are linked to which nodes in the target layer  with an excitatory link. That conversion is `(lc2uc_df conversion lower_case upper_case)`, which in practice reads the table above from left to right. 

More in general, when we create a connection between two layers representing a  `keyed_representation` a so-called `sparse_connection` is  created. This type of connection links all nodes of the source layer to all nodes of the target layer with a link that can be either excitatory or inhibitory. When a conversion rule is applied to define the connection wiring what actually happens is that the links specified by the rule, e.g. from "a" to "A", are defined as excitatory, and all others, e.g. from "a" to "B", as inhibitory. Note that the terms "excitatory" and "inhibitory" only suggest their typical use but it is up to the user to specify a  strength value for them. In our case we will choose a positive value (e.g. 0.07) for excitatory links and zero for inhibitory links, which means that we will not introduce inhibitory actions in the model. 
These and other model parameters will be specified below.

Parameters are loaded in from table-like text files in the same way as other tables:

	(mini_uc parameters) load Databases/Parameter_Sets/MINI/mini_uc.eNp
In the file we note, among others, the excitatory and inhibitory strength parameters for `lc_uc_connection` and the parameters  `min_act` and `max_act` that determine minimum and maximum activation values for all nodes in all layers. 

Before importing the trial script, we define the model input, or better a possible input, since we can have more than one. We want the input to be `lc_layer` and we want to use strings to express values. This is achieved by the following command:
 
	mini_uc define_input lc_input (lc2uc_df column_rep lower_case string_representation) lc_layer
where we define `lc_input` as the model input slot acting on `lc_layer` and using the specified representation. More precisely, any time we will send the input string "a" for a certain amount of time, this will translate (by virtue of the conversion `((lc2uc_df column_rep lower_case keyed_representation) conversion_key)`) into the activation of the "a" unit of  `lc_layer`. Activating a unit in this way means that its activation value is set to `max_act` for the time of exposition to the stimulus and then back to resting value, which is zero by default.

## The trial script
The trial script is the following:

	create trial mini_trial
	mini_trial add_stimulus_event stimulus lc_input START +$duration $stimulus
where the trial object `mini_trial` is created and populated with only one event, the stimulus event named `stimulus`. This event is sent to  the model input slot `lc_input`, it lasts from time `START`, i.e. the beginning of the trial, until time `+$duration` (short for `START+$duration`) and it consists of the value `$stimulus`. The `$` sign denotes variable names, which the user has to specify each time the trial is run. Remarkably, the only assumption this trial definition does on the target model is that the model has an input slot named  `lc_input`. The model will interpret `$stimulus` as a pattern obeying to the representation defined for  slot `lc_input` and convert it to the representation of the relevant layer. In fact our model `mini_uc` does have a slot named   `lc_input`, which accepts strings as input and applies them to  `lc_layer` after converting them to a `keyed_representation`, as defined above. In general, a trial is a definition of a set of events that translate into sending values to input slots at specified points in time and of reactions to events occurring in a model, e.g. an activation exceeding a threshold value. The way trials are defined is largely independent of the target model, which makes it possible to run the same trial on different models, and dually to run different trials on the same model.

The trial script could be part of the model script, but it is preferable to keep it separated into another file and include it using the command

	  include Trials/mini_trial.eNs
emphasising the conceptual separation of models and trials.

## Running the trial and inspecting the model 
 An example of usage for `mini_trial` trial is:

	mini_trial step stimulus=a duration=5
where we ask the trial `mini_trial` to `step` through its events (in our case only one, `stimulus`) and we choose values for all its variables. Note that we do not have to use the `$` sign any more, since `variable=value` makes it redundant, i.e. `stimulus=a` assigns the string "a" to `$stimulus`, which happens to be a variable that parametrises the event `stimulus` (we advise the user to familiarise with this apparently confusing practice of using the same name for an event and its main variable).

In order to inspect the layers after having run a trial we have to enable some pre-defined observers (of type `nobservers`), which are objects that react to changes in layers and write the observed values to a target dataframe. If we want to observe the state of `lc_layer` and `uc_layer`, we have to run:

	(lc_layer default_observer) enable
	(uc_layer default_observer) enable
before running the trial. The observer `(lc_layer default_observer)` will write the state of `lc_layer`, i.e. the activation value of its three nodes, every time those change. After running the trial we retrieve the state values by issuing the command `get` on the target dataframes:

	((lc_layer default_observer) default_dataframe) get
	((uc_layer default_observer) default_dataframe) get
We can see that the state of `lc_layer` reflects the clamping of unit "a" on its maximum activation value 1 for the `$duration` of `stimulus`, while the state of `uc_layer` shows the gentle rising of the corresponding unit "A" following the exponential laws governing `iac_layer`. Clearly it is not convenient to inspect large numerical tables from the *lazyNut* console, for which purpose we encourage the user to use the GUI  software *easyNet* instead.

## Adding a self-loop
A recurring device in modelling competition in the localist approach is lateral inhibition. In its simplest form, each unit in a layer tries to suppress the activation of all the other units in the same way, while possibly reinforcing its own activation through positive self-feedback.
Let us implement lateral inhibition in `uc_layer`. We need to create a connection between `uc_layer` and itself and assign a negative value to its inhibitory parameter and 0 or a positive value to its excitatory parameter. The syntax for a self-loop connection is not special and follows the general rules of connections: 

	create connection uc_loop
	uc_loop autoconnect uc_layer uc_layer
where as it was for `lc_uc_connection` a sparse connection is established. In this case we don't need to worry about conversions since source and target representations coincide. Unit "A" is connected to itself with a link that multiplies its input by the value of the  `uc_loop::excitation` parameter, and is connected to "B" and "C" with a link parametrised by `uc_loop::inhibition`, and the same rules hold for every node. We can change the default values of those two parameters either by editing the  parameter file and reloading it or directly as follows:

	(mini_uc parameters) set uc_loop::inhibition -0.3


