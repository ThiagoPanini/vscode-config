# Restrições e diagnóstico de problemas

Este roteiro considera que a instalação de extensões pelo Marketplace é permitida. A leitura dos arquivos e a aplicação das preferências são manuais, para funcionar mesmo quando scripts e downloads de outros repositórios estão restritos.

## Consigo abrir o GitHub, mas não baixar arquivos

Expanda os blocos de configuração no [README](../README.md#copiar-as-configurações-direto-desta-página) e copie o texto. Clonar o repositório, baixar ZIP ou acessar o domínio de arquivos raw não são etapas obrigatórias. Os links para a documentação detalhada também podem ser lidos pelo navegador.

## O VS Code continua com outra aparência

1. Confira o perfil ativo e se você editou suas configurações de usuário.
2. Confirme que Vesper e Symbols estão instalados e habilitados nesse perfil.
3. Confira `workbench.colorTheme: "Vesper"` e `workbench.iconTheme: "symbols"`.
4. Procure valores conflitantes nas configurações do workspace ou da sessão remota.
5. Confira se `window.autoDetectColorScheme` ficou `false`, como no preset.
6. Confira erros de sintaxe ou chaves duplicadas no `settings.json`.

O VS Code aplica uma ordem de precedência: configurações de workspace, de linguagem ou políticas podem prevalecer sobre outras preferências. Configurações administradas pela organização podem ser obrigatórias. [Precedência oficial](https://code.visualstudio.com/docs/configure/settings#_settings-precedence).

## Aparece uma configuração desconhecida

Abra **Help > About / Ajuda > Sobre** e confira a versão do VS Code. Este setup foi validado na versão 1.141.0. O Symbols 0.0.26 declara suporte a VS Code `^1.88.0`, e Vesper 0.0.40 declara `^1.75.0`. Isso descreve os requisitos dos pacotes, não a compatibilidade de cada ajuste com todas as versões anteriores.

Confira primeiro se a extensão correspondente está instalada. Por exemplo, uma opção `symbols.*` depende de Symbols. Para opções de interface que uma versão antiga não conhece, preserve a versão disponibilizada pela empresa e deixe de aplicar somente os campos não suportados, registrando a diferença. O restante da paleta não depende de um script de migração.

## Não consigo instalar a fonte

Use a fonte já disponível. No Windows, o preset tem fallback para Consolas. [fontes-alternativas.jsonc](../settings/fontes-alternativas.jsonc) fixa essa opção e desativa as ligaduras. As cores, os ícones e o layout continuam disponíveis, com diferença de tipografia. [Guia de fontes](fontes.md).

## Os ícones não mudaram

Confirme `symbols` como File Icon Theme. Salve o trabalho e use **Developer: Reload Window** quando puder recarregar extensões e sessões em andamento. As associações de pasta usam o nome exato da pasta. Se ela se chama `source`, por exemplo, o mapeamento de `src` não se aplica a ela.

## A cor de Python difere da amostra

Confirme se você aplicou o [módulo Python](../settings/python.jsonc), se o provedor de linguagem está ativo e se há configurações específicas para Python no projeto ou na sessão remota. Tokens semânticos dependem do provedor e da versão. O tema continua funcionando por TextMate sem essa camada.

As amostras de imagem são ilustrativas. Para investigar um token real, use **Developer: Inspect Editor Tokens and Scopes** com o cursor sobre ele e confira quais regras estão sendo usadas.

## Uma extensão passa a ser bloqueada

Use o ID e a versão registrados em [componentes.json](../componentes.json) para solicitar orientação à equipe responsável. Se Symbols não estiver disponível, mantenha um pack já aprovado enquanto usa Vesper. Se o próprio Vesper estiver bloqueado, não é possível prometer uma réplica exata só selecionando seu nome no JSON.

Instalação por VSIX é uma alternativa oficial para distribuição controlada pela empresa, quando necessária e aprovada; não faz parte do caminho principal e não elimina políticas de extensões. [Instalação por VSIX](https://code.visualstudio.com/docs/configure/extensions/extension-marketplace#_install-from-a-vsix) e [gerenciamento corporativo](https://code.visualstudio.com/docs/enterprise/extensions).
