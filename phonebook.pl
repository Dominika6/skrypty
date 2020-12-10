#!/usr/bin/perl -w
# Jadach Dominika


use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use Term::ANSIColor qw(:constants);


my $phonebook = "./phonebook.csv";


if( defined($ARGV[1]) && !defined($ARGV[2])){
	print "Jeżeli chcesz działac na pliku innym niz domyslny, wpisz jako trzeci arg jego nazwe. \n";
}

if( defined($ARGV[1]) && defined($ARGV[2])) {
	if ($ARGV[1] eq "-f") {
		$phonebook = "./$ARGV[2].csv"
	}
}


sub Help{
	print " \n";
	print YELLOW "Skrypt ten sluzy do tworzenia i obslugi kontaktów w ksiazce telefonicznej.\n";
	print "Jest ona zapisywana w pliku phonebook.csv i zawiera nastepujace informacje: \n";
	print "id kontaktu, nazwa, numer telefonu, kategoria, opis. \n", RESET;
	print MAGENTA"Autor: Dominika Jadach\n" , RESET;
	print YELLOW "Mozliwe dzialania: \n";
	print "--add        umozliwia dodanie kontaktu, \n";
	print "--remove     umozliwia usuniecie konkretnego kontaktu z ksiazki, \n";
	print "--removeall  usuwa wszystkie kontakty z listy, \n";
	print "--list       wypisuje liste wszystkich kontaktow, \n";
	print "--edit       umozliwia edycje danego kontaktu. \n";
	print "Aby zaczac uruchom skrypt z odpowiednim argumentem.\n";
	print "Domyslnie tworzony plik z ksiazka telefoniczna to phonebook.csv. \n";
	print "Jezeli chcesz dodac/ operowac na kontaktach z innego pliku dopisz do odpowiedniego \n";
	print " z powyzszych argumentow '-f nazwa' wedlug ponizszego przykladu dla pliku kontakty_z_pracy.csv: \n";
	print "./DominikaJadach-phonebook.pl --add -f kontakty_z_pracy \n", RESET;
}


foreach my $arg(@ARGV){
	if($arg eq "--help"){
		Help();
		exit 0;
	}
}


sub ifExists{
	my $id = shift;
	if(-e $phonebook){
		if(open(my $FH, '<', $phonebook)){
			while(my $row = <$FH>){
				chomp $row;
				my @phonebook = split(',', $row);
				if($phonebook[0] eq $id){
					return 1;
				}
			}
			close($FH);
			return 0;
		}
		else{
			print "Problem z otwarciem pliku. \n";
		}
	}
	else{
		print "Szukany plik nie istnieje. \n";
	}
}


sub endingId{
	if(open(my $FH, '<', $phonebook)){
		my $endingLine = "0";
		$endingLine = $_ while <$FH>;
		my @last = split(',', $endingLine);
		close($FH);
		return $last[0];
	}
	else{
		return "0"
	}
}


sub add{
	print BLUE "Biezacy plik: $phonebook \n", RESET;

	print YELLOW "Dodajesz kontakt. Wpisz nazwę: \n", RESET;
	my $name = <STDIN>;

	print YELLOW "Wpisz numer: \n", RESET;
	my $phoneNumber = <STDIN>;
	if (!looks_like_number($phoneNumber)){
		print RED "Ej... przeciez wiesz, ze to nie numer, podaj poprawny.\n", RESET;
		$phoneNumber = <STDIN>;
		if (looks_like_number($phoneNumber)) {
			print YELLOW "OK, udalo sie za drugim razem. \n", RESET;
		}else {
			print RED "Nie wspolpracujesz, podany numer nie jest poprawny. Nieudane dodawanie kontaktu.\n", RESET;
			exit;
		}
	}

	print YELLOW "Wybierz, do jakiej kategorii chcesz go przyporzadkowac: \n";
	print "1) sluzbowy \n";
	print "2) prywatny \n";
	print "3) inny \n", RESET;
	my $category = <STDIN>;
	my $group;
	if(!looks_like_number($category)){
		print RED "Brak kategorii. Zawsze mozesz ja dodac edytujac kontakt. \n", RESET;
		$group="";
	}else{
		if($category == 1){ $group="sluzbowy"}
		elsif($category == 2){ $group="prywatny"}
		elsif($category == 3){ $group="inny"}
		else{
			print RED "Brak kategorii. Zawsze mozesz ja dodac edytujac kontakt. \n", RESET;
			$group="";
		}
	}

	print YELLOW "Dodaj opis: \n", RESET;
	my $description = <STDIN>;

	my $id = endingId();
	chomp $id;
	chomp $name;
	chomp $phoneNumber;
	chomp $group;
	chomp $description;

	my $newid = $id + 1;

	if(open(my $FH, '>>', $phonebook)){
		print $FH "$newid,";
		print $FH "$name,";
		print $FH "$phoneNumber,";
		print $FH "$group,";
		print $FH "$description\n";
		print YELLOW "Dodano kontakt! Liste kontaktow mozesz sprawdzic uruchamiajac skrypt z argumentem --list. \n", RESET;
	}
	else{
		print RED "Problem z otwarciem pliku. \n", RESET;
	}
}


