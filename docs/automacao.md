# Automação com Python e Git Bash

O instalador reproduz o preset completo validado: Vesper Equilibrado, Symbols com pastas neutras, fonte do editor e do terminal, layout e coloração semântica de Python. Você pode usar **um único arquivo** copiado pelo navegador, sem clonar este repositório.

## Requisitos e alvo

- Windows com **VS Code Stable instalado normalmente** e perfil **Default**.
- **Python 3.9 ou mais recente do Windows**, disponível como `python`, `python3` ou `py -3`. Não precisa de pip, npm ou bibliotecas externas.
- Acesso ao Marketplace e permissão de instalar Vesper e Symbols. Se preferir instalá-los pela interface, use `--skip-extensions`.
- Permissão de escrever nas suas próprias configurações do VS Code.

O Windows Terminal é o aplicativo que hospeda o shell. Para os comandos Python abaixo, abra uma aba de **Prompt de Comando / cmd**; para o `.sh`, use **Git Bash**. O instalador não chama PowerShell, não muda políticas de execução e não precisa de administrador.

O alvo automático é `%APPDATA%\Code\User\settings.json`. Isso significa o perfil **Default**, não necessariamente o perfil ativo em uma janela aberta. Confira seu perfil no VS Code antes de aplicar. O caminho exato aparece no modo de simulação.

## Opção A: um arquivo Python no Prompt de Comando

1. Abra [scripts/install_vesper.py](../scripts/install_vesper.py) no GitHub e copie o código completo com o botão de cópia do arquivo. Não copie a página HTML.
2. Crie um arquivo chamado `install_vesper.py`, cole o conteúdo e salve em **UTF-8**. Confira se o nome não acabou como `install_vesper.py.txt`.
3. Abra o Prompt de Comando na pasta desse arquivo. Você pode abrir a pasta no Explorer, digitar `cmd` na barra de endereço e pressionar Enter.
4. Confirme a versão e simule:

```bat
python --version
python install_vesper.py --dry-run
```

5. Confira o caminho do `settings.json` exibido. Salve eventuais edições abertas desse arquivo e evite alterá-lo enquanto o instalador roda. Para aplicar:

```bat
python install_vesper.py
```

Se seu Python é acessado pelo launcher, os equivalentes são:

```bat
py -3 --version
py -3 install_vesper.py --dry-run
py -3 install_vesper.py
```

Este arquivo contém o preset completo. Ele não lê arquivos do repositório nem baixa código de configuração pela rede.

## Opção B: um arquivo autossuficiente no Git Bash

1. Copie o conteúdo completo de [scripts/install-vesper.sh](../scripts/install-vesper.sh).
2. Salve como `install-vesper.sh`, em UTF-8 **sem BOM**, com finais de linha **LF**. No VS Code, os indicadores de codificação e fim de linha ficam na barra inferior.
3. Abra o Git Bash nessa pasta e execute:

```sh
bash install-vesper.sh --dry-run
bash install-vesper.sh
```

Não precisa de `chmod`, de baixar o `.py` separado ou de ter os JSONC ao lado. O `.sh` contém o mesmo instalador Python e procura o Python do Windows pelos comandos `py -3`, `python` e `python3`, nessa ordem. Ele requer Python: não é um instalador escrito somente em Bash.

O interpretador Bash do WSL é outro ambiente. Use o **Git Bash do Windows** para este roteiro; o launcher recusa um Python Linux para não escolher o diretório errado.

## O que acontece durante a execução

1. Lê e valida o arquivo de configurações. Aceita JSONC com comentários e vírgula final, como o VS Code. Se houver chaves duplicadas, JSON inválido ou um arquivo que não seja UTF-8, para antes de instalar extensões ou alterar configurações.
2. Prepara a mesclagem com o preset embutido. Preserva outras configurações de usuário, incluindo formatadores e opções já existentes em `[python]`.
3. Usa a CLI oficial `code.cmd` para verificar Vesper e Symbols e instalar os ausentes pelo Marketplace. Não usa `--force` nem reinstala IDs encontrados. As extensões podem ser instaladas na versão compatível oferecida pelo Marketplace; o instalador não fixa uma versão antiga.
4. Confirma a presença das extensões. Se a etapa falhar, não grava o `settings.json`. Extensões instaladas antes de uma falha podem permanecer instaladas.
5. Quando há alterações, salva uma cópia exata do arquivo anterior na mesma pasta, com nome `settings.before-vesper-DATA-HORA-identificador.jsonc`. O backup contém suas configurações e permanece local; não é enviado ao GitHub.
6. Confere novamente se o arquivo mudou durante a execução e substitui o conteúdo por um arquivo temporário completo. Essa conferência reduz o risco de sobrescrever uma edição concorrente, mas não bloqueia o VS Code nem o Settings Sync: evite editar o arquivo enquanto instala.

