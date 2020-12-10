#!/bin/bash
# Jadach Dominika


COLOR_RED='\e[1;31m'
COLOR_WHITE='\u001b[0m'

phonebook="./phonebook.csv"


for arg in $@;
do
  if [[ $2 == -f ]];
  then
    if [[ ! $3 ]];
    then
      echo "Działasz na pliku innym niz domyslny, wpisz jako trzeci arg jego nazwe. "
      exit
    else
      phonebook="./$3.csv"
    fi
  fi
done


function Help(){
  echo ''
  printf "${COLOR_RED}Witaj "$(whoami)" ! ${COLOR_WHITE}\n"
  echo 'Skrypt ten sluzy do tworzenia i obslugi kontaktow w ksiazce telefonicznej.'
  echo 'Jest ona zapisywana w pliku phonebook.csv i zawiera nastepujace informacje: '
  echo 'id kontaktu, nazwa, numer telefonu, kategoria, opis. '
  echo 'Autor: Dominika Jadach'
  echo 'Mozliwe dzialania: '
  echo '--add        umozliwia dodanie kontaktu, '
  echo '--remove     umozliwia usuniecie konkretnego kontaktu z ksiazki, '
  echo '--removeall  usuwa wszystkie kontakty z listy, '
  echo '--list       wypisuje liste wszystkich kontaktow, '
  echo '--edit       umozliwia edycje danego kontaktu. '
  echo 'Aby zaczac uruchom skrypt z odpowiednim argumentem.'
  echo 'Domyslnie tworzony plik z ksiazka telefoniczna to phonebook.csv.'
  echo 'Jezeli chcesz dodac/ operowac na kontaktach z innego pliku dopisz do odpowiedniego'
  echo ' z powyzszych argumentow "-f nazwa" wedlug ponizszego przykladu dla pliku kontakty_z_pracy.csv: '
  echo './DominikaJadach-phonebook.sh --add -f kontakty_z_pracy'
  echo ''
}


if ! type sed >/dev/null 2>&1;
then
  echo 'Blad sad.'
  exit 0
fi


for arg in $@;
do
	if [[ $arg =~ --help$ ]];
	then
		Help
		exit 0
	fi
done


# jako argument jest podawane poszukiwane id (przy edycji, usuwaniu)
function ifExists(){
  if ! [ -f $phonebook ];
  then
    return 1
  fi

  while read -r line
  do
    if [[ "$line" =~ ^$1,.* ]];
    then
      return 0
    fi
  done < "$phonebook"
  return 1
}


function endingId(){
  declare -i endingId=1

  if ! [ -f $phonebook ];
  then
    echo $endingId
    return
  fi

  endingLine=$(tail -1 $phonebook)
  endingId=$(cut -d ',' -f 1 <<< "$endingLine")
  echo $((endingId+1))
}


function add(){
  printf "Biezacy plik: $phonebook \n"
  echo ""
  echo 'Dodajesz kontakt. Wpisz nazwe: '
  read name

  echo ""
  echo 'Wpisz numer: '
  read phoneNumber

  if [[ $phoneNumber ]] && [ $phoneNumber -eq $phoneNumber 2>/dev/null ];
  then
    echo ""
  else
    echo "Ej... przeciez wiesz, ze to nie numer, podaj poprawny."
    read phoneNumber
    if [[ $phoneNumber ]] && [ $phoneNumber -eq $phoneNumber 2>/dev/null ];
    then
      echo "OK, udalo sie za drugim razem."
      echo ""
    else
      echo "Nie wspolpracujesz, podany numer nie jest poprawny. Nieudane dodawanie kontaktu."
      return
    fi
  fi

  echo 'Wybierz, do jakiej kategorii chcesz go przyporzadkowac: '
  echo '1) sluzbowy'
  echo '2) prywatny'
  echo '3) inny'
  read category
  case "$category" in
    "1") group="sluzbowy";;
    "2") group="prywatny";;
    "3") group="inny";;
    *)  group=""
        printf "Brak kategorii. Zawsze mozesz ja dodac edytujac kontakt. \n";;
  esac

  echo ""
  echo 'Dodaj opis: '
  read description

  echo ""
  id=$(endingId)
  echo $id,$name,$phoneNumber,$group,$description >>$phonebook
  echo 'Dodano kontakt! Liste kontaktow mozesz sprawdzic uruchamiajac skrypt z arg --list '
}


function remove(){
  printf "Biezacy plik: $phonebook \n"
  if ! [ -s $phonebook ];
  then
    echo 'Brak kontaktow. Nie ma co usuwac. '
    return 0
  fi

  echo 'Ktory kontakt chcesz usunac? Podaj jego id. '
  read id

  if ifExists $id;
  then
    sed -i "/^$id/d" $phonebook
    echo 'Kontakt zostal usuniety. '

  else
    echo 'Kontakt o podanym id nie istnieje, mozesz sprawdzic liste kontaktow uzywajac arg --list '
  fi
}


