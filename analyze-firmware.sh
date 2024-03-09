#!/bin/bash

GREEN='\033[0;32m' # Green Color
RED='\033[0;31m' # Red Color
YELLOW='\033[1;33m' # Yellow Color
NC='\033[0m' # No Color

echo -e "${YELLOW}[*]Start script ${NC}"
read -p 'Enter full path to firmware: ' namefile

echo -e "${YELLOW}[*]Gathering infomation about system..${NC}"
mkdir Firmware
binwalk "$namefile" -B  --log=Firmware/About_System &>/dev/null
echo -e "${YELLOW}[*]The report can found in Firmware/About_System.txt${NC}"
read -p ''
echo -e "${YELLOW}[*]Start extracting filesystem..${NC}"
mkdir Firmware/Filesystem
cp "$namefile" Firmware/Filesystem
cd Firmware/Filesystem
sudo binwalk "$namefile" -Me --log=../About_Filesystem --run-as=root &>/dev/null
echo -e "${YELLOW}[*]Attempting to find init files:${NC}"
output1=$( sudo find . -iname "inittab")
if [ -z "$output1" ]
then echo -e "${RED}[!]inittab not found ${NC}"
else grep sysinit: "$output1"
fi
echo -e "${YELLOW}[*]Attemting to find libs for launcher: ${NC}"
outputall=$(sudo find -iname "*.so")
echo -e "${GREEN}All libs-path can be found in Firmware/Libs.txt"; echo "$outputall" > ../Libs.txt 
output1=$( sudo find . -iname "libcrypto*.so")
if [ -z "$output1" ]
then echo -e "${RED}[!]libcrypto not found${NC}"
else echo -e "${GREEN}[+]libcrypto  was found:${NC} \n$output1"
fi
output1=$( sudo find . -iname "libstdc++*")
if [ -z "$output1" ]
then echo -e "${RED}[!]libstdc++ not found${NC}"
else echo -e "${GREEN}[+]libstdc++ was found: ${NC} \n$output1 "
fi
output1=$( sudo find . -iname "libssl.so")
if [ -z "$output1" ] 
then echo -e "${RED}[!]libssl  not found ${NC}"
else echo -e "${GREEN}[+]libssl was found: ${NC} \n$output1 "
fi

echo -e "${YELLOW}[*]Attemting to find Cron: ${NC}"
output1=$( sudo find . -iname "crontab")
if [ -z "$output1" ] 
then echo -e "${RED}[!]crontab  not found ${NC}"
else echo -e "${GREEN}[+]crontab was found: ${NC} \n$output1 "
fi                                                 
echo -e "${YELLOW}[*]Attemting to find curl and wget: ${NC}"
output1=$( sudo find . -iname "curl")
if [ -z "$output1" ] 
then echo -e "${RED}[!]Curl  not found ${NC}"
else echo -e "${GREEN}[+]Curl was found:${NC} \n$output1 "
fi
output1=$( sudo find . -iname "wget")
if [ -z "$output1" ] 
then echo -e "${RED}[!]Wget  not found ${NC}"
else echo -e "${GREEN}[+]Wget was found: ${NC} \n$output1 "
fi

echo -e "${YELLOW}[*]Attemting to find webserver: ${NC}"

while IFS= read -r line
do
  output2=$( sudo find -iname "$line")
  if [ -z "$output2" ]
  then echo -e "${YELLOW} Check $line... ${NC}"
  else echo -e "${GREEN}[+] $line was found: ${NC} \n$output2 "; break
  fi 
done < ../../webservers.txt 

echo -e "${YELLOW}[*]Attemting to find Python: ${NC}"
output1=$(sudo find -iname "*.py")
if [ -z "$output1" ] 
then echo -e "${RED}[!]Python  not found ${NC}"
else echo -e "${GREEN}[+]Python was found: Check the Firmware/PythonScripts.txt${NC}"; echo -e "$output1" > ../PythonScripts.txt
fi

echo -e "${YELLOW}[*]Attemting to find webui files: ${NC}"
output1=$( sudo find . -iname "*.html")
output2=$( sudo find . -iname "*.js*")
output3=$( sudo find . -iname "*.css")
output4=$( sudo find . -iname "*php*")
if [ -z "$output1" ] 
then echo -e "${RED}[!]HTML  not found ${NC}"
else echo -e "${GREEN}[+]HTML was found:${NC} \n$output1 "
fi
if [ -z "$output2" ] 
then echo -e "${RED}[!]Javascript  not found ${NC}"
else echo -e "${GREEN}[+]Javascript was found:${NC} \n$output2 "
fi
if [ -z "$output3" ] 
then echo -e "${RED}[!]CSS-style  not found ${NC}"
else echo -e "${GREEN}[+]CSS-style was found:${NC} \n$output3 "
fi                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
if [ -z "$output4" ] 
then echo -e "${RED}[!]PHP  not found ${NC}"
else echo -e "${GREEN}[+]PHP was found:${NC} \n$output4 "
fi
echo -e "${YELLOW} [*]Attempting to find drivers: ${NC}"
output1=$(sudo find -iname "*.ko")
if [ -z "$output1" ]
then echo -e "${RED}[-]Drivers not found${NC}"
else echo -e "${GREEN}[+]Drivers were found!Check Firmware/DriversList.txt ${NC}"; echo "$output1" > ../DriversList.txt
fi

echo -e "${YELLOW}[*]Attempting to find symbol table"
while IFS= read -r line
do
  output2=$( sudo find -iname "$line")
  if [ -z "$output2" ]
  then echo -e "${YELLOW} Check $line... ${NC}"
  else echo -e "${GREEN}[+] $line was found: ${NC} \n$output2"; break
  fi 
done < ../../SymbolTable.txt

exit
