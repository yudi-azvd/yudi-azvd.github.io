---
date: '2021-12-19'
title: Como ler do sistema de arquivos de um jeito organizado em C
tags: ['c', 'sistema-de-arquivos']
excerpt: Usando getcwd, strcat e strstr
---

## Pré-requisitos

- Ambiente Linux com GCC
- Conhecimento de ponteiros e strings em C

Aprendizados:

- `getcwd`
- `strcat`
- `strstr`

## Poblema

Para a disciplina de Estrutura de Dados 2 (EDA2), eu tenho um
[repositório](https://github.com/yudi-azvd/eda2/) com uma estrutura relativamente
complexa para um "projeto" em C. Esse repositório vive no meu computador na
pasta `/home/yudi/<vários diretórios>/eda2/`, mais ou menos com o seguinte conteúdo:

```
.
├── ... outros arquivos como .gitignore, README.md, etc
├── 00-revisao/
├── 01-sorting/
├── 02-hash/
├── 04-trees/
├── 05-heap/
├── 06-graph
│   ├── _exercises/
│   └── list-und-graph
│       ├── listundgraph.h
│       └── _tests
│           ├── listundgraph.test.cpp
│           └── ...
└── resources
    └── algs4-data
        ├── tinyG.txt
        ├── tinyCG.txt
        └── ... outros vários arquivos com amostras de dados
```

Em um dos exercícios do livro, eu tinha que criar um
"[construtor](https://pt.wikipedia.org/wiki/Construtor)" que recebe o caminho
de um arquivo para criar e preencher o grafo, com uma assinatura assim:

```c
ListUndGraph *ListUndGraph_create_from_file(const char *filepath)
```

Que é chamada nos arquivos em `06-graph/list-und-graph/_tests/` ou
em `06-graph/_exercises/`.

## Primeiras soluções

A primeira solução que pensei foi a de passar o caminho relativo para o construtor,
algo como `"../../../../resources/algs4-data/tinyG.txt"`. A quantidade de `../`
varia de acordo com o lugar de onde `ListUndGraph_create_from_file` é chamado.
Essa é uma solução viável, mas um tanto incoveniente. O código cliente fica feio
com muitos `../` e é chato para o programador ficar "calculando" essa quantidade.

Outra solução seria passar o caminho absoluto para o construtor. No meu computador,
por exemplo, esse caminho poderia ser
`"/home/yudi/uni/eda2/resources/algs4-data/tinyG.txt"`. Essa solução, entretanto,
traz mais restrições:

- Se por acaso eu precisar mudar o repositório de lugar no meu computador, esse
  caminho absoluto já não valeria mais
- Se outra pessoa baixar esse repositório no computador dela, esse caminho absoluto
  faria menos sentido ainda. Ela teria que ter um username igual a `yudi` e
  baixar o repositório em `~/uni/`
- Essa solução polui o projeto com informações do sistema de arquivos que estão
  fora do repositório e não importam pra ele.

## Uma solução melhor

_Ao meu ver pelo menos._

Para o cliente, seria interessante se a chamada do construtor fosse algo assim:

```c
ListUndGraph *g = ListUndGraph_create_from_file("algs4-data/tinyG.txt");
```

Dessa maneira, o construtor recebe apenas o _caminho relativo_ para o arquivo a
partir de `resources/` e ele se encarrega de resolver o _caminho absoluto_ até a
pasta `resources/` ou de chamar alguém que sabe fazê-lo.

Vamos optar por criar a função `void get_res_dir(char *res_dir)` que preenche
`res_dir` com o caminho absoluto até `resources/` e é usada pelo construtor. Como
bônus, ela ainda pode ser usada por outras funções de qualquer lugar do repositório
e sua lógica pode ser reaproveitada em outros projetos.

Como vamos colocar `get_res_dir` em seu próprio arquivo de cabeçalho (`.h`), ele
precisa ser incluído por quem quer usá-lo. Infelizmente, o problema da quantidade
`../` volta aqui na hora de usar `#include "../../../get_res_dir.h"`. Isso pode
ser resolvido com um Makefile ou com um gerador de build system. Configurando
essas ferramentas apropriadamente, a compilação por debaixo dos panos aconteceria
mais ou menos assim:

```sh
# essa quantidade de "../" é apenas para ilustração.
gcc -I"../../../../get_res_dir.h" listundgraph.test.cpp -o listundgraph.test.out
```

Assim seria possível incluir a função apenas com

```c
#include "get_res_dir.h"
```

Eu teria que pesquisar mais pra configurar essas ferramentas apropriadamente, mas
durante o curso de EDA2 eu não achei necessário fazer o setup de Make ou CMake
para esses exercícios simples ~por preguiça ou falta de paciência pra aprender~.
Ainda assim, vale ressaltar que essa estratégia seria mais adequada em um projeto
C/C++ de verdade .

## Super pseudocódigo

```cpp
void get_res_dir(char* res_dir) {
  // pegar caminho absoluto do diretório onde o programa está sendo executado
  //    exemplo: "/home/yudi/uni/eda2/06-graph/list-und-graph/_tests/"
  // pegar a substring do caminho absoluto até "eda2"
  //   substr: "/home/yudi/uni/eda2/"
  // concatenar a substring com "resources/"
  //   resultado: "/home/yudi/uni/eda2/resources/"
  // (esse resultado deve estar em res_dir no final da função)
}
```

## Implementação de `get_res_dir`

Para pegar o caminho absoluto do diretório eu pesquisei extamente isso no Google.
Como estou programando em ambiente Linux, a função que foi recomendada foi
`char* getcwd(char* buf, size_t size)` (get current working directory) do cabeçalho
`unistd.h`. De acordo com as
[páginas do manual](https://man7.org/linux/man-pages/man3/getcwd.3.html), ela retorna
o diretório em `buf`, que deve apontar para um espaço previamente alocado.

Executando a essa função no meu computador no diretório
`/home/yudi/uni/eda2/06-graph/list-und-graph/_tests/`, ela retorna exatamente isso.
Por prevenção, vamos usar um buffer com o tamanho máximo.

```c
getcwd(res_dir, PATH_MAX);
```

Agora precisamos apenas de uma substring disso tudo: `"/home/yudi/uni/eda2"`. Como
diretório raíz do repositório, podemos usar a string `"eda2"` para extrair a
substring de interesse. É uma suposição razoável porque é o nome do repositório
e dificilmente vai mudar. Uma solução mais robusta, talvez, seria procurar o próximo
diretório pai com a pasta `.git`, mas não vamos por esse caminho nesse post.

Para extrair a substring, vamos usar a função

```c
char* strstr(const char *haystack, const char *needle)
```

Que encontra a primeira ocorrência de `needle` em `haystack` e retorna o ponteiro
que aponta para onde `needle` foi encontrado.

```c
const char *root_dir_name = "eda2";
char *root_dir_ptr = strstr(res_dir, root_dir_name);
```

Agora `root_dir_ptr` aponta para a string `"eda2/06-graph/list-und-graph/_tests"`.
Vale ressaltar que não há cópias de strings, `root_dir_ptr` apenas aponta para
uma região de memória alguns bytes à frente da região de memória apontada por
`res_dir`, conforme a ilustração abaixo:

```
/home/yudi/uni/eda2/06-graph/list-und-graph/_tests/
↑              ↑
res_dir        root_dir_ptr
```

Como não precisamos de nada que vem depois de `"eda2/"`, podemos desconsiderar
essa parte colocando o terminador de string `'\0'`.

```c
*(root_dir_ptr + strlen(root_dir_name)) = '\0';
```

Agora `res_dir` aponta para

```
                   Note o '\0', antes era um '/'
                   ↓
/home/yudi/uni/eda2\006-graph/list-und-graph/_tests/
↑              ↑
res_dir        root_dir_ptr

```

Que é o mesmo que:

```

/home/yudi/uni/eda2
↑              ↑
res_dir        root_dir_ptr
```

Agora só precisamos concatenar `"/resources"` ao final de `res_dir`:

```c
const char *res = "/resources";
strcat(res_dir, res);
```

Juntando tudo, a função `get_res_dir` fica assim:

```c
#include <unistd.h>       // getcwd
#include <linux/limits.h> // PATH_MAX
#include <string.h>       // strstr, strcat, strlen

// Preenche RES_DIR com "/.../eda2/resources".
// "..." é o caminho absoluto até "eda2/".
//
// RES_DIR deve ser um buffer com PATH_MAX bytes.
void get_res_dir(char *res_dir)
{
  getcwd(res_dir, PATH_MAX);
  const char *root_dir_name = "eda2";
  char *root_dir_ptr = strstr(res_dir, root_dir_name);
  *(root_dir_ptr + strlen(root_dir_name)) = '\0';
  const char *res = "/resources";
  strcat(res_dir, res);
}
```

## Implementação de `ListUndGraph_create_from_file`

Agora só falta implementar o construtor de grafos. Vamos alocar um espaço para
o caminho absoluto.

```cpp
char full_filepath[PATH_MAX]; // com lixo de memória por enquanto
```

Executando a função `get_res_dir` com `full_filepath` obtemos o seguinte:

```cpp
get_res_dir(full_filepath);
// full_filepath: "/home/yudi/uni/eda2/resources"
```

Para terminar, precisamos acrescentar uma `"/"` e o caminho relativo do arquivo
que foi passado a `ListUndGraph_create_from_file`. Vamos supor que esse caminho
relativo é `"algs4-data/tinyG.txt"`.

```c
// full_filepath: "/home/yudi/uni/eda2/resources"
strcat(full_filepath, "/");
// full_filepath: "/home/yudi/uni/eda2/resources/"
strcat(full_filepath, filepath);
// full_filepath: "/home/yudi/uni/eda2/resources/algs4-data/tinyG.txt"
```

O código do construtor fica assim:

```c
ListUndGraph *ListUndGraph_create_from_file(const char *filepath)
{
  char full_filepath[PATH_MAX];
  get_res_dir(full_filepath);
  strcat(full_filepath, "/");
  strcat(full_filepath, filepath);

  // restante do código para preencher o grafo
}
```

## Possíveis melhorias

Ainda seria possível deixar `ListUndGraph_create_from_file` mais interessante,
criando uma função que faz o equivalente às últimas três linhas do trecho
anterior.

Outra melhoria seria deixar esse código um pouco mais cross-platform, ou seja,
que funcione melhor independentemente do sistema operacional. O cabeçalho
`unistd.h` não existe em Windows, o que geraria um erro de compilação. Uma
maneira de resolver isso seria com macros condicionais e usando a função
`GetCurrentDirectory` do cabeçalho `winbase.h`.

Essas possíveis melhorias ficam como exercícios para leitor.
