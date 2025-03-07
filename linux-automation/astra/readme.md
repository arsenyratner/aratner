

## Сгенерить файл ответов с проинсталированной системы
взять инфу из файла /var/log/installer/cdebconf
```shell 
preseedcfg=/var/tmp/preseed.cfg
$ sudo chmod +rx /var/log/installer/cdebconf
$ echo "#_preseed_V1" > $preseedcfg
$ debconf-get-selections --installer >> $preseedcfg
$ debconf-get-selections >> $preseedcfg$
```
