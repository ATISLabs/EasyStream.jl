# Stream

The `Stream` is a struct used to represent a data stream aware of its behavior.
Then, grouping all of these information in a struct the process of training and
classification is easily ran.


### Struct

    function Stream(
        window_size, 
        n_avaiable_labels,
        samples::Array{<:Number},
        labels;
        name = nothing
        )
