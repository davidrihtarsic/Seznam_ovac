#! /bin/bash

help(){
echo "DECRIPTION:\n
Program je namenjen pregledovanju seznama ovac.\n
Možno je beležiti prevzem ovac in stanje prevzema\n
za posameznega lastnika."
echo "PARAMETERS:"
echo " -h izpiše tole pomoč"
echo " -f ime datoteke"
echo "EXAMPLE:\n
prevzem_ovac_xl.sh -f ovce_test.csv"
echo "USAGE:\n
⏎       - iskanje niza\n
h       - izpiše tole pomoč\n
d       - izbriše označbo iskani niz\n
n       - New = dodaj nov vnos
e       - Edit = spremeni vnos
ctrl-a  - izberi vse
t       - run test\n
q       - quit\n
-----------------"
}

while getopts "hf:" option; do
   case $option in
      h) help && exit ;;
      f) INPUT_FILE=$OPTARG;;
   esac
done

[ -z $INPUT_FILE ] && INPUT_FILE="ovce_test.csv"

STEVILKA_OVCE=""
NAJDEN_VNOS_OVCE=""
LASTNIK_OVCE=""
SE_KOLIKO_OVAC=""
ST_ZADETKOV=""
VSEH_NJEGOVIH_OVAC=""
NJEGOVE_DOBLJENE_OVCE=""
MANJKAJOCE_OVCE=""

poisci_zadetke(){
  NAJDEN_VNOS_OVCE=$(fzf -m --bind ctrl-a:toggle-all <$INPUT_FILE)
  ST_ZADETKOV=$(echo "$NAJDEN_VNOS_OVCE" | sed '/^$/d' | wc -l )
  LASTNIK_OVCE=$(echo "$NAJDEN_VNOS_OVCE" | head -1 | awk -F, '{print $2}')
  STEVILKA_OVCE=$(echo "$NAJDEN_VNOS_OVCE" | head -1 | awk -F, '{print $1}')
}

oznaci_ovco_dobljena(){
  echo $NAJDEN_VNOS_OVCE
  OVCA_ZE_VZETA=$(grep -P "$STEVILKA_OVCE" ./$INPUT_FILE |grep "OK" | wc -l)
  if [ $OVCA_ZE_VZETA -gt 0 ]
  then
    echo "ŽE VZETA"
  else
    sed -i "/$STEVILKA_OVCE/ s/.*$/&,OK/" ./$INPUT_FILE
    echo "OK .. VOZI"
  fi
  quick_info
}

izbrisi_oznacbo(){
  poisci_zadetke
  if [ $ST_ZADETKOV -eq 1 ]
  then
    echo $NAJDEN_VNOS_OVCE
    sed -i "/$STEVILKA_OVCE/ s/,OK//" ./$INPUT_FILE
    echo "Izbris prevzema"
    quick_info
  else
    echo "Err: Nismo našli točno ENEGA zadetka. Izbris označbe ni mogoče izvesti."
  fi
}

quick_info(){
  [ $ST_ZADETKOV -eq 1 ] && ISKANI_NIZ=$LASTNIK_OVCE
  VSEH_NJEGOVIH_OVAC=$(echo "$NAJDEN_VNOS_OVCE" | grep [0-9] | wc -l)
  NJEGOVE_DOBLJENE_OVCE=$(echo "$NAJDEN_VNOS_OVCE" | grep [0-9] | grep "OK" | wc -l )
  MANJKAJOCE_OVCE=$(echo "$NAJDEN_VNOS_OVCE" | grep [0-9] | grep -v "OK" | wc -l)
  echo "      [ $NJEGOVE_DOBLJENE_OVCE 👍 + $MANJKAJOCE_OVCE 🔍 = $VSEH_NJEGOVIH_OVAC 🐑]"
}

obdelaj_podatke(){
  poisci_zadetke
  [ $ST_ZADETKOV -eq 0 ] && echo "Ni podatka"
  [ $ST_ZADETKOV -eq 1 ] && oznaci_ovco_dobljena
  [ $ST_ZADETKOV -gt 1 ] && echo "Št.zadetkov: $ST_ZADETKOV" && echo "$NAJDEN_VNOS_OVCE" | column -t -s ',' && quick_info
}

