# O que cada ajuste faz

O preset parte de Vesper e preserva sua identidade: fundo quase preto, menta em strings e pêssego nos destaques. A customização torna alguns elementos mais legíveis e a interface mais uniforme.

## Paleta e superfícies

| Parte | Configuração do preset | Motivo |
| --- | --- | --- |
| Editor, sidebar e barras | Fundo principal `#101010` | Superfícies integradas |
| Texto neutro e variáveis | `#D0D0D0` | Suavizar o branco puro |
| Comentários e seus delimitadores | `#858585` | Comentários legíveis sem adicionar outra cor de destaque |
| Busca | Pêssego translúcido com borda pêssego | Cor previsível para um highlight central |
| Seleção | Branco translúcido sobre o fundo escuro | Destaque neutro |
| Diffs | Menta para adições e vermelho para remoções, com alfa `0x22` | Melhorar a percepção das mudanças sem perder a função das cores |
| Status bar na depuração | Fundo `#241C17`, texto pêssego | Reduzir a presença do laranja forte do Vesper original |
| Bordas de separação selecionadas | Transparentes | Reduzir molduras, preservando o foco e a indicação da aba ativa |

`#101010` é quase preto, não preto puro. `#RRGGBBAA` representa uma cor com transparência; o sufixo `22` equivale a aproximadamente 13,3% de alfa. Isso não é uma razão de contraste nem uma certificação da legibilidade de toda a tela.

## Por que existem duas camadas de tokens

Vesper define branco explicitamente para vários escopos de variáveis. Trocar apenas `editor.foreground` não altera todos eles. Por isso o arquivo visual também usa `editor.tokenColorCustomizations` com regras TextMate para variáveis, comentários e delimitadores de comentários.

Se um provedor como Pylance emitir tokens semânticos, eles podem prevalecer sobre a coloração TextMate. O [módulo de Python](../settings/python.jsonc) mantém essa camada dentro da mesma paleta:

- Variáveis, parâmetros e propriedades em cinza claro.
- Funções, métodos, decorators e variáveis readonly em pêssego.
- Classes e tipos em um neutro um pouco mais claro.

Os seletores terminados em `:python` limitam essas regras semânticas a Python. Não há alteração de diagnósticos, regras de type checking, lint, formatador ou imports. [Guia oficial de semantic highlighting](https://code.visualstudio.com/api/language-extensions/semantic-highlight-guide).

## Escopo das customizações

As cores estão dentro de `[Vesper]`, nos objetos de customização. Ao escolher outro tema, esses grupos deixam de se aplicar. Fonte, layout, ícones e a opção de semântica de Python são preferências do usuário ou perfil e continuam até você alterá-las ou trocar de perfil.

## Symbols com pastas neutras

O ID correto é `symbols`. As associações de pastas usam o ícone `folder` existente no pacote oficial para `src`, `tests`, `data`, `notebooks` e `.venv`. Os ícones dos arquivos permanecem coloridos.

O Symbols muda os arquivos e pastas do Explorer. Os ícones da própria interface usam `workbench.productIconTheme`; o preset mantém essa escolha como estiver no seu perfil. Não é preciso instalar um tema de ícones de produto.

## Layout e navegação

Minimap e breadcrumbs ficam escondidos. A Activity Bar continua na posição padrão, várias abas continuam visíveis e sticky scroll permanece ativado. As guias de indentação e seu realce ativo são mantidos para ajudar a ler Python. Espaços em branco aparecem quando o texto está selecionado.

O tamanho 14 e a altura de linha 22 são o ponto de partida validado. Ajuste-os ao monitor sem precisar mudar as cores.

## Versões de referência

Veja [componentes.json](../componentes.json). As versões registradas identificam o que foi validado e ajudam a investigar diferenças depois de atualizações; não é necessário desativar atualizações ou alterar políticas da empresa para usar o preset.
