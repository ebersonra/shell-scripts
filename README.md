## Shell para instalar o Java e o Gradle no Ubuntu 20.04.

#### Configurando o arquivo <em>passwd.txt</em> com a senha do seu usuário root.
```
$ touch passwd.txt && vim passwd.txt
```
### Instalando Java.
#### Instalando Java JDK Default para Ubuntu 20.04. Ex: Java JDK 11.
```
$ ./env-dev.sh 
```
#### Instalando uma versão especifica do Java. Ex: Java JDK 8
```
$ ./env-dev.sh 8
```
### Instalando Gradle.
#### Execute o script a baixo:
```
$ ./env-dev.sh
```
#### Responda as perguntas a baixo:
```
Do you have a specific version? [y] or [n] .:
```
#### Se tiver uma versão especifica, responda a pergunta a baixo seguindo o padrão do exemplo:
```
What's your version? Ex: v4.10.5
```

## Comandos globais (`dell-*`)

O repositório é a **fonte da verdade**. `link-global.sh` cria symlinks em `/usr/local/bin` — edições nos `.sh` do projeto valem na hora, sem recopiar.

```bash
cd /caminho/para/shell-scripts
sudo ./link-global.sh          # cria/atualiza links
./link-global.sh --list        # ver mapeamento
sudo ./link-global.sh --remove # remove links deste repo
```

Depois, em **qualquer terminal** (sem `cd` no projeto):

| Comando global | Equivalente no repo |
|----------------|---------------------|
| `env-dev.sh` | `./env-dev.sh` |
| `git-config-user.sh` | `./git-config-user.sh` |
| `dell.sh` | `./dell.sh` |
| `sudo dell-optimize-system` | `./dell/optimize_system.sh` |
| `sudo dell-setup-amd-gpu` | `./dell/setup_amd_gpu.sh` |
| `sudo dell-fix-amd-error` | `./dell/fix_amd_error.sh` |
| `dell-link-global --list` | `./link-global.sh --list` |

Se mover o clone do projeto, rode de novo `sudo ./link-global.sh` (ou `sudo dell-link-global`) para apontar os links ao novo caminho.