O modo `--dry-run` somente lê e valida. Não cria pastas, backups ou arquivos, não executa a CLI e não instala extensões. Ele verifica se encontra o `code.cmd`, mas a conexão com o Marketplace só será testada na execução real.

Se rodar novamente, as mesmas regras não são duplicadas. Se o preset já corresponder às configurações, nenhum backup ou regravação é feito. O instalador não reinicia nem recarrega o VS Code automaticamente.

## O que é preservado e o que muda

As chaves do [preset completo](../settings/replica-completa.jsonc) passam a usar os valores escolhidos. Outras chaves permanecem. Dicionários são mesclados: por exemplo, `[python].editor.formatOnType` continua presente, enquanto `editor.semanticHighlighting.enabled` recebe `true`.

Os comentários, espaços e finais de linha fora dos valores substituídos são preservados, assim como BOM UTF-8 quando existir. Valores ou listas que precisarem de substituição podem ser reformatados. As regras TextMate pessoais são mantidas; regras com os mesmos nomes das duas regras deste setup são atualizadas. Outras customizações de Vesper também permanecem e podem afetar o resultado final.

O instalador não modifica projetos, atalhos, interpretadores Python, formatadores, opções de lint ou arquivos corporativos. Não instala o Python nem fontes no sistema. Configurações de workspace, da sessão remota ou administradas pela empresa ainda podem prevalecer sobre as preferências do usuário.

## Fonte e extensões de Python

A família configurada é `'Cascadia Code NF', Consolas, monospace`, com ligaduras habilitadas. Isso reproduz a tipografia se **Cascadia Code NF já estiver instalada**. Sem ela, o Windows usa Consolas, cuja aparência e ausência de ligaduras são diferentes. Veja o [guia de fontes](fontes.md) para a instalação opcional.

Para fixar Consolas e desligar ligaduras:

```bat
python install_vesper.py --consolas
```

Para preservar a fonte que você já usa no terminal integrado:

```bat
python install_vesper.py --keep-terminal-font
```

O preset contém as regras semânticas de Python, mas a instalação padrão só acrescenta as duas extensões de aparência. Se Python, Pylance e Python Debugger ainda não estiverem no ambiente e você quiser instalá-los também:

```bat
python install_vesper.py --with-python-extensions
```

No Git Bash, as mesmas opções são aceitas após `bash install-vesper.sh`. Provedores Python são necessários para recursos de linguagem e tokens semânticos, não para o funcionamento básico do tema. O instalador instala no Windows local; provedores necessários em WSL ou outra sessão remota devem ser administrados nessa sessão.

## Se as extensões forem instaladas pela interface

Pesquise pelos IDs `raunofreiberg.vesper` e `miguelsolorio.symbols` no painel de extensões do VS Code, confirme os publicadores e instale-os no perfil escolhido. Então execute:

```bat
python install_vesper.py --skip-extensions --dry-run
python install_vesper.py --skip-extensions
```

O instalador não verifica extensões nesse modo. Mesmo no modo automático, um ID instalado pode estar desabilitado no perfil ou no workspace; confira se Vesper e Symbols estão habilitados se o resultado não aparecer.

## Outro perfil, Insiders, portátil ou WSL

A automação padrão não tenta adivinhar o perfil ativo, não cria perfis e não usa configurações de workspace como alvo. Para um perfil nomeado, Insiders ou instalação portátil:

1. Abra **Preferences: Open User Settings (JSON)** no perfil desejado.
2. Copie o caminho completo do arquivo real pelo menu de contexto da aba. Se o perfil ainda não tiver arquivo próprio, salve suas configurações primeiro.
3. Instale Vesper e Symbols pela interface nesse perfil.
4. Execute o instalador com `--settings-path` e `--skip-extensions`. O caminho deve ser absoluto e apontar para um arquivo existente. Substitua o caminho ilustrativo abaixo pelo seu:

