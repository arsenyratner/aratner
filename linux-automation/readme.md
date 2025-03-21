

#Включить перемещение по каталогам стрелочками (Lynx style navigation")

sed -i 's/^navigate_with_arrows.*$/navigate_with_arrows=true/g' ~/.config/mc/ini

sed -i 's/^locale: ru_RU.UTF-8/locale: en_US.UTF-8/g' /etc/cloud/cloud.cfg
