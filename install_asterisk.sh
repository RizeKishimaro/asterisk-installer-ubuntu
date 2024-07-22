echo "Starting Installation Script"
read -p "What is your Desired Asterisk Version To Install?:-> " ast_ver
sudo apt update
sudo apt install wget build-essential git autoconf subversion pkg-config libtool
echo "Entering src directory to build"
cd /usr/src/
sudo wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz
tar -xvzf dahdi-linux-complete-current
cd dahdi-linux-complete-current
sudo make && sudo make install
cd /usr/src/
sudo git clone -b next https://github.com/asterisk/dahdi-tools
cd dahdi-tools
sudo ./configure
sudo make install
sudo make install-config
sudo dahdi_genconf modules
cd /usr/src/
sudo git clone https://github.com/asterisk/libpri 
cd libpri
sudo make
sudo make install
cd /usr/src/
sudo git clone -b $ast_ver https://github.com/asterisk/asterisk asterisk-$ast_ver
cd asterisk-$ast_ver
sudo contrib/scripts/get_mp3_source.sh
sudo contrib/scripts/install_prereq install
sudo ./configure
sleep 3
echo "Make menu popup will appear inorder to install asterisk you need to select format_mp3"
read ack

sudo make menuselect
sudo make -j2
sudo make install

echo "Are you trying to Setup a PBX or Generic Asterisk?
1. Generic Asterisk
2. PBX
"
read install_tp

if [ $install_tp -eq 1 ];then
  sudo make samples
elif [ $install_tp -eq 2 ];then 
  sudo make basic-pbx
else 
  echo "invalid input"
  exit 1
fi

sudo make config
sudo ldconfig
sudo adduser --system --group --home /var/lib/asterisk --no-create-home --gecos "Asterisk PBX" asterisk
echo "Now adding group"
sudo sed -i '/^#AST_USER=/s/^#//' "/etc/default/asterisk"
sudo sed -i '/^#AST_GROUP=/s/^#//' "/etc/default/asterisk"
sudo usermod -a -G dialout,audio asterisk
sudo chown -R asterisk: /var/{lib,log,run,spool}/asterisk /usr/lib/asterisk /etc/asterisk
sudo chmod -R 750 /var/{lib,log,run,spool}/asterisk /usr/lib/asterisk /etc/asterisk
sudo systemctl restart asterisk
echo "
Installation Done you may launch asterisk by using 
asterisk -vvvvr
"


