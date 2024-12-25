---
title: 'Automação com Bash, parte 1'
date: '2021-11-20'
excerpt: 'Básico de watch, ps e grep'
tags: ['automação', 'bash', 'série-automação']
---

<!-- ## O que é automatizar um processo?

- É a primeira coisa que um programador pensa depois de fazer a mesma coisa
  mais de uma vez.

Ninguém quer ficar repetindo os mesmos comandos terminal ou na IDE.

## O que é automação?

- É o resultado do trabalho de alguém preguiçoso.

- É diminuir a presença de uma pessoa em determinado processo.

## Benefícios

- O mais óbvio é a economia de tempo porque você não precisa executar uma série
  de passos manualmente.

- Reduz a carga mental do programador. Ele precisa se preocupar com menos coisas,
  fazer menos coisas por que parte delas já estão sendo feitas por um script.

- ...

- _Bônus_: em alguns casos, dá uma noção melhor de como montar um pipeline de
  Entrega Contínua, o famoso CI, conceito fundamental na área de DevOps. -->

## Ideia geral desta série de posts

Nesta série de posts, vou apresentar alguns processos que eu automatizei durante
algumas disciplinas na universidade, a maioria deles em Bash (Bourne Again Shell).
Pode ser que a automação aconteça usando outras ferrametas como o Python
e outros em ambientes como uma IDE ou uma pipeline de CI.

A ideia é que você leia esses posts, aprenda uma ferramenta ou outra e se inspire
para automatizar os seus próprios processos na sua vida de programação.