```bat
python install_vesper.py --skip-extensions --settings-path "C:\caminho\do\perfil\settings.json" --dry-run
python install_vesper.py --skip-extensions --settings-path "C:\caminho\do\perfil\settings.json"
```

O requisito de `--skip-extensions` nesse caso evita instalar no perfil Default enquanto altera outro perfil. Não passe o caminho de `.vscode/settings.json` de um projeto. O alvo é o arquivo de **usuário/perfil local**.

Para usar uma janela WSL, aplique a aparência nas configurações locais de usuário do VS Code para Windows, como no [guia corporativo](instalacao-corporativa.md#python-e-wsl). O instalador não escreve em diretórios de usuário Linux.

## Diagnóstico

| Situação | Como resolver |
| --- | --- |
| `python` não existe, mas `py -3` funciona | Use `py -3 install_vesper.py`; o `.sh` já tenta o launcher |
| Python anterior a 3.9 | Use um Python corporativo mais recente disponível ou o roteiro manual |
| `.sh` com erro envolvendo `\r` | Salve com finais LF e UTF-8 sem BOM; execute com `bash`, não com duplo clique |
| `code.cmd` não encontrado | Instale as extensões pela interface e use `--skip-extensions`; ou informe `--code-command` com o caminho absoluto de `bin\code.cmd` da instalação Stable |
| Falha de Marketplace/proxy/política | Use a instalação de extensões permitida pela empresa; depois rode com `--skip-extensions` |
| JSONC inválido ou chave duplicada | Corrija o arquivo no VS Code e rode a simulação novamente; o instalador não escolhe qual chave duplicada descartar |
| Arquivo sem permissão, bloqueado ou alterado durante a execução | Confira o alvo, termine a edição de configurações e execute de novo; não precisa de administrador para um arquivo normal do seu usuário |
| A instalação terminou, mas o visual não mudou | Confira perfil ativo, extensões habilitadas e sobreposições de workspace; veja o [diagnóstico geral](restricoes-e-alternativas.md) |

O suporte automático é a instalação Stable tradicional. Um `code.cmd` de Insiders, outro produto ou dados redirecionados exige o roteiro explícito de perfil. Uma variável `VSCODE_PORTABLE` ou a pasta `data` ao lado do aplicativo interrompem o modo automático.

## Conferir e reverter

Confira o tema, ícones e fonte com a [amostra sintética](../examples/amostra.py) e o [checklist visual](validar-e-reverter.md#conferência-após-a-aplicação). Normalmente as preferências são percebidas pelo editor; se precisar, salve seu trabalho e use **Developer: Reload Window** quando puder interromper a janela.

O caminho do backup aparece no terminal. Para reverter, abra o backup e restaure seu conteúdo nas configurações de usuário do mesmo perfil. Se você mudou outras preferências depois da instalação, compare os arquivos e restaure apenas as chaves do preset, para manter essas alterações posteriores. Veja [o roteiro de reversão](validar-e-reverter.md#reverter-usando-o-backup).

O backup restaura configurações, não a lista de extensões. Vesper e Symbols podem permanecer instalados e inativos; a reversão não exige removê-los.

## Manutenção e testes

O Python é a implementação de referência. O `.sh` leva uma cópia idêntica embutida para permitir a distribuição de um arquivo só. Depois de alterar o `.py`, sincronize o launcher com `python tools/sync_shell_launcher.py`.

Os testes usam diretórios temporários e uma CLI simulada; não alteram as configurações reais nem instalam extensões:

```bat
python -m unittest discover -s tests -v
```

Eles conferem a igualdade do preset com os JSONC, a igualdade entre Python e `.sh`, a preservação de preferências, comentários/BOM/CRLF, idempotência, backups, rejeição de entradas inválidas e falhas de gravação/instalação.

Referências oficiais: [CLI do VS Code](https://code.visualstudio.com/docs/configure/command-line), [configurações e precedência](https://code.visualstudio.com/docs/configure/settings), [perfis](https://code.visualstudio.com/docs/configure/profiles), [processos em Python](https://docs.python.org/3/library/subprocess.html).
