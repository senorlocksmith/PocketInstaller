#!/bin/bash

cd ~/PocketInstaller

#sudo rm -R -f log.txt
echo "Welcome to PocketInstaller" | sudo tee log.txt

sudo chmod 777 log.txt
exec &> >(tee -a log.txt)

sudo apt-mark hold -qq  pocket-home

if hash zenity 2>/dev/null; then
  :
else
  sudo apt-get update
  sudo apt-get install -y zenity
fi
if hash jq 2>/dev/null; then
  :
else
 sudo apt-get update
 sudo apt-get install -y jq
fi
if hash yad 2>/dev/null; then
  :
else
  echo "deb http://pkg.bunsenlabs.org/debian bunsen-hydrogen  main" | sudo tee -a /etc/apt/sources.list
  sudo wget https://pkg.bunsenlabs.org/debian/pool/main/b/bunsen-keyring/bunsen-keyring_2016.7.2-1_all.deb
  sudo dpkg -i bunsen-keyring_2016.7.2-1_all.deb
  echo "#key added" | sudo tee -a /etc/apt/sources.list
  sudo apt-get update
  sudo apt-get install -y yad
fi
if grep -Fxq "deb http://pkg.bunsenlabs.org/debian bunsen-hydrogen  main" /etc/apt/sources.list && grep -Fxq "#key added" /etc/apt/sources.list; then
  :
else
  sudo wget https://pkg.bunsenlabs.org/debian/pool/main/b/bunsen-keyring/bunsen-keyring_2016.7.2-1_all.deb
  sudo dpkg -i bunsen-keyring_2016.7.2-1_all.deb
  sudo apt-get update
  echo "#key added" | sudo tee -a /etc/apt/sources.list
fi

# Check for Pocket Home to correct config.json (might not be necessary.)
# if test -f ~/.pocket-home/.version; then
#   sed 's/},\s*]/}\n]/' ~/.pocket-home/config.json > tmp.$$.json
#   mv tmp.$$.json ~/.pocket-home/config.json
# fi

if hash mednafen 2>/dev/null; then
  :
else
  P1="Mednafen(GB,GBA,NES,SNES,NPC)|Installers/mednafen.sh"
fi
if hash x64 2>/dev/null; then
  :
else
  P2="Vice(C64,C128)|Installers/vice.sh"
fi
if hash prboom  2>/dev/null; then
  :
else
  P3="Doom|Installers/doom.sh"
fi
if hash openttd 2>/dev/null; then
  :
else
  P4="OpenTTD|Installers/openttd.sh"
fi
if hash dosbox 2>/dev/null; then
  :
else
  P5="DOSBox|Installers/dosbox.sh"
fi
if hash scummvm 2>/dev/null; then
  :
else
  P6="ScummVM|Installers/scummvm.sh"
fi
if hash pcsx 2>/dev/null; then
  :
else
  P7="PCSX(PSX)|Installers/pcsx.sh"
fi
if hash gngeo 2>/dev/null; then
  :
else
  P8="GnGeo(NeoGeo)|Installers/gngeo.sh"
fi
if hash zoom 2>/dev/null; then
  :
else
  P9="Zoom(Z-machine)|Installers/zoom.sh"
fi
if dpkg-query -s bsdgames &>> /dev/null; then
  :
else
  P10="BSDgames|Installers/bsd.sh"
fi
if test -f /home/chip/chipcraft-master/start.sh; then
  :
else
  P11="Minecraft|Installers/minecraft.sh"
fi
if hash openarena 2>/dev/null; then
  :
else
  P12="QuakeIII|Installers/quake3.sh"
fi
if hash retroarch 2>/dev/null; then
  :
else
  P13="RetroArch|Installers/retroarch.sh"
fi
if hash u4 2>/dev/null; then
  :
else
  P14="XU4|Installers/xu4.sh"
fi
if hash freedroid 2>/dev/null; then
  :
else
  P15="Freedroid|Installers/freedroid.sh"
fi
if test -f ~/ColEm/ColEm.c; then
  :
else
  P16="ColEm|Installers/colem.sh"
fi
if test -f ~/ZEsarUX-4.1/scrsdl.c; then
  :
else
  P17="ZEsarUX|Installers/zesarux.sh"
fi
if hash gargoyle-free 2>/dev/null; then
  :
else
  P18="Gargoyle|Installers/gargoyle.sh"
fi
if hash lectrote 2>/dev/null; then
  :
else
  P19="Lectrote|Installers/lectrote.sh"
fi
if test -f ~/.pocket-home/.version; then
  :
else
  P20="PocketHome(Marshmallow)|Installers/pockethome.sh"
fi

menu=($P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 $P10 $P11 $P12 $P13 $P14 $P15 $P16 $P17 $P18 $P19 $P20)

yad_opts=(--form
--scroll
--text="Install Software"
--image="icon.png"
--button="Install" --button="Exit")

for m in "${menu[@]}"
do
yad_opts+=( --field="${m%|*}:CHK" )
done

IFS='|' read -ra ans < <( yad "${yad_opts[@]}" )

for i in "${!ans[@]}"
do
if [[ ${ans[$i]} == TRUE ]]
then
m=${menu[$i]}
name=${m%|*}
cmd=${m#*|}
echo "selected: $name ($cmd)"
$cmd
fi
done

# Icon for Pocket Installer
if test -f ~/.pocket-home/.version; then
  IS_ICON_PRESENT=`jq '.pages[0] | .items[] | select(.name == "PocketInstaller")' ~/.pocket-home/config.json`
  if [ -z ${IS_ICON_PRESENT} ]
  then
    jq '(.pages[0] | .items) |= . + [{ "name": "PocketInstaller", "icon": "~/PocketInstaller/desktopicon.png", "shell": "vala-terminal -fs 8 -g 20 20 -e ~/PocketInstaller/PocketInstaller.sh" }]' ~/.pocket-home/config.json > tmp.$$.json
    mv tmp.$$.json ~/.pocket-home/config.json
  fi
  zenity --info --text="Restart Pocket-Home to show icons for new software."
  killall pocket-home && nohup pocket-home &
fi

echo "Closing PocketInstaller, see you soon!"
sleep 3
kill -9 $PPID
