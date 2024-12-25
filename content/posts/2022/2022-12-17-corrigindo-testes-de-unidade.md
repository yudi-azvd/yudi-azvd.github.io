---
date: '2022-12-17'
title: Corrigindo testes de unidade
tags: ['testes']
excerpt: |
  Um aspecto importante para escrever um bom teste de
  unidade é ter em mente qual é a unidade sob teste
description: |
  Ao implementar essa calculadora, eu me propus a fazer testes unitários para
  aprender boas práticas de programação e ter mais segurança do funcionamento
  correto das funções desenvolvidas. Mal sabia eu que apenas escrever asserções
  sobre as expectativas de resultados corretos não era o suficiente para escrever
  bons testes de unidade. Um aspecto importante para escrever um bom teste de
  unidade é ter em mente qual é a unidade sob teste. Dessa parte eu sabia, mas
  não estava convicto, o que acabou resultando depois em dor de cabeça
  desnecessária.
---

## Introdução

De tempos em tempos, eu volto nesse [projeto](https://github.com/yudi-azvd/c-calculator)
para ler código, implementar novas funcionalidades ou corrigir bugs. É uma calculadora
de terminal em C que avalia expressões matemáticas bem simples.

Ao implementar essa calculadora, eu me propus a fazer testes unitários para aprender
boas práticas de programação e ter mais segurança do funcionamento correto das
funções desenvolvidas. Mal sabia eu que apenas escrever asserções sobre as expectativas
de resultados corretos não era o suficiente para escrever bons testes de unidade.
Um aspecto importante para escrever um bom teste de unidade é ter em mente qual
é a unidade sob teste. Dessa parte eu sabia, mas não estava convicto, o que acabou
resultando depois em dor de cabeça desnecessária.

## Funcionamento básico da calculadora

Ela funciona em um ciclo executando algumas etapas mais ou menos assim:

1. Ler a entrada do usuário
1. Validar e sanitizar
1. Tokenizar
1. Avaliar
1. Mostrar o resultado para o usuário e repetir.

O foco deste post é nas etapas 3 e 4.

**Tokenizar**, nesse contexto, é separar as partes siginificativas de uma expressão
matemática em tokens como números, operadores e parênteses de abertura e de
fechamento. Essa etapa é executada pela função `tokenize`.

**Avaliar** é a etapa de simplificar uma expressão matemática em seu resultado.
Por exemplo, `3 + 3 * 2` tem `9` como resultado. A função responsável por essa
etapa é `evaluate`.


## O teste de "unidade"

Nesse projeto foi usado [Catch](https://github.com/catchorg/Catch2) para
escrever os testes de unidade. Dentre eles, existe o arquivo `evaluate.test.cpp`,
que contém o seguinte caso de teste:

```cpp
TEST_CASE("evaluate 0", "[evaluate]") {
  char* data;
  char* result;
  t_list* list;

  char expression[] = "3*(8+4)/2";

  list = tokenize(expression);

  evaluate(list, &result);
  REQUIRE(string(result) == "18.000000");
  // Tem mais código que que libera memória,
  // mas será omitido daqui pra frente.
}
```
<!-- // FIXME: Explicar em algum lugar o que esse caso de teste tá testando -->

Baseado no nome do arquivo e no conteúdo do caso de teste, qual é a unidade sob
teste?

Se sua repostas foi `evaluate`, você acertou. Na época que eu escrevi esse teste
pela primeira vez, minha intenção era que ele fosse um teste de unidade.

Se você é experiente com testes, você percebeu que esse teste, na realidade, não
é um teste de unidade porque ele também depende do funcionamento correto da
função `tokenize`. Um caso de teste que ilustra isso é o `"3*3-6/2"`, que
resulta na [falha do teste](https://github.com/yudi-azvd/c-calculator/issues/2).
<!-- ^ Aqui eu devia ter dito qual o resultado errado que a função retornava.
Esse link pra issue é realmente necessário? -->

Fiquei um tempo considerável procurando a origem do erro na função `evaluate`.
Talvez não seja surpresa para você que está lendo agora, mas
[descobri depois](https://github.com/yudi-azvd/c-calculator/issues/2#issuecomment-1039256295)
que o erro estava na verdade na função `tokenize`.

## Correção do teste

O ideal é que o sucesso do caso de teste dependa apenas da função sob teste,
nesse contexto, `evaluate`. Vamos lembrar que essa função precisa de uma lista
em que cada elemento seja um token para avaliar o resultado da expressão que ela
representa.

Para corrigir o teste, precisamos de alguma rotina auxiliar, mais simples que
`tokenize`, que transforme uma expressão do tipo `"3*3-6/2"` em uma lista de
tokens. E precisamos fazer isso sem usar a função `tokenize` porque ela faz parte
da lógica principal da calculadora e deve ser testada em outro lugar.

A forma que eu escolhi para fazer isso foi assim:

```cpp
t_list* create_char_list_from(char* str) {
  t_list* l = create_list("char*");

  char* delimeters = " \t\n";
  char* last_token_found = strtok(str, delimeters);
  // strtok modifica o seu primeiro parâmetro, use com cuidado!
  while (last_token_found != NULL) {
    char* s = calloc(1, strlen(last_token_found)+1);
    strcpy(s, last_token_found);
    insert_tail(l, s);
    last_token_found = strtok(NULL, delimeters);
  }

  return l;
}
```

(A criação dessa função foi uma adaptação desse
[exemplo](https://www.cplusplus.com/reference/cstring/strtok/))

`create_char_list_from` cria uma lista encadeada de strings a partir de uma string,
separando os elementos por espaço em branco.
Na terra do C, a gente tem que implementar algumas rotinas por conta própria mesmo.
Se você usa outra linguagem mais moderna, não se preocupe com essa parte.
Apenas considere que `create_char_list_from` funciona de forma semelhante ao
método `split` do
[Python](https://docs.python.org/3.3/library/stdtypes.html?highlight=split#str.split)
ou do
[Java](https://docs.oracle.com/javase/8/docs/api/java/lang/String.html#split-java.lang.String-).

Exemplo de string de entrada: `"3 * ( 8 + 4 ) / 2"`. Essa entrada deve causar o
retorno de uma lista encadeada com os elementos:

`3, *, (, 8, +, 4, ), /, 2`

Reescrevendo o caso de teste com a função `create_char_list_from` temos o seguinte:

```cpp
TEST_CASE("evaluate 0", "[evaluate]") {
  char* data;
  char* result;
  t_list* list;

  char expression[] = " 3 * ( 8 + 4 ) / 2";
  list = create_char_list_from(expression);

  evaluate(list, &result);
  REQUIRE(string(result) == "18.000000");
}
```

Antes, o sucesso do caso de teste dependia de duas etapas importantes e
relativamente complexas do ciclo da calculadora. Depois da correção, ele depende
de apenas uma etapa da calculadora (a unidade sob teste) e de uma função auxiliar
relativamente simples que _não_ faz parte da lógica principal da calculadora.

## Conclusão

Não deixe a preguiça atingir você, pense um pouco sobre como você está escrevendo
seus testes. Independemente se a unidade sob teste for uma classe, método ou
função, o seu sucesso deve depender apenas dessa unidade.

### Observações tangentes
- Escrevendo esse post eu percebi que havia um bug em `create_char_list_from`.
Por isso, vale reforçar que é importante testar as funções auxiliares que você
escreve.
- Não use o código do repositório para entender as funções. No momento em que você
acessar o link, o código provavelmente já mudou. O que está escrito neste post
deve ser o suficiente para entender o que estou tentado dizer.
- Não use os nomes dos testes como eu fiz. Eu era jovem e preguiçoso. Dê nomes
descritivos para os seus casos de teste. Assista esse
[trecho](https://youtu.be/MWsk1h8pv2Q?t=892) para ter uma ideia de como escolher
bons nomes.
- A função `evaluate` ainda não é totalmente isolável porque ela utiliza internamente
a função `to_postfix` que converte uma expressão na forma
[infixa](https://en.wikipedia.org/wiki/Infix_notation) para
[pós-fixa](https://en.wikipedia.org/wiki/Reverse_Polish_notation). Essa conversão
é um pré-requisito para avaliação de uma expressão e, por isso, talvez seja
interessante separar essas duas funções e testá-las isoladamente.