sub remove{
	print BLUE "Biezacy plik: $phonebook \n", RESET;
	if(! -z $phonebook){
		print YELLOW "Ktory kontakt chcesz usunac? Podaj jego id: \n", RESET;
		my $id = <STDIN>;
		chomp $id;

		if(ifExists($id)){
			open (FILE, "<$phonebook");
			my @PHONEBOOK = <FILE>;
			close(FILE);
			open(FILE, ">$phonebook");
			foreach my $CONTACT (@PHONEBOOK) {
				print FILE $CONTACT unless($CONTACT =~ m/^$id,/);
			}
			close(FILE);
			print RED "Kontakt zostal usuniety. \n", RESET;
		}
		else{
			print RED "Kontakt o podanym id nie istnieje, mozesz sprawdzic liste kontaktow uzywajac arg --list  \n", RESET;
		}
	}
	else{
		print RED "Brak kontaktow w ksiazce. Nie ma co usuwac. \n", RESET;
		exit 0;
	}
}


sub removeall{
	print BLUE "Biezacy plik: $phonebook \n", RESET;
	if(! -z $phonebook){
		open(my $FH, '>', $phonebook);
		print RED "Usunieto wszystkie kontakty. \n", RESET;
	}
	else{
		print RED "Brak kontaktow. \n", RESET;
	}
}


sub list{
	print BLUE "Biezacy plik: $phonebook \n", RESET;
	if(-z $phonebook){
		print RED "Brak kontaktow, lista jest pusta. \n", RESET;
	}else{
		if(open(my $FH, '<', $phonebook)){
			print YELLOW "Dane kontaktów wypisane w ponizszej kolejności: \n";
			print "ID, nazwa, numer, kategoria, opis \n";
			print "--------------------------------- \n", RESET;
			while(my $row = <$FH>){
				chomp $row;
				my @contact = split(',', $row);
				print GREEN" $contact[0], $contact[1], $contact[2], $contact[3], $contact[4] \n", RESET;
			}
			close($FH);
		}
	}
}


sub isOne{
	my $line;
	my $lines = 1;
	open(my $fh, '<', $phonebook) or die "Nie da się otworzyc pliku: $phonebook: $!";
	$line = <$fh>;
	$lines++ while <$fh>;
	close $fh;

	if ($lines eq 1){
		return 1;
	}
	else {
		return 0;
	}
}


