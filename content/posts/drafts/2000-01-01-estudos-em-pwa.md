---
title: Rascunho Estudos em PWA
tags: ['pwa']
excerpt: 'Compilado dos meus achados sobre PWA revirando a internet'
draft: true
---

## PWA

**Super útil**: [PWA asset generator](https://github.com/onderceylan/pwa-asset-generator)

É possível disponibilizar o PWA em lojas de aplicativos.

[Progressive Web Apps in 100 Seconds](https://www.youtube.com/watch?v=sFsRylCQblw), Fireship

[7 Web Features You Didn’t Know Existed](https://www.youtube.com/watch?v=ppwagkhrZJs)

Testei instalar o PWA no meu celular (Samsung Galaxy S20 FE) por dois navegadores:

**Brave Browser**:

- O ícone do navegador aparece no ícone do app.
- A resolução do ícone estava um pouco a desejar, como se tivesse sido um pouco
  esticado
- na listagem de aplicativos abertos, o PWA aparece como uma instância do Brave
  Browser

**Google Chrome**: Experiência de uso se aproxima mais de uma experiência de
app nativo.

- o ícone do app não tem o ícone do navegador
- o app é listado na lista de aplicativos, sendo possível até desinstalá-lo
  como qualquer outro app.
- na listagem de aplicativos abertos, o PWA aparece como como um aplicativo
  nativo
- o ícone tem uma definição melhor, como se o tamanho apropriado tivesse sido
  escolhido

**Firefox**: Não vi ainda

iOS

O aplicativo não funcionou no iPhone de uma amiga, mas acho que não é por conta
da parte de PWA, por que eu nem tinha colocado coisa no projeto referente a isso.

## Workbox e `generateSW`

- [Workbox](https://developers.google.com/web/tools/workbox/guides/get-started)
- [generateSW](https://developers.google.com/web/tools/workbox/modules/workbox-cli)

Gerador de Service Worker de linha de comando. `generateSW` é limitado para os
casos:

- You want to precache files.
- You have simple runtime configuration needs (e.g. the configuration allows you to define routes and strategies).

Mas não sei qual é o escopo do meu futuro caso de uso (PWA pra controlar a fita
de LED), mas deve ser o suficiente.

## Snowpack + TypeScript + Workbox

Consegui fazer deploy de um PWA.

Com o Workbox, vi que a parte PWA "só funciona" em produção quando estão
sendo servidos os arquivos do diretório de build. O aplicativo é instalável
quando o app está hospedado no GitHub Pages ou na Vercel, mas não consegui
reproduzir isso em ambiente de desenvolvimento (localhost). O Snowpack reclama
de não encontrar o `sw.js`, o que faz sentido já que ele é gerado pelo Workbox
no diretório de build.

É possível visitá-lo [aqui](https://vercel.com/yudi-azvd/bedtime-calculator).
Hospedado na Vercel por enquanto.

Ainda não consegui montar um ambiente depuração com VSCode.

## Webpack + TypeScript + Workbox

Nem toquei ainda, mas o Webpack tem uma
[página](https://webpack.js.org/guides/progressive-web-application/) pra isso. Também usam Workbox.

Meu chute é que o ambiente de desenvolvimento com VSCode vai ser mais fácil.

## Parcel + TypeScript

Não consegui fazer o service worker funcionar sem nenhuma ferramenta adicional.
Aparentemente larguei cedo demais, por que acho que dava pra encaixar com WorkBox
também, segundo esse [post](https://www.bha.ee/how-to-make-your-parcel-js-app-progressive/). Nada muito diferente do Snowpack
e Webpack. Esse post usa React.

## Svelte

Aparentemente tem uma integração mais "seamless" com service workers.

```js
// service-worker.js
import { build, files, timestamp } from '$service-worker'
```

[Building a PWA with Svelte (Svelte, SvelteKit e Sapper)](https://blog.logrocket.com/building-a-pwa-with-svelte/),
LogRocket

[Create a PWA with Sveltekit](https://dev.to/100lvlmaster/create-a-pwa-with-sveltekit-svelte-a36)

## Referências

(Indicar o repositório inicial onde tem vários links)