function removeall(){
  printf "Biezacy plik: $phonebook \n"

  if ! [ -s $phonebook ];
  then
    echo "Brak kontaktow. Nie ma co usuwac. "
    return 0
  fi

  >$phonebook
  echo 'Usunieto wszystkie kontakty. '
}


function list(){
  printf "Biezacy plik: $phonebook \n"

  if ! [ -s $phonebook ];
  then
    echo "Brak kontaktow. "
    return 0
  fi

  echo "Dane kontaktow wypisane w ponizszej kolejnosci: "
  echo ""
  echo "ID, nazwa, numer, kategoria, opis "
  echo "--------------------------------- "
  while IFS=, read -r id name phoneNumber group description
  do
    printf "$id, $name, $phoneNumber, $group, $description \n"
  done < "$phonebook"
}


function isOne(){
  numb=$(cat $phonebook | wc -l)

  if [ $numb == 1 ];
  then
    return 1
  else
    return 0
  fi
}


function edit(){
  printf "Biezacy plik: $phonebook \n"

  if ! [ -s $phonebook ];
  then
    echo 'Brak kontaktow. Nie ma co edytowac. '
    return 0
  fi

  if ! isOne;
  then
    printf "Nie masz wielkiego wyboru, w Twojej ksiazce znajduje sie jeden kontakt:\n"
    while IFS=, read -r id name phoneNumber group description
    do
      declare ids=$id
    done < "$phonebook"
  else
    echo 'Ktory kontakt chcesz edytowac? Podaj jego id: '
    read ids
  fi

  if ifExists $ids;
  then
    echo "Co chcesz edytowac? Wybierz odpowiednia akcje: "
    echo "1) Zmiana nazwy "
    echo "2) Zmiana numeru "
    echo "3) Zmiana kategorii "
    echo "4) Zmiana opisu "
    read selection

    if [ $selection -eq "1" ];
    then
      echo "Nowa nazwa: "
      read newName
      sed -i -E "s/^$ids,(.*),(.*),(.*),(.*)/$ids,$newName,\2,\3,\4/" $phonebook
      echo "Zmieniono nazwe. "

    elif [ $selection -eq "2" ];
    then
      echo "Nowy numer: "
      read newNumber

      if [[ $newNumber ]] && [ $newNumber -eq $newNumber 2>/dev/null ];
        then
          echo ""
        else
          echo "Ej... przeciez wiesz, ze to nie numer, podaj poprawny, zeby edytowac."
          read newNumber
          if [[ $newNumber ]] && [ $newNumber -eq $newNumber 2>/dev/null ];
          then
            echo "OK, udalo sie za drugim razem."
            echo ""
          else
            echo "Nie wspolpracujesz, podany numer nie jest poprawny. Nieudane edytowanie kontaktu."
            return
          fi
        fi

      sed -i -E "s/^$ids,(.*),(.*),(.*),(.*)/$ids,\1,$newNumber,\3,\4/" $phonebook
      echo "Zmieniono numer. "

    elif [ $selection -eq "3" ];
    then
      echo "Wybierz nowa kategorie "
      echo '1) sluzbowy '
      echo '2) prywatny '
      echo '3) inny '
      read category
      case "$category" in
        "1") group="sluzbowy";;
        "2") group="prywatny";;
        "3") group="inny";;
        *)  group=""
      printf "Brak kategorii. \n";;
      esac
      sed -i -E "s/^$ids,(.*),(.*),(.*),(.*)/$ids,\1,\2,$group,\4/" $phonebook

    elif [ $selection -eq "4" ];
    then
      echo "Nowy opis: "
      read newDescription
      sed -i -E "s/^$ids,(.*),(.*),(.*),(.*)/$ids,\1,\2,\3,$newDescription/" $phonebook

    else
      echo "Cos Ci sie pomylilo, mozliwe wybory to 1, 2, 3 lub 4. "
    fi
  else
    echo "Kontakt o podanym id nie istnieje, mozesz sprawdzic liste kontaktow uzywajac arg --list "
  fi
}


function optionsToChoose(){
  echo ''
  printf "${COLOR_RED}Nieznany argument!${COLOR_WHITE} \n"
  echo 'Oto te, ktore znam: '
  echo '--add '
  echo '--remove '
  echo '--removeall '
  echo '--list '
  echo '--edit '
}


for arg in $1;
do
  case $arg in
    --add)
      add;;
    --remove)
      remove;;
    --removeall)
      removeall;;
    --list)
      list;;
    --edit)
      edit;;
    *)
      optionsToChoose;;
  esac
done
