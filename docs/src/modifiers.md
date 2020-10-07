# Modifiers

Durante o fluxo de dados, o desenvolvedor poderá manipular e processar os dados sob demanda. Neste interim, surge a ideia dos modificadores (__Modifiers__). O desenvolvedor poderá adicionar modificadores e eles irão manipular os dados após a função __listen__. Alguns exemplos de possibilidade:

- Geração de ruído
- Processamento de dados
- Filtragem de dados

## FilterModifier

O __FilterModifier__ é um __Modifier__ com objetivo em filtrar colunas desnecessárias do _stream_. Exemplo de utilização:

```julia
EasyStream.reset!(stream_filter) # função para reiniciar o stream
modifier_filter = EasyStream.FilterModifier(:y);
push!(stream_filter, modifier_filter);

EasyStream.listen(stream_filter)
```

## AlterDataModifier

O __AlterDataModifier__ é um __Modifier__ com objetivo em processar e alterar informações do _stream_. Ele recebe por parâmetro uma função que poderá manipular os dados, recebendo o dado e o evento do stream. Exemplo de utilização:

```julia
EasyStream.reset!(stream_filter) # função para reiniciar o stream
modifier_alter_1 = EasyStream.AlterDataModifier((data,event)-> data[:x] .= 5)
push!(stream_filter, modifier_alter_1);

EasyStream.listen(stream_filter)
```

O dado irá receber um _DataFrame_ e o evento será uma estrutura onde possuirá os argumentos de construção do __AbstractStream__ e do __AbstractConnector__. Desta forma, é possível alterar até a geração dos dados!
