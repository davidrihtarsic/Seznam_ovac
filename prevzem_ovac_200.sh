#! /bin/bash

help(){
echo "DECRIPTION:
  Program je namenjen pregl-
  edovanju seznama ovac.
  Možno je beležiti prevzem
  ovac in stanje prevzema
  za posameznega lastnika.
PARAMETERS:
  -h izpiše tole pomoč
  -f ime datoteke
EXAMPLE:
  prevzem_ovac_xl.sh -f ovce_test.csv
USAGE:
  ⏎       - iskanje niza
  h       - izpiše tole pomoč
  ctrl-a  - izberi vse
  t       - run test
  q       - quit

  Nekaj načinov uporabe:
  1. Takoj na začetku priti-
    snemo tipko ENTER
    in pričneš tipkati:
    > ⏎ 
    > RIH 500 <⏎ 
    in dobiš Čoho.
    Nato še enkrat pritisnemo ⏎
    in ovca se zabeleži kot
    'Prevzeta'.
  2. Iskalni niz lahko vnesemo
    takoj na začetku:
    >RIH⏎ 
    in dobiš vse ovce, ki jih
    imamo z nekaj statistike:
    [ 2 👍 + 7 🔍 = 9 🐑]
  3. Lahko najdemo tudi vrstice
    iz tabele, ki izključujejo
    isani niz. Naprimer, da
    želimo poizkati vse, ki
    NISO Prevzete:
    > ⏎ 
    > !Prevz < 
    in dobimo vse ovce, ki še
    niso Prevzete = manjkajo.
  "
}
# najprej naj da izbor ovac
# če jih je več naj izpiše poročilo
# če je ena naj ponudi možnosti obdelave [Prevzem,Edit,New,Delete]

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

izberi_podatke_iz_baze(){
  if [ -z $ISKANI_NIZ ]
  then
    NAJDEN_VNOS_OVCE=$(fzf -m --bind ctrl-a:toggle-all <$INPUT_FILE)
  else
    NAJDEN_VNOS_OVCE=$(grep -i -P "$ISKANI_NIZ" $INPUT_FILE)
  fi
  ST_ZADETKOV=$(echo "$NAJDEN_VNOS_OVCE" | sed '/^$/d' | wc -l )
  LASTNIK_OVCE=$(echo "$NAJDEN_VNOS_OVCE" | head -1 | awk -F, '{print $2}')
  STEVILKA_OVCE=$(echo "$NAJDEN_VNOS_OVCE" | head -1 | awk -F, '{print $1}')
}

obdelava_podatka(){
  echo "--------------------"
  echo "$NAJDEN_VNOS_OVCE"
  echo "[P]revzem/[e]dit/[n]ew/"
  read -e -p "[d]elete/[c]ancle: " CMD
  case $CMD in
    p|P|"") prevzem_ovce ;;
    e) uredi_podatek ;;
    d) izbrisi_oznacbo ;;
    n) nov_vnos ;;
    c) quick_info ;;
    *) echo "Napačen vnos" && obdelava_podatka ;;
  esac
}
prevzem_ovce(){
  OVCA_ZE_VZETA=$(grep -P "$STEVILKA_OVCE" ./$INPUT_FILE |grep "Prevzeta" | wc -l)
  if [ $OVCA_ZE_VZETA -gt 0 ]
  then
    echo "ŽE VZETA"
  else
    sed -i "/$STEVILKA_OVCE/ s/.*$/&,Prevzeta/" ./$INPUT_FILE
    echo "OK .. VOZI"
  fi
  quick_info
}

izbrisi_oznacbo(){
  sed -i "/$STEVILKA_OVCE/ s/,Prevzeta//" ./$INPUT_FILE
  echo "Izbris prevzema"
  quick_info
}

quick_info(){
  [ $ST_ZADETKOV -eq 1 ] && NAJDEN_VNOS_OVCE=$(grep [0-9] ./$INPUT_FILE | grep -i -P "$LASTNIK_OVCE")
  VSEH_NJEGOVIH_OVAC=$(echo "$NAJDEN_VNOS_OVCE" | wc -l)
  NJEGOVE_DOBLJENE_OVCE=$(echo "$NAJDEN_VNOS_OVCE" | grep "Prevzeta" | wc -l )
  MANJKAJOCE_OVCE=$(echo "$NAJDEN_VNOS_OVCE" | grep -v "Prevzeta" | wc -l)
  echo "      [ $NJEGOVE_DOBLJENE_OVCE 👍 + $MANJKAJOCE_OVCE 🔍 = $VSEH_NJEGOVIH_OVAC 🐑]"
}

