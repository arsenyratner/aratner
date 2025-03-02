## acl

```
aclpath=/srv/vm/share2
#aclpath=/var/tmp/fsn03/share3
realm="redadm.nornik.ru"
readgroup="domain users@${realm}"
writegroup="domain admins@${realm}"
mkdir -p $aclpath
setfacl -b $aclpath
#chmod -R ugo+rwX $aclpath
setfacl -R -m g:"$readgroup":rX,g:"$writegroup":rwX $aclpath
getfacl --access $aclpath | setfacl -R -d -M- $aclpath

semanage fcontext -a -t samba_share_t $aclpath
restorecon -R -v $aclpath

```

## quota

```
#fstab
#ext4 defaults,usrquota,grpquota
#xfs defaults,uquota,gquota
#ext4 jornaled usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0
localdev=/dev/vg1data/lv_vm
localpaht=/srv/vm

#echo "$localdev $localpaht ext4 defaults,usrquota,grpquota 0 0" >> /etc/fstab
mount -o remount $localpaht
mount | grep quota
quotaon $localpaht
quotacheck -F vfsv0 -avum

> $localpaht/aquota.user
> $localpaht/aquota.group
chmod 600 $localpaht/aquota.user
chmod 600 $localpaht/aquota.group

quotacheck -avug -f
sudo  edquota -u test

edquota -g dl_q_Vm_20mb
20480 - 20 mb
edquota -u fsuser1
edquota -p fsuser1 fsuser2

repquota -ug /srv/vm

#fsuser1
#F$user1


```


dnf -y install unison251*

st2fsn03
/srv/vm/fsn03_sourcedir
/srv/vm/fsn00_twoway
st2fsn00
/srv/samba/fsn03_targetdir
/srv/samba/fsn00_twoway

echo $(date +%Y%m%d-%H%M%S) > $(date +%Y%m%d-%H%M%S)
( sleep 10 ; echo $(date +%Y%m%d-%H%M%S) > $(date +%Y%m%d-%H%M%S) )
( sleep 25 ; echo $(date +%Y%m%d-%H%M%S) > $(date +%Y%m%d-%H%M%S) )
( sleep 50 ; echo $(date +%Y%m%d-%H%M%S) > $(date +%Y%m%d-%H%M%S) )

rsync -rlptgoXAUN --delete -e ssh /srv/vm/fsn03_sourcedir/ root@st2fsn00.redadm.nornik.ru:/srv/samba/fsn03_targetdir

unison -batch=true ~/source/ ~/target/


#fsn00_twoway
```
#/bin/bash
sourcedir="/srv/samba/fsn00_twoway"
targetdir="/srv/vm/fsn00_twoway"
targethost="st2fsn03.redadm.nornik.ru"
targetuser="root"
#rsync -rlptgoXAUN --bwlimit=1000 --delete -e ssh $sourcedir $targetuser@$targethost:$targetdir; logger "rsync done"
#unison -batch=true $sourcedir $targetuser@$targethost:$targetdir

(sleep 10 ; echo $(date +%Y%m%d-%H%M%S) > $sourcedir/fsn00-$(date +%Y%m%d-%H%M%S); logger "echo 10") &
(sleep 25 ; echo $(date +%Y%m%d-%H%M%S) > $sourcedir/fsn00-$(date +%Y%m%d-%H%M%S); logger "echo 25") &
(sleep 50 ; echo $(date +%Y%m%d-%H%M%S) > $sourcedir/fsn00-$(date +%Y%m%d-%H%M%S); logger "echo 50") &

mkdir /root/.unison
cat > /root/.unison/fsn00_twoway.prf << EOF
root = $sourcedir
root = ssh://${targetuser}@${targethost}/${targetdir}
# Список подкаталогов, которые нужно синхронизировать
#path=sysvol
auto=true
batch=true
perms=0
rsync=true
maxthreads=1
retry=3
confirmbigdeletes=false
servercmd=/usr/bin/unison
# использовать rsync только для больших файлов??
copythreshold=1000
copyprog = /usr/bin/rsync -XAavz --rsh='ssh -p 22' --inplace --compress
copyprogrest = /usr/bin/rsync -XAavz --rsh='ssh -p 22' --partial --inplace --compress
copyquoterem = true
copymax = 1

# Сохранять журнал с результатами работы в отдельном файле
logfile = /var/log/unison-sync.log
EOF
cat /root/.unison/fsn00_twoway.prf

```