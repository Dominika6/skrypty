#!/usr/bin/python3
# Jadach Dominika - projekt zaliczeniowy - grupa 1


import sys
import os.path
import csv

phonebook = "./phonebook.csv"


class colors:
    MAGENTA = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'


class Phonebook:

    def Help(self):
        print(colors.YELLOW + "Skrypt ten sluzy do tworzenia i obslugi kontaktow w ksiazce telefonicznej.")
        print("Jest ona zapisywana w pliku phonebook.csv i zawiera nastepujace informacje: ")
        print("id kontaktu, nazwa, numer telefonu, kategoria, opis. " + colors.ENDC)
        print(colors.MAGENTA + "Autor: Dominika Jadach - grupa 1 " + colors.ENDC)
        print(colors.YELLOW + "Mozliwe dzialania: ")
        print("--add        umozliwia dodanie kontaktu, ")
        print("--remove     umozliwia usuniecie konkretnego kontaktu z ksiazki, ")
        print("--removeall  usuwa wszystkie kontakty z listy, ")
        print("--list       wypisuje liste wszystkich kontaktow, ")
        print("--edit       umozliwia edycje danego kontaktu. ")
        print("Aby zaczac uruchom skrypt z odpowiednim argumentem.")
        print("Domyslnie tworzony plik z ksiazka telefoniczna to phonebook.csv. ")
        print("Jezeli chcesz dodac/ operowac na kontaktach z innego pliku dopisz do odpowiedniego ")
        print(" z powyzszych argumentow '-f nazwa' wedlug ponizszego przykladu dla pliku kontakty_z_pracy.csv: ")
        print("./DominikaJadach-phonebook.py --add -f kontakty_z_pracy " + colors.ENDC)

    def ifExists(self, id):
        if os.path.isfile(phonebook):
            with open(phonebook) as csv_file:
                csv_reader = csv.reader(csv_file, delimiter=',')
                for row in csv_reader:
                    if row[0] == id:
                        return 1
        else:
            print("Szukany plik nie istnieje.")
            return 0

    def endingId(self):
        ending_id = 0
        with open(phonebook) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            for row in csv_reader:
                ending_id = row[0]
        ret = int(ending_id) + 1
        return ret

    def add(self):
        print(colors.BLUE + "Biezacy plik: " + phonebook + colors.ENDC)
        name = input(colors.YELLOW + "Dodajesz kontakt. Wpisz nazwe: " + colors.ENDC)
        number = input(colors.YELLOW + "Wpisz numer: " + colors.ENDC)
        if not number.isnumeric():
            print(colors.RED + "Ej... przeciez wiesz, ze to nie numer, podaj poprawny." + colors.ENDC)
            number = input()
            if not number.isnumeric():
                print(colors.RED + "Nie wspolpracujesz, podany numer nie jest poprawny. Nieudane dodawanie kontaktu." + colors.ENDC)
                return
            else:
                print(colors.YELLOW + "OK, udalo sie za drugim razem." + colors.ENDC)
        print(colors.YELLOW + "Wybierz, do jakiej kategorii chcesz go przyporzadkowac: ")
        print("1) sluzbowy")
        print("2) prywatny")
        print("3) inny" + colors.ENDC)
        category = input()
        if category == "1":
            group = "sluzbowy"
        elif category == "2":
            group = "prywatny"
        elif category == "3":
            group = "inny"
        else:
            print(colors.RED + "Brak kategorii. Zawsze mozesz ja dodac edytujac kontakt." + colors.ENDC)
            group = ""
        description = input(colors.YELLOW + "Dodaj opis: " + colors.ENDC)
        id = self.endingId()
        with open(phonebook, 'a+', newline='') as csv_file:
            csv_writer = csv.writer(csv_file)
            csv_writer.writerow([id, name, number, group, description])
            print(colors.YELLOW + "Dodano kontakt! Liste kontaktow mozesz sprawdzic uruchamiajac skrypt z argumentem --list." + colors.ENDC)

    def remove(self):
        print(colors.BLUE + "Biezacy plik: " + phonebook + colors.ENDC)
        if os.stat(phonebook).st_size == 0:
            print(colors.RED + "Brak kontaktow, lista jest pusta. " + colors.ENDC)
            return
        id = input(colors.YELLOW + "Ktory kontakt chcesz usunac? Podaj jego id: " + colors.ENDC)
        if self.ifExists(id):
            lines = list()
            with open(phonebook) as csv_file:
                csv_reader = csv.reader(csv_file, delimiter=',')
                for row in csv_reader:
                    lines.append(row)
                    for field in row:
                        if field == id:
                            lines.remove(row)
                            print(colors.RED + "Kontakt zostal usuniety. " + colors.ENDC)
                        else:
                            continue
            with open(phonebook, 'w') as csv_file:
                csv_writer = csv.writer(csv_file, delimiter=',')
                csv_writer.writerows(lines)
        else:
            print(colors.RED + "Kontakt o podanym id nie istnieje, mozesz sprawdzic liste kontaktow uzywajac arg --list" + colors.ENDC)

    def removeall(self):
        print(colors.BLUE + "Biezacy plik: " + phonebook + colors.ENDC)
        if os.stat(phonebook).st_size == 0:
            print(colors.RED + "Brak kontaktow, lista jest pusta. " + colors.ENDC)
            return
        f = open(phonebook, "w+")
        f.close()
        print(colors.RED + "Usunieto wszystkie kontakty." + colors.ENDC)

    def list(self):
        print(colors.BLUE + "Biezacy plik: " + phonebook + colors.ENDC)
        if os.stat(phonebook).st_size == 0:
            print(colors.RED + "Brak kontaktow, lista jest pusta. " + colors.ENDC)
            return
        with open(phonebook) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            line_count = 0
            print(colors.YELLOW + "Dane kontaktów wypisane w ponizszej kolejności: ")
            print("ID, nazwa, numer, kategoria, opis")
            print("---------------------------------" + colors.ENDC)
            for row in csv_reader:
                print(colors.GREEN + row[0], ",", row[1], ",", row[2], ",", row[3], ",", row[4] + colors.ENDC)
                line_count += 1

    def isOne(self):
        with open(phonebook) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            line_count = 0
            for _ in csv_reader:
                line_count += 1
        if line_count == 1:
            return 1
        else:
            return 0

    def edit(self):
        print(colors.BLUE + "Biezacy plik: " + phonebook + colors.ENDC)
        if os.stat(phonebook).st_size == 0:
            print(colors.RED + "Brak kontaktow, lista jest pusta. " + colors.ENDC)
            return
        if(self.isOne()):
            print(colors.YELLOW + "Nie masz wielkiego wyboru, w Twojej ksiazce znajduje sie jeden kontakt." + colors.ENDC)
            with open(phonebook) as csv_file:
                csv_reader = csv.reader(csv_file, delimiter=',')
                for row in csv_reader:
                    id = row[0]
        else:
            print(colors.YELLOW + "Ktory kontakt chcesz edytowac? Podaj jego id: " + colors.ENDC)
            id = input()
        lines = list()
        if self.ifExists(id):
            print(colors.YELLOW + "Co chcesz edytowac? Wybierz odpowiednia akcje: ")
            print("1) Zmiana nazwy")
            print("2) Zmiana numeru")
            print("3) Zmiana kategorii")
            print("4) Zmiana opisu" + colors.ENDC)
            selection = input()
        else:
            print(colors.RED + "Kontakt o podanym id nie istnieje, mozesz sprawdzic liste kontaktow uzywajac arg --list" + colors.ENDC)
            return
        if selection == "1":
            newName = input(colors.YELLOW + "Nowa nazwa: " + colors.ENDC)
            with open(phonebook) as csv_file:
                csv_reader = csv.reader(csv_file, delimiter=',')
                for row in csv_reader:
                    lines.append(row)
                    for field in row:
                        if field == id:
                            row[1] = newName
            with open(phonebook, 'w') as csv_file:
                csv_writer = csv.writer(csv_file, delimiter=',')
                csv_writer.writerows(lines)
        elif selection == "2":
            newNumber = input(colors.YELLOW + "Nowy numer: " + colors.ENDC)
            if not newNumber.isnumeric():
                print(colors.RED + "Ej... przeciez wiesz, ze to nie numer, podaj poprawny." + colors.ENDC)
                newNumber = input()
                if not newNumber.isnumeric():
                    print(colors.RED + "Nie wspolpracujesz, podany numer nie jest poprawny. Nieudane dodawanie kontaktu." + colors.ENDC)
                    return
                else:
                    print(colors.YELLOW + "OK, udalo sie za drugim razem." + colors.ENDC)
            with open(phonebook) as csv_file:
                csv_reader = csv.reader(csv_file, delimiter=',')
                for row in csv_reader:
                    lines.append(row)
                    for field in row:
                        if field == id:
                            row[2] = newNumber
            with open(phonebook, 'w') as csv_file:
                csv_writer = csv.writer(csv_file, delimiter=',')
                csv_writer.writerows(lines)
        elif selection == "3":
            print(colors.YELLOW + "Wybierz nowa kategorie: ")
            print("1) sluzbowy")
            print("2) prywatny")
            print("3) inny" + colors.ENDC)
            category = input()
            if category == "1":
                group = "sluzbowy"
            elif category == "2":
                group = "prywatny"
            elif category == "3":
                group = "inny"
            else:
                group = ""
                print(colors.RED + "Brak kategorii. Zawsze mozesz ja dodac edytujac kontakt." + colors.ENDC)
            with open(phonebook) as csv_file:
                csv_reader = csv.reader(csv_file, delimiter=',')
                for row in csv_reader:
                    lines.append(row)
                    for field in row:
                        if field == id:
                            row[3] = group
            with open(phonebook, 'w') as csv_file:
                csv_writer = csv.writer(csv_file, delimiter=',')
                csv_writer.writerows(lines)
        elif selection == "4":
            newDescription = input(colors.YELLOW + "Nowy opis: " + colors.ENDC)
            with open(phonebook) as csv_file:
                csv_reader = csv.reader(csv_file, delimiter=',')
                for row in csv_reader:
                    lines.append(row)
                    for field in row:
                        if field == id:
                            row[4] = newDescription
            with open(phonebook, 'w') as csv_file:
                csv_writer = csv.writer(csv_file, delimiter=',')
                csv_writer.writerows(lines)
        else:
            print(colors.RED + "Cos Ci sie pomylilo, mozliwe wybory to 1, 2, 3 lub 4." + colors.ENDC)
            return

    def optionsToChoose(self):
        print(colors.RED + "Nieznany argument! ")
        print("Oto te, ktore znam:")
        print("--add ")
        print("--remove ")
        print("--removeall ")
        print("--list ")
        print("--edit " + colors.ENDC)


book = Phonebook()

if len(sys.argv) == 3:
    print("Jezeli chcesz dzialac na pliku innym niz domyslny, wpisz jako trzeci arg jego nazwe.")

elif len(sys.argv) == 4:
    if sys.argv[2] == "-f":
        phonebook = "./" + sys.argv[3] + ".csv"

if len(sys.argv) > 1 and sys.argv[1] == "--help":
    Phonebook.Help(book)
elif len(sys.argv) > 1 and sys.argv[1] == "--add":
    Phonebook.add(book)
elif len(sys.argv) > 1 and sys.argv[1] == "--remove":
    Phonebook.remove(book)
elif len(sys.argv) > 1 and sys.argv[1] == "--removeall":
    Phonebook.removeall(book)
elif len(sys.argv) > 1 and sys.argv[1] == "--list":
    Phonebook.list(book)
elif len(sys.argv) > 1 and sys.argv[1] == "--edit":
    Phonebook.edit(book)
else:
    Phonebook.optionsToChoose(book)
    exit(0)
