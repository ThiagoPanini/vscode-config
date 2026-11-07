# Validar e reverter

## Conferência após a aplicação

1. **Tema e superfícies:** confirme Vesper na seleção de tema. Editor e sidebar devem usar o fundo quase preto; a aba ativa continua identificável.
2. **Ícones:** confira os arquivos e pastas do Explorer. `src`, `tests`, `data`, `notebooks` e `.venv` devem usar a pasta neutra quando existirem. Arquivos continuam coloridos.
3. **Python:** abra [amostra.py](../examples/amostra.py) e compare comentários, variáveis, strings, números e funções. A leitura não exige executar o arquivo. Se aplicar a semântica, considere o tempo de inicialização do provedor de linguagem.
4. **Fonte:** compare `0 O`, `1 l I`, `!=`, `==`, `<=`, `>=` e `->`. A presença de ligaduras depende da fonte instalada. Cores e ícones não dependem das ligaduras.
5. **Busca e seleção:** use `Ctrl+F` e selecione texto. A busca deve usar pêssego e a seleção deve ser neutra.
6. **Git:** quando tiver um diff real, confira adições menta e remoções vermelhas. Os sinais funcionais permanecem coloridos.
7. **Diagnósticos e depuração:** em um projeto real, confira os sublinhados de erro e aviso e, quando depurar, a status bar discreta. O preset não desativa diagnósticos.
8. **Preferências de trabalho:** confira se seu formatador, imports, testes, ambiente Python e atalhos continuam como antes. O roteiro pede mesclagem para preservá-los.

Se usar somente o preset visual, diferenças de Python semântico e de fonte do terminal são esperadas: esses recursos estão em módulos opcionais.

## Reverter usando um perfil

Se você criou um perfil Vesper Trabalho copiando o atual, abra a paleta e procure por **Profiles: Switch Profile**. Selecione o perfil anterior. Perfis podem ficar associados a um workspace; confira a associação se a janela voltar a selecionar outro perfil ao reabrir o projeto. [Documentação de perfis](https://code.visualstudio.com/docs/configure/profiles).

## Reverter usando o backup

1. Abra as configurações de usuário do perfil em que aplicou o preset.
2. Se você não fez outras mudanças desde o backup, restaure o conteúdo do arquivo local que guardou antes da instalação.
3. Se houve outras mudanças, compare os dois arquivos e remova ou restaure apenas os campos do preset. Assim, você preserva as alterações recentes.
4. Selecione o tema e os ícones anteriores, se ainda não tiverem voltado com a restauração.
5. Salve e, se necessário, recarregue a janela quando for conveniente.

## Reverter somente a aparência

Os arquivos deste repositório mostram as chaves que o preset usa. Restaure seus valores anteriores ou remova as chaves que você acrescentou para retornar aos padrões do VS Code. Remova o grupo `[Vesper]` dos objetos de customização somente se ele contiver exclusivamente os ajustes deste preset.

Fonte, layout e ícones são preferências do perfil; eles podem continuar ativos mesmo ao trocar o tema de cores. No bloco `[python]`, remova somente `editor.semanticHighlighting.enabled` se essa foi a opção acrescentada. Preserve as outras opções da linguagem.

Não é necessário desinstalar Vesper ou Symbols para voltar a outro tema. Eles podem continuar instalados e inativos.
