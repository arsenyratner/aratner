Полезные ссылки:
https://ald-firstdc.ald.ratners.ru/
ad/ui/
ipa/migration/
ipa/ui
ipa/config/ca.crt

Что такое ПАК сертификат?

мкц, мрд -

кроме SUDO: pdpl-user -l 63 -i 63 $username и ещё ключей насыпать. pdpl-user -i 63 <имя_пользователя>

Добавить пользователя локлаьного админа
```shell
username=appc; \
userpass='$6$ZnhIZWUDy1PFLOnL$NLDyMoef53vlJMvVvAl6iX92pPvwknDAx55iTQTuUTlvvyb3X0YAEEZPo0xvC1Diei5CPfK0BvRRWxTPRo569/'; \
userkey='ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA7YUTXCKAMavLy98/Kep6eDKK2NyVEc/kUklZUbBubg4DfFHDO2KDXtFN7uq8HPcYR7uqFLqkRijhBwJbnPGLpp2mA+iOHLpJvD/tGpDyNt/ImM0hQG3+dzPLtvzc9Ln5mY2RUfOUTFEx7dqGVuwPQXMhZLCEkpIcGicPTpdG0CIu/GdELUtwgrZZ+reNXMG82VnFBVDZObL7H1YsmrgyyWBUMAzwf+EeUFk9Q4k8qsV8utONo3AvscaESxyt5UDvVuV7PrPxp28a03k9ybMMrXjPzuEaM2P0pxGT0VsIoR/fG78MwkSPTveX0QgDU4gBihOAcH2/2WHGBE+1pr9saw== appc@appc-pc'; \
useradd -m -s /bin/bash -k /etc/skel -p $userpass $username; \
echo "$username ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$username; \
# особенность астры
pdpl-user -l 63 -i 63 $username; \
mkdir -p /home/$username/.ssh; \
echo $userkey >> /home/$username/.ssh/authorized_keys; \
echo "StrictHostKeyChecking=accept-new" > /home/$username/.ssh/config; \
echo 'AddKeysToAgent=yes' >> ~/.ssh/config; \
chown -R ${username}:${username} /home/$username; \
chmod 700 /home/$username/.ssh; \
chmod -R 600 /home/$username/.ssh/*
```
sudo apt install -y python3-apt astra-update

astra-update -A -r -n


## Вопросы

- чо за кольца ядра? 0? 1 - режим гипервизора?
- что такое процессы, прерывания и что-то ещё
- режимы работы ядра?
- dist-upgrade vs upgrade (dist-upgrade выбирает нужную стратегию?)

# Уроки

## Урок 1

- у владельца есть привелегия, назначить права доступа на файл
- mkcmrd - мандатный контроль прав доступа цель обеспечить конфеденциальность.
- локакльные группы - могут содежать только пользователей? локальную группу нельзя сделать членом другой локальной группы.
- 1(архитектура+предназначение).7(очередное обновление).x(оперативное обновление) - обновления с обратной совместимостью
- UU срочные обновления (1.7.UU.2)
- доступны 4 репозитория
- уровни защищённости (базовый орёл, усиленный воронеж, ... смоленск)
- Экосистема Астры: ....
- рекомендую ставить ВМ с ЛВМ (не помню почему)

## Урок 2

- low latency соибрали для серверов БД или для обработки инфы с датчиков на производстве
- astra-update -A
- dist-upgrade vs upgrade (dist-upgrade выбирает нужную стратегию, удаляет лишние пакеты)

## Урок 3

- процесс загрузки
- настройке в проводнике сохраняются при закрытии окна проводника, какое окно закрыли последним, те настройки сохранятся последними и перезапишут все изменения.
- LSA - аналог PAM на винде
- winlogon ui - fly-dm
- explorer - fly-vm (рабочий стол)

## Урок 4 bash

- dpkg-query -L packetname - спиоск файлов в пакете
- dpkg -S /usr/lib/fly - из какого пакета этот файл
- & при перенаправлеии это все потоки?
- !! выполнить последнюю команду, sudo !! последняя команда с судо

- команды
  file - покажет тип файла

## Урок 5

- man
- help для bash
- textinfo
- apropos wich ???

## Урок 6 20240219

- чем отличаются системные вызовы от работы с файлами?

  - https://habr.com/ru/companies/otus/articles/525012/

- fhs
- каналы
- socket - позволяет процессам обмениваться данными
- inode
- junction point mklink -j = mount --bind

## Урок 7 20240220

Всё что читает Эдуард лютая скукота. На просьбе разобрать подробно команду которую он ввёл, отправил читать документацию.

- csv - ?
- xml - xpath
- ldif -
  - :: значает base64
- JSON - JSON XPath jq yq
- YAML - yq
- неразмеченный текст - match примеры
  - поиск цифр [0-9]{1,}
  - найти неопределённый патерн
  - найти в тексте имя фамилия
  - найти email
  - найти телефоны
  - найти адрес сайта
  - найти теги в тексте
- replace - для замены в тексте
- инструмент для проверки регулярных выражений https://regex101.com/
- cat tac head tail tr cut colum sort uniq sed grep awk xargs xpath(libxml-xpath-perl) tee группировка скобками (cat asdf; echo "\n--"; cat sdfg)

## Урок 8 20240221

- uid
- gid
  0 - root
  65534 - nobody
  1-99 - системные пользователи и группы
  100-999 - служебные пользователи и группы
  1000-... созданные пользователи
  ? Чем служебные от системных отличаются?
- sid S-R-IA-SA-N-N-N-RID
  RID уникальный для каждого пользователя и группы (т.е. не может быть группы и пользователя с одинаковым RID) в системе. А в линуксе значение GID может быть таким же как UID
- /etc/login.defs создержит настройки диапазанов UID и GID
- /etc/passwd
- /etc/group
- /etc/shadow
- /etc/skel
- команды работы с пользователями и группами
  chfn
  chage
  ...
  ...
- команды для Ы
  who
  w (what)
  id
  groups - выяснить свои группы
  lslogins - все пользователи системы
  last - журналы входа пльзователей в систему
  lastb - тоже что и ласт но читает из другого журнала btmp
  lastlog -
  faillog - сколько было попыток входа /var/log/faillog - хранит настройки об ограничениях на количество попыток входа

## Урок 9 20240222

Анатолий Лысов - кросавчег отлично читает

- спецфлаги?
-

## Урок 11 bash

compgen -b
compgen -k
whereis
type
enable
help
баш гайд

## Урок 12 Процессы

У процесса всегда есть родитель!

## Урок 15

Как удалить все зависимости метапакета?
Как установить файл пакета аптом, чтобы он решил все зависимости?
base средства разработки
main и update лицензируется
wget
надо использовать frozen

## Урок 16 CUPS

Логи
access_log
error_log
pages_log - вск напечатанные страницы

/var/spooo/cups - задания на печать, управляющие файлы cXXXX, файлы данных dXXXXX
Управляющие файлы удаляются после пятисотого задания, файлы данных удаляются после успешного завершения задания

cups-lpd работает через inetd tcp/515

фильтры - преобразуют в формат пригодный для печати
Монитор портов -
lpinfo -v посмотреть все транспорты
lpstat -p

fly-admin-printer

принтум - для управления доступа к принтерам

## Урок

vfs - что такое?

## Урок

