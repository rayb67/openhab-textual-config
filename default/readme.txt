A fresh installation is based on the initial setup of a new version of Openhab. 
The purpose is, when updating to a new version, where we can thus exclude potential errors during the upgrade.

cp i18n.config ../userdata/config/org/openhab/.
cp users.json  ../userdata/jsondb/.
cp addons.cfg  ../conf/services/.

user     : admin
password : admin
