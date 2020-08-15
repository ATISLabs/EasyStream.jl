# EasyStream

Esse pacote tem o intuito de facilitar o uso de stream.

Exemplo de utilização.
```
using EasyStream

stream = EasyStream.Dataset1CDT(10)

for data in stream
    @show data
end
```

Exemplo de colocar um modificador ao stream.
```
using EasyStream

stream = EasyStream.Dataset1CDT(10)

filter = EasyStream.FilterModifier([:Column, :Column2])

push!(stream, filter)

EasyStream.listen(stream)
```