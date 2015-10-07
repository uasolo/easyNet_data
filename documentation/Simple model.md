#A simple model

We are going to build a very simple model that represents the mapping between lower case (LC) letters and corresponding upper case (UC) letters. The model will consist of two layers and one connection between the two. One layer holds a localist representation of (a subset of) all LC letters of the English alphabet, i.e. one node for each letter, the other layer holds the same type of representation for UC ones, and a connection from the former to the latter links every LC letter node to its corresponding UC letter node with an excitatory link. 
The LC letters layer will serve as input. This model expresses the idea that whenever a representation of a LC letter gets activated then the representation of its corresponding UC gets activated too, even though no UC letter was sent as input to the model.   

In order to build the above architecture with *lazyNut* we will not use only layers and connections, but also other types of objects, such as  representations and conversions, which make it possible to automate the model construction and to determine its behaviour at run time. 

After that, we will also design a trial. In general terms a trial defines a task that a model can carry out. In our case, the trial consists in the exposition to a LC input stimulus for a specified amount of time. Even though this does not sound like a task, e.g. the model does not take any decision based on the input value, it gives the possibility to see the result of the exposition to an input by appreciating how the model state changes in time.    

## The model script

The first line in every *lazyNut* script defining a model looks like this:

	create model mini_uc
where you specify the name of the model. Under the hood, this instruction created the object `(mini_uc parameters)`, which is a dataframe object that will store all the model parameters (see [bracketed notation](bracketed_notation) for an explanation on how brackets are used in *lazyNut*). 

In order to set up the two layers and the connection the way we want, we need to tell *lazyNut* what each layer represents and how the connection is wired. These two goals are achieved by using representation and conversion objects, respectively. A representation specifies a data format. In this example we will use two types of representation, namely a `string_representation`, which represents a string of characters of unspecified length, and a `keyed_representation`, which represents a set of named units, such as the letters "a", "b" and "c". Every layer is associated to one and only one representation, that is to say a layer codifies knowledge of a specific type. A conversion specifies the rules to convert from a source representation to a target representation. For example, a conversion can specify that the named units  "a", "b" and "c" of a `keyed_representation` map to their corresponding strings in a `string_representation`. Note that a conversion from a source to a target representation does not imply its inverse to exist, nor does say anything about the inverse when it exists. Moreover, more than a conversion can be defined between the same source and target representation.

Although representations and conversions can be created explicitly, in the majority of cases we let  *lazyNut* create them for us by creating a dataframe. A dataframe is a table of values that can be imported from a text file. The table we use looks like this:

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

In order to make this table available to *lazyNut* in the form of a dataframe, first we create an empty dataframe object, then we load the text file containing the table into the object:

	create dataframe_for_reps lc2uc_df	
	lc2uc_df load Databases/lc2uc.eNd

By declaring the dataframe to be of type `dataframe_for_reps` we are triggering the automatic generation of a number of default representations and conversions, which is what we wanted. In fact four representations have been created, two for each column in `lc2uc_df`. Since each column contains strings, a  `string_representation` is created for each of them. Then, since each column contains non numeric values, a `keyed_representation` is also created. The difference between the two types of representation is that while all  `string_representation`s are equal and for example the string "word" is a valid one for that representation, even though that string is not present in any of the dataframe columns, only the values "a", "b" and "c" are valid for the `keyed_representation` for the LC column. Moreover, while operations like string splitting or concatenation can be applied on a value of type `string_representation`, this is not possible for  `keyed_representation`. A `keyed_representation` is the obvious way to define and set up a localist representation in a layer, i.e. each key corresponds to a named unit or node in a layer. 
The four representations created from  `lc2uc_df` have names like this:

	(lc2uc_df column_rep lower_case keyed_representation)
that more or less reads "this is a `keyed_representation` created from the `lower_case` column of the  `lc2uc_df` table". 

Loading the table above into `lc2uc_df` triggered also the creation of six conversions, two pairs of conversions between the representations associated to each column of  `lc2uc_df` and a pair converting between the `keyed_representation`s of the two columns. For example, the conversion

	((lc2uc_df column_rep lower_case keyed_representation) conversion_key)