nov_vnos(){
  echo "Vnesi vrstico s podatki."
  echo "Podatke loči z vejico, npr:"
  echo "12345,RIHTARŠIČ JANEZ,pogin"
  echo "---------------------------"
  NASLOVNA_VRSTICA=$(grep -v [0-9] ./$INPUT_FILE | head -n 1)
  echo $NASLOVNA_VRSTICA
  echo -n "> "
  read VNOS_PODATKOV
  echo $VNOS_PODATKOV >> ./$INPUT_FILE
  echo "--= Dodano v: $INPUT_FILE =--"
  echo "..."
  tail -5 ./$INPUT_FILE
  echo "---------------------------"
}

uredi_podatek(){
  poisci_zadetke
  if [ $ST_ZADETKOV -eq 1 ]
  then
    echo "Spremeni vrstico:"
    echo "--------------------------------"
    read -e -p "> " -i "$NAJDEN_VNOS_OVCE" POPRAVEK
    echo "--------------------------------"
    sed -i "s/$NAJDEN_VNOS_OVCE/$POPRAVEK/" ./$INPUT_FILE
    grep -B 2 -A 2 "$POPRAVEKA" ./$INPUT_FILE
    echo "--------------------------------"
  else
    echo "Err: Nismo našli točno ENEGA zadetka."
  fi

}

test_and_debug(){
  ISKANI_NIZ=""
  echo "obdelaj_podatke() ISKANI_NIZ=$ISKANI_NIZ"
  obdelaj_podatke
  echo "----------------------"

  ISKANI_NIZ="JUREJEVČIČ"
  echo "obdelaj_podatke() ISKANI_NIZ=$ISKANI_NIZ"
  obdelaj_podatke
  echo "----------------------"

  ISKANI_NIZ="NOVAK"
  echo "obdelaj_podatke() ISKANI_NIZ=$ISKANI_NIZ"
  obdelaj_podatke
  echo "----------------------"

  ISKANI_NIZ="RIHTARŠIČ"
  echo "prikaži ovce za RIHTARŠIČ ISKANI_NIZ=$ISKANI_NIZ"
  obdelaj_podatke
  #debug
  echo "NAJDEN_VNOS_OVCE=$NAJDEN_VNOS_OVCE"
  echo "ST_ZADETKOV=$ST_ZADETKOV"
  echo "LASTNIK_OVCE=$LASTNIK_OVCE"
  echo "----------------------"

  echo "najdi ovco ISKANI_NIZ=190500"
  ISKANI_NIZ="190500"
  obdelaj_podatke
  echo "----------------------"

  ISKANI_NIZ="RIHTARŠIČ"
  echo "prikaži ovce za RIHTARŠIČ ISKANI_NIZ=$ISKANI_NIZ"
  obdelaj_podatke
  echo "----------------------"

  ISKANI_NIZ="190500"
  echo "odstrani oznacbo ovce ISKANI_NIZ=$ISKANI_NIZ"
  izbrisi_oznacbo
  echo "----------------------"
  
  ISKANI_NIZ="RIHTARŠIČ"
  echo "prikaži ovce za RIHTARŠIČ ISKANI_NIZ=$ISKANI_NIZ"
  obdelaj_podatke
  echo "----------------------"

  ISKANI_NIZ="500,jan"
  echo "iskanje MaleVElikE ISKANI_NIZ=$ISKANI_NIZ"
  obdelaj_podatke
  echo "----------------------"
  ISKANI_NIZ="500,jan"
  echo "izbrisi MaleVElikE ISKANI_NIZ=$ISKANI_NIZ"
  izbrisi_oznacbo
  echo "----------------------"
}

help
while :
  do
    echo -n "> "
    read CMD
    case $CMD in
      q) break ;;
      h) help ;;
      t) test_and_debug ;;
      d) izbrisi_oznacbo ;;
      n) nov_vnos ;;
      e) uredi_podatek ;;
      *) obdelaj_podatke ;;
    esac
  done
