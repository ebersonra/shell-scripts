## Shell para instalar o Java e o Gradle no Ubuntu 20.04.

#### Configurando o arquivo <em>passwd.txt</em> com a senha do seu usuário root.
```
$ touch passwd.txt && vim passwd.txt
```
### Instalando Java.
#### Instalando Java JDK Default para Ubuntu 24.04. Ex: Java JDK 11.
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