converts from the `string_representation` to the `keyed_representation` associated with the `lower_case` column, while the reverse conversion has a similar name ending with `conversion_unkey`. Conversion

	(lc2uc_df conversion lower_case upper_case)
converts from `(lc2uc_df column_rep lower_case keyed_representation)` to `(lc2uc_db column_rep upper_case keyed_representation)`. We will use these conversions for two purposes. One is to allow *lazyNut* to infer the connectivity between the LC letter and the UC letter layer from the conversion operating between the corresponding representations. The other is to let the user conveniently specify inputs using strings, which are converted to localist (keyed) representations by the appropriate conversion. 

Once representations and conversions are in place, creating layers and connecting them takes a few lines of code. Layers are created as follows:

	create iac_layer lc_layer
	lc_layer represent (lc2uc_df column_rep lower_case keyed_representation)

	create iac_layer uc_layer
	uc_layer represent (lc2uc_df column_rep upper_case keyed_representation)

We are using a specific type of layer, the `iac_layer` or Interactive Activation C?? layer, which contains activation units regulated by the  equations found in *Rumelhart & McClelland (1981)*. This type of layer has only one input port, called `net_input`, and its output is identical to the       internal state, i.e. the level of activation of each of the nodes. The code snippet above says that layers `lc_layer` and `uc_layer` represent the `keyed_representation` of LC and UC letters, respectively, which in turn means that those layers contain  units named after the  keys of their internal `keyed_representation`, so units  "a", "b" and "c" for `lc_layer` and units "A" "B" and "C" for `uc_layer`. At this point those units are not connected to each other, neither within a layer nor between layers. A connection wiring from `lc_layer` to `uc_layer` is instantiated as follows:

	create connection lc_uc_connection
	lc_uc_connection autoconnect lc_layer uc_layer

where the 'magic' command `autoconnect` will try and find a conversion between the internal representations of the two layers in the desired direction and use that rule to determine which nodes in the source layer are linked to which nodes in the target layer  with an excitatory link. That conversion is `(lc2uc_df conversion lower_case upper_case)`, which in practice reads the table above from left to right. 

More in general, when we create a connection between two layers representing a  `keyed_representation` a so-called `sparse_connection` is  created. This type of connection links all nodes of the source layer to all nodes of the target layer with a link that can be either excitatory or inhibitory. When a conversion rule is applied to define the connection wiring what actually happens is that the links specified by the rule, e.g. from "a" to "A", are defined as excitatory, and all others, e.g. from "a" to "B", as inhibitory. Note that the terms "excitatory" and "inhibitory" only suggest their typical use but it is up to the user to specify a  strength value for them. In our case we will choose a positive value (e.g. 0.07) for excitatory links and zero for inhibitory links, which means that we will not introduce inhibitory actions in the model. 
These and other model parameters will be specified below.

Parameters are loaded in from table-like text files in the same way as other tables:

	(mini_uc parameters) load Databases/Parameter_Sets/MINI/mini_uc.eNp
In the file we note, among others, the excitatory and inhibitory strength parameters for `lc_uc_connection` and the parameters  `min_act` and `max_act` that determine minimum and maximum activation values for all nodes in all layers. 

Before importing the trial script, we define the model input, or better a possible input, since we can have more than one. We want the input to be `lc_layer` and we want to use strings to express values. This is achieved by the following command:
 
	mini_uc define_input lc_input (lc2uc_df column_rep lower_case string_representation) lc_layer
where we define the label `lc_input` as the model input acting on   `lc_layer`   and using the specified representation. More precisely, any time we will send the input string "a" for a certain amount of time, this will translate (by virtue of the conversion `((lc2uc_df column_rep lower_case keyed_representation) conversion_key)`) into the activation of the "a" unit of  `lc_layer`. Activating a unit in this way means that its activation value is set to `max_act` for the time of exposition to the stimulus and then back to resting value, which is zero by default.





## The trial script