Eu mesmo fui inspirado por uma aula da disciplina
[Missing Semester](https://missing.csail.mit.edu/) do MIT.
A aula de [data wrangling](https://missing.csail.mit.edu/2020/data-wrangling/)
foi onde eu formei a base do meu conhecimento (ainda fraca por falta de prática)
do programa `sed` e de [regex](https://en.wikipedia.org/wiki/Regular_expression)
(regular expressions ou expressões regulares),
que vão ser bastante usados nesta série. Se você estuda Ciências da Computação ou
Engenharia de Software, vale à pena você dar uma olhada nessa disciplina.

## Tópicos deste post

Neste post vamos aprender alguns conceitos e comandos:

- `watch`
- operador pipe
- `ps`
- `grep`

## O que você precisa
- Computador com ambiente Unix (Máquina virtual, dual boot com alguma distro Linux)
  - Se você está em Windows, você pode usar o [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install).
- Terminal
- gcc (não é obrigatório)

## Um pouco de prática: relógio ao vivo de terminal

Vamos começar com uma situação muito simples: **mostrar as horas no terminal a cada
intervalo de tempo, como um relógio ao vivo**. Em Linux, um comando que mostra as
horas é o `date`. Se você usá-lo no terminal, você deve ver algo assim:

    sex nov 26 18:40:39 -03 2021

Como queremos apenas as horas, podemos passar a opção `+"%R:%s"`. O resultado de
executar `date +"%R:%s"` é:

    18:40:55

Mas esse comando mostra as horas apenas uma vez. Teríamos que executar o comando
`date` pelo menos uma vez por segundo para termos um relógio decente. Queremos algo
mais automático. Para isso vamos usar o comando `watch`. `watch` executa um comando
periodicamente mostrando o resultado dele em tela cheia. Esse comando é muito
útil quando queremos observar alguma coisa que muda com o tempo sem ter que ficar
digitando um comando no terminal toda ver que queremos ver um resultado.

Você pode aprender mais sobre comandos no `manpages` do Linux. Se você rodar
`man watch` você verá algo assim no terminal:

```
WATCH(1)                        User Commands                       WATCH(1)

NAME
       watch - execute a program periodically, showing output fullscreen

SYNOPSIS
       watch [options] command

DESCRIPTION
       watch  runs command repeatedly, displaying its output and errors (the
       first screenfull).  This allows  you  to  watch  the  program  output
       change  over  time.   By  default, command is run every 2 seconds and
       watch will run until interrupted.
```

No terminal, você pode rolar a página para baixo com as setas do teclado ou com
a barra de rolagem do mouse. Toda vez que você tiver dúvida sobre o funcionamento
de algum comando ou suas flags e opções, ~pesquise primeiro no Stackoverflow~
consulte as páginas do manual para esse comando.

Executando `watch date +%R` no terminal deve resultar nas horas sendo impressas
a cada 2 segundos, com um cabeçalho com parâmetros adicionais sobre o comando. Não
é bem o que a gente quer, mas estamos quase lá. Você pode interromper a execução
de `watch` com <kbd>Ctrl</kbd> + <kbd>C</kbd>.

Olhando no manual de `watch`,
percebemos que existe uma flag `-n` para especificar o intervalo de tempo em
segundos. O intervalo padrão, como pode-se perceber é de 2 segundos. Se queremos
um relógio ao vivo, podemos diminuir o intervalo para 1 segundo ou um intervalo
menor que isso.

    watch -n 0.5 date +%R

Note que a flag `-n` é para o comando `watch` e não para o comando `date`.

**Exercício para o leitor:** consultando as páginas do manual, descubra como fazer
o comando `watch` não mostrar o cabeçalho com informações adicionais, ou seja,
que mostre apenas o resultado do comando `date`. _Dica:_ procure por título ou
title.

## Um pouco mais complicado: árvore de processos

Vamos usar esses conhecimentos em um cenário um pouco mais complicado:
**observar a árvore de processos de um programa**.

Para isso, vamos executar um programa feito em C que simplesmente cria vários
processos filhos e morre depois de alguns segundos:

```c
// procs.c
#include <stdio.h>
#include <sys/types.h> // pid_t
#include <unistd.h> // fork, sleep

int main() {
  int i;
  pid_t pid;

  for (i = 0; i < 3; i++) {
    sleep(1);
    pid = fork();

    if (pid > 0) {
      sleep(2);
      fork();
    }
  }

  return 0;
}
```

Compile com `gcc procs.c` e execute com `./a.out`.

Você pode escolher outro programa para observar. Navegadores web (Chrome, Brave
Browser, Edge) são ótimos exemplos.

Vamos usar novos comandos para isso:

- `ps`: mostra um snapshot dos processos atuais.
- `grep`: imprime as linhas que contém determinada string.

Consulte os manuais desses comando para saber mais (eu só traduzi essas definições
de lá). Tome um tempo pra explorar o comando `ps` com diferentes flags e opções.
Leia a seção `EXAMPLES` do manual do `ps`. Depois disso, tente filtrar o resultado
do comando `ps` com o `grep` para obter os processos de determinado programa.

Se você conseguiu fazer tudo isso, fica fácil mostrar a árvore de processos de um
programa a sua escolha. Caso contrário, continue lendo.

Para usar esses comandos, vamos usar o
[operador pipe](<https://en.wikipedia.org/wiki/Pipeline_(Unix)>) em shell. O pipe
redireciona a saída padrão de um comando (ou programa) para a entrada padrão de
outro comando (ou programa). A partir de agora, use duas janelas de terminal: uma
para executar os comandos de shell e a outra para executar o programa em C.

Na primeira janela, execute o programa em C com

    ./a.out

Logo em seguida, na segunda janela de terminal, execute o seguinte:

```sh
ps axjf | grep "a.out"
```

(Ao invés de observar o programa `a.out`, você pode observar algum navegador.
Basta substituir `a.out` por `google-chrome` ou `brave-browser`).

Se você executou os comandos anteriores suficientemente rápido, você deve ver
uma árvore de processos em certo instante da execução do programa `a.out`. Se
você não conseguiu ser rápido o suficiente, você pode aumentar o tempo nas
chamadas de função `sleep` ou, melhor ainda, usar o comando `watch`.

```sh
watch -n 0.1 "ps axjf | grep 'a.out'"
```

> Note os diferentes usos de aspas simples e aspas duplas nos comandos daqui
> pra frente.

As opções pra `ps` vão listar todos os processos do computador e mostrar a relação
entre alguns deles através de uma árvore. Usando o resultado do `ps`, `grep`
imprime todas as linhas com a string `a.out` presente.

**Exercício para o leitor:** você pode notar que mesmo depois que o programa
`a.out` termina sua execução, o
comando `watch` continua mostrando alguns resultados de processos como `watch` e
o próprio `grep`. Pesquise na internet ou nas páginas do manual como podemos
mandar o `grep` _não_ imprimir linhas com certas strings, de maneira que apareça
apenas a linhas dos processos filhos do `a.out`.

Para atingir o objetivo do parágrafo anterior, podemos usar a flag `-v` do `grep`:

```sh
watch -n 0.1 "ps axjf | grep 'a.out' | grep -v 'watch'"
```

Se você executar assim, ainda sobra um processo que não pertence à arvore de
processos de `a.out`. Podemos removê-la com outro filtro para `grep`

```sh
watch -n 0.1 "ps axjf | grep 'a.out' | grep -v 'watch' | grep -v 'grep'"
```

Mas podemos remover essa última parte de outra maneira:

```sh
watch -n 0.1 "ps axjf | grep 'a.out' | grep -v -E 'watch|grep'"
```

Sem entrar em muitos detalhes, a flag `-E` habilita regex para o `grep`. No
contexto de regex, o operador `|` funciona como um operador lógico OU. Então,
pode-se ler `grep -v -E 'watch|grep'` como "não imprima as linhas que contêm
watch OU grep".

E finalmente, o que resta na tela é a árvore de processos do programa `a.out`.
