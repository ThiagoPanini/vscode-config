# Instalação manual no ambiente corporativo

O caminho principal usa o Marketplace do próprio VS Code. A aplicação consiste em instalar duas extensões de aparência e mesclar configurações de usuário. Você pode ler e copiar tudo pelo GitHub, sem clonar o repositório ou executar scripts.

## 1 Guardar o estado atual

1. Abra o VS Code usado no trabalho.
2. Pressione `Ctrl+Shift+P` e procure por **Open User Settings (JSON)** ou **Configurações do Usuário (JSON)**.
3. Copie o conteúdo para um arquivo local de backup, em uma pasta permitida pela empresa. Não envie esse backup para este repositório.
4. Se desejar isolar a aparência, abra **File > Preferences > Profiles** e crie **Vesper Trabalho** copiando o perfil atual. Preserve as extensões e configurações que já usa.
5. Confirme qual perfil está ativo antes de editar. As configurações de usuário abertas no próximo passo devem pertencer a esse perfil.

Usar um perfil copiado é uma conveniência, não uma dependência. Você pode aplicar diretamente às configurações do usuário com o backup guardado. [Perfis e cópia de configurações](https://code.visualstudio.com/docs/configure/profiles).

## 2 Instalar Vesper

1. Abra Extensions / Extensões com `Ctrl+Shift+X`.
2. Pesquise por `@id:raunofreiberg.vesper`.
3. Confira **Vesper**, do publicador **Rauno Freiberg**, ID `raunofreiberg.vesper`.
4. Clique em **Install / Instalar**.
5. Se aparecer o botão **Set Color Theme**, selecione **Vesper**. Você também pode usar **Preferences: Color Theme** na paleta de comandos.

[Página oficial de Vesper](https://marketplace.visualstudio.com/items?itemName=raunofreiberg.vesper). A referência validada deste repositório é `0.0.40`.

## 3 Instalar Symbols

1. No mesmo painel, pesquise por `@id:miguelsolorio.symbols`.
2. Confira **Symbols**, do publicador **Miguel Solorio**, ID `miguelsolorio.symbols`.
3. Clique em **Install / Instalar**.
4. Use **Preferences: File Icon Theme** na paleta e selecione **Symbol Icons**, ou deixe o JSON ativá-lo por meio de `workbench.iconTheme: "symbols"`.

[Página oficial de Symbols](https://marketplace.visualstudio.com/items?itemName=miguelsolorio.symbols). A referência validada é `0.0.26`.

Os presets neutralizam as pastas `src`, `tests`, `data`, `notebooks` e `.venv`. Os arquivos continuam com seus ícones e cores. Isso é intencional: Symbols não é um pack monocromático.

## 4 Aplicar a aparência

1. Abra [settings/vesper.jsonc](../settings/vesper.jsonc), ou expanda o mesmo bloco no [README](../README.md#copiar-as-configurações-direto-desta-página).
2. Copie o conteúdo.
3. Volte às configurações do usuário ou do perfil no VS Code.
4. Mescle as propriedades conforme [o guia com exemplos](aplicar-configuracoes.md). Preserve as opções existentes e não crie chaves duplicadas.
5. Salve o arquivo. A maior parte das mudanças aparece imediatamente.
6. Se os ícones ficarem em cache, salve o trabalho e execute **Developer: Reload Window** quando for conveniente. Esse comando recarrega a janela e pode reiniciar extensões ou sessões em andamento.

O arquivo de aparência inclui a fonte do editor com fallback. A instalação de uma fonte nova não é necessária para concluir esta etapa.

## 5 Acrescentar os opcionais desejados

- **Python:** mescle [settings/python.jsonc](../settings/python.jsonc) se quiser a mesma coloração semântica do preset de referência.
- **Fonte alternativa:** use [settings/fontes-alternativas.jsonc](../settings/fontes-alternativas.jsonc) se quiser fixar Consolas no Windows.
- **Terminal:** use [settings/terminal.jsonc](../settings/terminal.jsonc) somente para reproduzir também a fonte do terminal integrado.

[settings/replica-completa.jsonc](../settings/replica-completa.jsonc) reúne o visual, Python e a fonte do terminal em um objeto. Ele é uma alternativa à aplicação por partes, não um segundo arquivo a aplicar obrigatoriamente.

## Python e WSL

Tema, ícones e fonte não exigem instalar Python, criar ambiente virtual, executar `pip` ou adicionar um formatador. Para a camada semântica de Python, mantenha o provedor de linguagem usado no trabalho. O ambiente de referência usa [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python) e [Pylance](https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance), mas eles não são requisitos para instalar Vesper e Symbols. O [Python Debugger](https://marketplace.visualstudio.com/items?itemName=ms-python.debugpy) só é relevante para depuração.

Em uma janela WSL ou remota, instale as extensões visuais no lado local da interface. A fonte é a do sistema que desenha a janela do VS Code; na configuração Windows com WSL, instale ou selecione a fonte no Windows. Python e seus recursos de linguagem podem ficar no ambiente remoto conforme a indicação do VS Code. Não é preciso instalar o Vesper dentro de um projeto Python.

Não coloque o preset visual em `.vscode/settings.json` de um projeto compartilhado para replicar suas preferências em todos os projetos. Use as configurações de usuário ou de um perfil. Um workspace pode ter configurações próprias que prevaleçam; confira [o diagnóstico](restricoes-e-alternativas.md).

## 6 Conferir o resultado

Abra [examples/amostra.py](../examples/amostra.py), sem precisar executá-lo, e siga [a validação e a reversão](validar-e-reverter.md).

## Fontes oficiais

- [Instalar extensões pelo Marketplace](https://code.visualstudio.com/docs/configure/extensions/extension-marketplace)
- [Configurações de usuário e workspace](https://code.visualstudio.com/docs/configure/settings)
- [Selecionar temas e ícones](https://code.visualstudio.com/docs/configure/themes)
- [Perfis](https://code.visualstudio.com/docs/configure/profiles)
