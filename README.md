# hosts-creator

## FEATURES
- [X] Download and merge multiple host lists
- [X] remove comments, trailing spaces and  duplicate lines from new hosts file
- [X] replace new hosts file with /etc/hosts
- [X] use doas if available, if not use sudo
- [X] backup old /etc/hosts file
- [X] error management while using doas(or sudo)
- [X] size check(if file is > 60M, it reports to you)
## Deps
- doas or sudo
- curl
- awk
- hostname
## Usage
**clone the repository**
```sh
$ git clone https://github.com/XDream8/hosts-creator
```
**make the script executable**
```sh
$ chmod +x hosts-creator.sh
```
**run the script**
```sh
$ ./hosts-creator.sh
```
