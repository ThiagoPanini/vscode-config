# Fontes e alternativas

A fonte não é instalada por uma extensão de tema ou de ícones. `editor.fontFamily` apenas escolhe uma família que o sistema já oferece. Escrever o nome de uma fonte no JSON não a instala.

## Caminho que funciona sem instalar uma fonte nova

O preset visual usa:

```jsonc
{
  "editor.fontFamily": "'Cascadia Code NF', Consolas, monospace",
  "editor.fontLigatures": true,
  "editor.fontSize": 14,
  "editor.lineHeight": 22,
  "editor.fontWeight": "400",
  "editor.letterSpacing": 0
}
```

O sistema tenta as famílias na ordem informada. No Windows, se Cascadia Code NF estiver ausente e Consolas estiver disponível, o editor usa Consolas. Isso permite reproduzir as cores e o layout sem buscar arquivos em outro repositório.

Consolas não tem as ligaduras de programação da Cascadia Code. Manter `editor.fontLigatures: true` não cria esse recurso em uma fonte que não o possui. Para fixar a alternativa explicitamente, use [settings/fontes-alternativas.jsonc](../settings/fontes-alternativas.jsonc), que também desativa as ligaduras.

Em outro sistema operacional, selecione uma fonte monoespaçada já instalada ou mantenha o fallback `monospace`. O roteiro visual não depende de instalar uma família específica.

## Reproduzir Cascadia Code NF

1. Confira se a família **Cascadia Code NF** já está instalada no sistema ou disponível pelo catálogo de software da empresa.
2. Se estiver disponível, o preset já a seleciona. O nome da família deve corresponder ao instalado.
3. Se a empresa permitir a instalação de fontes, obtenha o pacote por uma fonte aprovada, como o catálogo interno ou a [distribuição oficial de Cascadia Code](https://github.com/microsoft/cascadia-code/releases).
4. No Windows, extraia o pacote e instale a família usando o instalador de fontes do sistema. A possibilidade de instalar por usuário depende das permissões locais.
5. Salve o trabalho e recarregue o VS Code se a nova família ainda não aparecer. Em alguns casos é necessário reabrir o aplicativo quando for conveniente.
6. Compare `0 O`, `1 l I`, `!=`, `==`, `<=`, `>=` e `->`. Ajuste o tamanho de fonte à sua tela.

Se o acesso a essa distribuição ou a instalação de fontes estiver bloqueado, continue com a fonte disponível. O repositório não exige que você baixe Cascadia de outro GitHub.

## Variantes de Cascadia

- **Cascadia Code** possui ligaduras de programação.
- **Cascadia Mono** é a variante sem essas ligaduras.
- **NF** indica uma variante com glifos Nerd Font.

Os ícones de arquivos do Symbols são SVGs e não dependem de uma Nerd Font. A variante NF é útil para glifos adicionais no terminal, se seu prompt usar esses símbolos. [Variantes na documentação oficial](https://github.com/microsoft/cascadia-code#font-variants).

## Terminal integrado

O roteiro principal preserva a fonte do terminal. Se você quiser a mesma fonte do ambiente de referência, mescle [settings/terminal.jsonc](../settings/terminal.jsonc). Se o terminal já usa outra fonte aprovada com glifos necessários ao prompt, mantenha-a.

## Alternativas de gosto pessoal

Geist Mono e JetBrains Mono combinam com Vesper, mas não são dependências deste setup. Se quiser experimentá-las em um ambiente que permita sua instalação, use as fontes oficiais:

- [Geist Mono](https://vercel.com/font): ligaduras de programação nas versões atuais usam `"editor.fontLigatures": "'ss11'"`, conforme [confirmação do projeto](https://github.com/vercel/geist-font/issues/201#issuecomment-3842910111).
- [JetBrains Mono](https://www.jetbrains.com/lp/mono/): use `"editor.fontLigatures": true`.

Comece com a fonte disponível no trabalho. Isso mantém a escolha de fonte separada da instalação do tema e dos ícones.