sub edit{
	print BLUE "Biezacy plik: $phonebook \n", RESET;

	my $id = 0;
	if(-z $phonebook){
		print RED "Brak kontaktow, lista jest pusta. \n", RESET;
	}
	else{
		if(isOne){
			print YELLOW "Nie masz wielkiego wyboru, w Twojej ksiazce znajduje sie jeden kontakt. \n", RESET;
			if(open(my $FH, '<', $phonebook)){
				while(my $row = <$FH>){
					chomp $row;
					my @contact = split(',', $row);
					$id = $contact[0];
				}
				close($FH);
			}
		}
		else {
			print YELLOW "Ktory kontakt chcesz edytowac? Podaj jego id: \n", RESET;
			$id = <STDIN>;
			chomp $id;
		}

		if(ifExists($id)){
			print YELLOW "Co chcesz edytowac? Wybierz odpowiednia akcje: \n";
			print "1) Zmiana nazwy \n";
			print "2) Zmiana numeru \n";
			print "3) Zmiana kategorii \n";
			print "4) Zmiana opisu \n", RESET;
			my $selection = <STDIN>;

			if($selection == 1){
				print YELLOW "Nowa nazwa: \n", RESET;
				my $newName = <STDIN>;
				chomp $newName;
				open(FILE, "<$phonebook");
				my @PHONEBOOK = <FILE>;
				close(FILE);
				open(FILE, ">$phonebook");
				foreach my $PHONOBOOK (@PHONEBOOK) {
					if ($PHONOBOOK =~ m/^$id,/) {
						my @splited = split(',', $PHONOBOOK);
						$splited[1] = $newName;
						my $newPhonebook = join(',', @splited);
						print FILE $newPhonebook;
					} else {
						print FILE $PHONOBOOK;
					}
				}
				close(FILE);
			}

			elsif($selection == 2){
				print YELLOW "Nowy numer: \n", RESET;
				my $newNumber = <STDIN>;
				if(!looks_like_number($newNumber)){
					print RED "Ej... przeciez wiesz, ze to nie numer, podaj poprawny, zeby edytowac.\n", RESET;
					$newNumber = <STDIN>;
					if(looks_like_number($newNumber)){
						print YELLOW "OK, udalo sie za drugim razem.\n", RESET;
					}else{
						print RED "Nie wspolpracujesz, podany numer nie jest poprawny. Nieudane edytowanie kontaktu.\n", RESET;
						exit(0);
					}
				}
				chomp $newNumber;
				open(FILE, "<$phonebook");
				my @PHONEBOOK = <FILE>;
				close(FILE);
				open(FILE, ">$phonebook");
				foreach my $PHONOBOOK (@PHONEBOOK) {
					if ($PHONOBOOK =~ m/^$id,/) {
						my @splited = split(',', $PHONOBOOK);
						$splited[2] = $newNumber;
						my $newPhonebook = join(',', @splited);
						print FILE $newPhonebook;
					} else {
						print FILE $PHONOBOOK;
					}
				}
				close(FILE);
			}

			elsif($selection == 3){
				my $group;
				print YELLOW "Wybierz nowa kategorie \n";
				print "1) sluzbowy \n";
				print "2) prywatny \n";
				print "3) inny \n", RESET;
				my $category = <STDIN>;
				if($category == 1){
					$group = "sluzbowy";
				}
				elsif($category == 2){
					$group = "prywatny";
				}
				elsif($category == 3){
					$group = "inny";
				}
				else{
					print RED "Brak kategorii. Zawsze mozesz ja dodac edytujac kontakt.\n", RESET;
					$group = "";
				}
				chomp $group;
				open(FILE, "<$phonebook");
				my @PHONEBOOK = <FILE>;
				close(FILE);
				open(FILE, ">$phonebook");
				foreach my $PHONOBOOK (@PHONEBOOK) {
					if ($PHONOBOOK =~ m/^$id,/) {
						my @splited = split(',', $PHONOBOOK);
						$splited[3] = $group;
						my $newPhonebook = join(',', @splited);
						print FILE $newPhonebook;
					} else {
						print FILE $PHONOBOOK;
					}
				}
				close(FILE);
			}

			elsif($selection == 4){
				print YELLOW "Nowy opis: \n", RESET;
				my $newDescription = <STDIN>;
				chomp $newDescription;
				open(FILE, "<$phonebook");
				my @PHONEBOOK = <FILE>;
				close(FILE);
				open(FILE, ">$phonebook");
				foreach my $PHONOBOOK (@PHONEBOOK) {
					if ($PHONOBOOK =~ m/^$id,/) {
						my @splited = split(',', $PHONOBOOK);
						$splited[4] = $newDescription;
						my $newPhonebook = join(',', @splited);
						print FILE $newPhonebook;
					} else {
						print FILE $PHONOBOOK;
					}
				}
				close(FILE);
			}
			else{
				print RED "Cos Ci sie pomylilo, mozliwe wybory to 1, 2, 3 lub 4. \n", RESET;
			}
		}
		else{
			print RED "Kontakt o podanym id nie istnieje, mozesz sprawdzic liste kontaktow uzywajac arg --list \n", RESET;
		}
	}
}


sub optionsToChoose{
	print RED "Nieznany argument! \n";
	print "Oto te, które znam: \n";
	print "--add \n";
	print "--remove \n";
	print "--removeall \n";
	print "--list \n";
	print "--edit \n", RESET;
}


if(! defined $ARGV[0]){
	optionsToChoose();
}
elsif($ARGV[0] eq "--add"){
	add();
}
elsif($ARGV[0] eq "--remove"){
	remove()
}
elsif($ARGV[0] eq "--removeall"){
	removeall();
}
elsif($ARGV[0] eq "--list"){
	list();
}
elsif($ARGV[0] eq "--edit"){
	edit();
}
else{
	optionsToChoose();
	exit 0;
}
