# Aplicar JSONC preservando suas configurações

Os arquivos em `settings/` são objetos de configuração para mesclar no `settings.json` do usuário ou perfil. Eles não são instaladores e não têm efeito só por estarem nesta pasta.

JSONC é JSON com comentários. O editor de configurações do VS Code aceita esse formato. Neste repositório, os comentários explicam o uso dos arquivos; os valores são os mesmos do preset validado.

## Abrir o arquivo correto

Pressione `Ctrl+Shift+P` e procure por **Open User Settings (JSON)** / **Configurações do Usuário (JSON)**. Se você criou um perfil Vesper Trabalho, confirme que ele está ativo. Evite usar **Workspace Settings (JSON)** para uma preferência pessoal que deve valer para vários projetos.

## Quando o arquivo está vazio

Se o conteúdo é somente `{}`, você pode substituí-lo pelo objeto completo de `settings/vesper.jsonc`.

## Quando o arquivo já contém preferências

Um arquivo de configurações tem um único objeto externo:

```jsonc
{
  "editor.formatOnSave": true,
  "workbench.colorTheme": "Vesper",
  "workbench.iconTheme": "symbols"
}
```

Esse é apenas um exemplo de estrutura. O preset completo está em [vesper.jsonc](../settings/vesper.jsonc).

1. Preserve as propriedades que não fazem parte do preset.
2. Para uma chave simples que já existe, altere seu valor. Por exemplo, atualize `workbench.colorTheme` de Dracula para Vesper em vez de manter duas ocorrências da mesma chave.
3. Para uma chave nova, acrescente a propriedade dentro das chaves externas, com vírgula separando-a das demais.
4. Para um objeto existente, mescle as propriedades internas.
5. Salve e confira os erros de sintaxe indicados pelo editor.

Não cole um segundo `{ ... }` ao final do arquivo e não duplique chaves como `[python]` ou `workbench.colorCustomizations`.

## Mesclar Python

Se seu arquivo já contém:

```jsonc
{
  "[python]": {
    "editor.formatOnType": true
  }
}
```

O resultado do acréscimo da opção de semântica deve manter essa preferência:

```jsonc
{
  "[python]": {
    "editor.formatOnType": true,
    "editor.semanticHighlighting.enabled": true
  }
}
```

Acrescente também o objeto `editor.semanticTokenColorCustomizations` do [arquivo de Python](../settings/python.jsonc). Preserve suas outras opções de análise, lint, formatação, testes e imports. O preset não escolhe um formatador.

## Mesclar as cores

O visual usa estes objetos:

- `workbench.colorCustomizations`: cores da interface e do editor, dentro de `[Vesper]`.
- `editor.tokenColorCustomizations`: comentários e regras TextMate, dentro de `[Vesper]`.
- `editor.semanticTokenColorCustomizations`: regras de tokens semânticos, no módulo opcional de Python.

Se já existir um desses objetos, acrescente ou atualize o grupo `[Vesper]` dentro dele. Preserve grupos de outros temas e propriedades que queira manter. Se o grupo `[Vesper]` já tiver customizações suas, compare os conflitos: para reproduzir este preset, os valores fornecidos aqui devem prevalecer nas mesmas chaves.

`textMateRules` é uma lista. Se você já tiver regras próprias que deseja manter, una as listas e revise regras que disputem os mesmos escopos. Objetos e listas não devem ser tratados da mesma forma ao copiar manualmente. Veja [a precedência oficial de configurações](https://code.visualstudio.com/docs/configure/settings#_settings-precedence).

## Aplicar fontes e terminal

A fonte do editor já possui fallback para Consolas no Windows. Se aplicar [fontes-alternativas.jsonc](../settings/fontes-alternativas.jsonc), atualize `editor.fontFamily` e `editor.fontLigatures` no mesmo objeto; não crie cópias dessas chaves.

O [módulo de terminal](../settings/terminal.jsonc) é separado para preservar a fonte de um terminal corporativo que já esteja funcionando. Ele não muda seu shell, perfil de terminal ou paleta ANSI.

## Confirmar que o arquivo está válido

- O arquivo tem um único objeto externo.
- As propriedades estão separadas por vírgulas.
- Não há duas chaves iguais no mesmo objeto.
- Suas configurações anteriores continuam presentes.
- O VS Code não mostra erro de sintaxe ou chave desconhecida.

Se aparecer uma chave desconhecida, confira a versão do VS Code e as extensões instaladas antes de copiar mais blocos. [Diagnóstico](restricoes-e-alternativas.md).
