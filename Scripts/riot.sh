mkdir /var/www/riot.example.com
cd /var/www/riot.example.com
wget https://github.com/vector-im/riot-web/releases/download/v1.6.0/riot-v1.6.0.tar.gz
apt -y install gnupg
wget https://github.com/vector-im/riot-web/releases/download/v1.6.0/riot-v1.6.0.tar.gz.asc
tar -xzvf riot-v1.6.0.tar.gz
ln -s riot-v1.6.0 riot
chown www-data:www-data -R riot
cd riot
cp config.sample.json config.json
nano config.json