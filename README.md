<p1>
hosts-creator
</p1>

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
