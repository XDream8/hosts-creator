# hosts-creator

## FEATURES
- [X] Configuration file
- [X] Colored output
- [X] Download and merge multiple host lists
- [X] remove comments, trailing spaces and  duplicate lines from new hosts file
- [X] replace new hosts file with /etc/hosts
- [X] use rdo or doas if available, if not use sudo
- [X] backup old /etc/hosts file
- [X] error management while using doas(sudo or rdo)
- [X] size check(if file is > 60M, it reports to you)
## Deps
- (doas, sudo or rdo)
- curl
- awk
- hostname
## Usage
**clone the repository and enter into directory**
```sh
$ git clone https://github.com/XDream8/hosts-creator
$ cd hosts-creator
```
**edit the configuration with your favourite editor**
```sh
$ nvim config
```
**run the script**
```sh
$ ./hosts-creator.sh
```
