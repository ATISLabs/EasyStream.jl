# Getting Started
## Installation

EasyStream can be installed using the Julia package manager.
From the Julia REPL, type `]` to enter the Pkg REPL mode and run.

```
pkg> add https://github.com/Conradox/EasyStream.jl
```

## Generating your first graph

Everything starts with the `EasyStream.evaluate` function where you need to pass as parameters three essential elements
to the analysis to get started.
```
EasyStream.evaluate(models, stream, measures = measures)
```

**`streams`** parameter needs to receive a `Stream` that is a struct of
`EasyStream`. The `Stream` stores the data for training and testing the models and some other meta data about the stream. It also supports a vector of `Stream`.

**`models`** receives one model or a vector of models to be
analyzed. Here you can use custom models, but you
will have to overload some structs and functions.

!!! note
    The EasyStream has support to MLJModels i.e there are a wide quantity of ready models to be used.
    As in MLJ library, you only need to add the model package to the project using `]add` and use the macro `@load`
    to call the model.

    #### Example
    ```
    pkg> add NearestNeighbors
    julia> using EasyStream
    julia> @load KNNClassifier

    models = KNNClassifier()
    streams = Data()
    measures = [:time, :allocation, :accuracy]
    EasyStream.evaluate(models, stream, measures = measures)

    ```

**`measures`** receives all of desired measures that
you will be used in graphs and tables.  

After to use the `EasyStream.evaluate`, you are ready to use the function to create
the elements to your analysis.

```
  EasyStream.generate(output)
```
The output is built by an array where its first element
is the type of the output, such as :table and :bars. The
following elements are the measures like `:time`, `:allocation` and
`:accuracy`. Some examples of outputs are `[:bars, :tine]`,
`[:table, :time, :accuracy]` and `[:bars, :accuracy]`.

## Examples

```julia
EasyStream.evaluate(
streams[1:3], #Streams
[KNNClassifier(), DecisionTreeClassifier()],
measures = [:time, :accuracy]); #Models
```

Nesse caso a formatação padrão é `(:measure, :stream, :model)`, então cada gráfico representa a avaliação de um modelo em determindos streams definidos no parametro `streams` e usando as métricas passadas através da estruturas do `output`.


```julia
result = EasyStream.generate([:bars, :time]);
```


```julia
result[1][1]
```

![Graph1](../imgs/guide/output_1.png)

```julia
result = EasyStream.generate([:bars, :accuracy]);
```

```julia
result[1][1]
```

![Graph1](../imgs/guide/output_2.png)