prikazi_podatke(){
  izberi_podatke_iz_baze
  [ $ST_ZADETKOV -eq 0 ] && echo "Ni podatka"
  [ $ST_ZADETKOV -eq 1 ] && obdelava_podatka
  [ $ST_ZADETKOV -gt 1 ] && echo "Št.zadetkov: $ST_ZADETKOV" && echo "$NAJDEN_VNOS_OVCE" | column -t -s ',' && quick_info
}

nov_vnos(){
  echo "Vnesi vrstico s podatki."
  echo "Podatke loči z vejico, npr:"
  echo "12345,RIHTARŠIČ JANEZ,pogin"
  echo "---------------------------"
  NASLOVNA_VRSTICA=$(grep -v [0-9] ./$INPUT_FILE | head -n 1)
  echo $NASLOVNA_VRSTICA
  read -e -p "> " -i "$NAJDEN_VNOS_OVCE" VNOS_PODATKOV
  sed -i "/$NAJDEN_VNOS_OVCE/a $VNOS_PODATKOV" ./$INPUT_FILE
  #echo $VNOS_PODATKOV >> ./$INPUT_FILE
  echo "--= Dodano v: $INPUT_FILE =--"
  echo "..."
  grep -B 2 -A 2 "$VNOS_PODATKOV" ./$INPUT_FILE
}

uredi_podatek(){
  read -e -p "> " -i "$NAJDEN_VNOS_OVCE" POPRAVEK
  sed -i "s/$NAJDEN_VNOS_OVCE/$POPRAVEK/" ./$INPUT_FILE
  #grep -B 2 -A 2 "$POPRAVEK" ./$INPUT_FILE
}

test_and_debug(){
  ISKANI_NIZ=""
  echo "prikazi_podatke() ISKANI_NIZ=$ISKANI_NIZ"
  prikazi_podatke
  echo "Test complet. Press ENTER.";read;

  ISKANI_NIZ="JUREJEVČIČ"
  echo "prikazi_podatke() ISKANI_NIZ=$ISKANI_NIZ"
  prikazi_podatke
  echo "Test complet. Press ENTER";read;

  ISKANI_NIZ="NOVAK"
  echo "prikazi_podatke() ISKANI_NIZ=$ISKANI_NIZ"
  prikazi_podatke
  echo "Test complet. Press ENTER";read;

  ISKANI_NIZ="RIHTARŠIČ"
  echo "test spremenljivk za ISKANI_NIZ=$ISKANI_NIZ"
  prikazi_podatke
  #debug
  echo "NAJDEN_VNOS_OVCE=$NAJDEN_VNOS_OVCE"
  echo "ST_ZADETKOV=$ST_ZADETKOV"
  echo "LASTNIK_OVCE=$LASTNIK_OVCE"
  echo "Test complet. Press ENTER";read;

  echo "najdi ovco ISKANI_NIZ=190500"
  ISKANI_NIZ="190500"
  prikazi_podatke
  echo "Test complet. Press ENTER";read;

  ISKANI_NIZ="RIHTARŠIČ"
  echo "prikaži ovce za RIHTARŠIČ ISKANI_NIZ=$ISKANI_NIZ"
  prikazi_podatke
  echo "Test complet. Press ENTER";read;

  ISKANI_NIZ="190500"
  echo "odstrani oznacbo ovce ISKANI_NIZ=$ISKANI_NIZ"
  izbrisi_oznacbo
  echo "Test complet. Press ENTER";read;

  ISKANI_NIZ="RIHTARŠIČ"
  echo "prikaži ovce za RIHTARŠIČ ISKANI_NIZ=$ISKANI_NIZ"
  prikazi_podatke
  echo "Test complet. Press ENTER";read;

  ISKANI_NIZ="500,jan"
  echo "iskanje MaleVElikE ISKANI_NIZ=$ISKANI_NIZ"
  prikazi_podatke
  echo "Test complet. Press ENTER";read;
  ISKANI_NIZ="500,jan"
  echo "izbrisi MaleVElikE ISKANI_NIZ=$ISKANI_NIZ"
  izbrisi_oznacbo
  echo "Test complet. Press ENTER";read;
}

help
while :
  do
    echo "----------------------"
    echo -n "> "
    read CMD
    case $CMD in
      q) break ;;
      h) help ;;
      t) test_and_debug ;;
      *) ISKANI_NIZ=$CMD;
        prikazi_podatke ;;
    esac
  done
