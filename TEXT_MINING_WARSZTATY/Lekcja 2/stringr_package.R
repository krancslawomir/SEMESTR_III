  #---------------------------------------------------------#
  #                       Text minign                       #
  #                          CDV                            #
  #                    Mateusz Samson                       #
  #          Funkcje tekstowe w pakiecie stringr            #
  #---------------------------------------------------------#

# 1. Pakiet stringr ---------------------------------------------------------

# Pakiet stringr - Pakiet stringr jest częścią uniwersum pakietów `tidyverse` - 
# naszym zdaniem jest to optymalny wybór wśród pakietów oferujących funkcje do 
# operacji na tekstach w R.

# Instalacja pakietu

#install.packages('stringr')

# załadowanie biblioteki do pamięci
library(stringr)

# 1.1. Sklejanie tekstu ---------------------------------------------------------

# str_c - równoważna paste, ale używa "" jako domyślnego 
# separatora zamiast " "

str_c("Ala", "ma", "kota", sep = " ")
str_c("Ala", "ma", "kota", sep = " nie ")
str_c("Ala", "ma", "kota")

# Jako argumentu funkcji str_c można także użyć funkcji, której wartość R wylicza
# 'on the run' i drukuje w odpowiednie miejsce sklejanego ciągu zmiennych tekstowych:

str_c("2 + 2 = ", 2 + 2)

# Przykład z operacjami na wektorach:
ulice <- c('Puławska ', 'al. Solidarności ', 'Andersa ') 
numery <- c(34, 57, 106)
str_c(ulice, numery, ', Warszawa')

# 1.2. Długość tekstu ---------------------------------------------------------

# Funkcja str_length zwraca liczbę znaków zmiennej typu character:
str_length("Paderewski")
nchar('Paderewski')

# 1.3. Fragment tekstu ---------------------------------------------------------

# Funkcja fragment teksu z tekstu wycina z tekstu znaki według podanej lokalizacji 
# (początek, koniec).  
str_sub("abecadło", start = 2, end = 5)

# Funkcja lewy - od początku do trzeciego znaku od końca.
str_sub("abecadło", end = 3)

# Funkcja prawy:
str_sub("abecadło", start = -3)

# Funkcja prawy - dwa znaki z prawej strony (nieco bardziej skomplikowane)
str_sub("abecadło", start = str_length("abecadło")-1, end = str_length("abecadło"))
str_sub("abecadło", 5, 7)

# 1.4 Zmiana podciągów ---------------------------------------------------------

# Funkcji str_sub można także użyć do zastąpienia pewnego podciągu w ciągu znaków
# przez odpowiedniej długości prefiks innego ciągu (uwaga: str_sub dopasowuje się
# do najdłuższego argumentu, czyli możemy zastąpić np. 4 znaki w ciągu przez 6 znaków):

x <- "ABCDEF"
str_sub(x, 2, 5) <- "123456"
x # zauważmy - od razu nadpisuje
str_sub(x, 2, 5) <- "BC"
x # można też przypisać w miejsce dłuższego ciągu krótszy.

# 1.5. Rozdzielanie tekstu ---------------------------------------------------------

# Do rozdzielania tekstu na mniejsze kawałki służy funkcja str_split(string, pattern), 
# której parametrami są zmienne tekstowe string --- która ma zostać podzielona oraz 
# pattern --- określająca miejsce podziału (zastępująca wszystkie odpowiednie podciągi
# przez odstęp między kolejnymi wartościami zwracanego wektora). Opcjonalny argument n -
# na ile części ma zostać podzielona zmienna.
str_split("Ala ma kota", " ")
str_split("Ala ma kota", " ", n = 2)

str_split("Ala ma kota", "a")
str_split("Ala ma kota", "")

# Jeśli chcemy macierz:
str_split_fixed("Ala ma kota", " ", n = 1:3)

wynik <- str_split(c("Ala ma kota"), " ", n = 1:3)

# Rozbudowany przykład z listą
wektor_zdan <- c("Ala ma kota", 'Piotr posiada psa', 'Zbyszek nie ma papugi')

wynik <- str_split(wektor_zdan, pattern = ' ')
wynik

# Obsługa list:
toupper(wektor_zdan) # funkcja działa na wektorze
toupper(wynik) # funkcja działa, choć nie powinna i działa nie zgodnie z oczekiwaniami
str_to_upper(wynik) # funkcja działa, choć nie powinna i działa nie zgodnie z oczekiwaniami

# Funkcje nie działają poprawnie na liście, dlatego że wartości tekstowe nie są 
# bezposrednio dostępne dla funkcji tylko są w polach listy. Zwróćmy takie pole:
# toupper(wynik[[1]])

# Świetnie. To jak zastosować taką funkcję do WSZYSTKICH elementów listy?
# Odpowiedź: Za pomocą funkcji lapply bądź sapply.

wynik <- lapply(wynik, toupper)
wynik

wynik <- sapply(wynik, toupper) # sapply ma ciekawy argument USE.NAMES
wynik

wynik <- lapply(wynik, function(x) toupper(x))
wynik

# 1.6 Wielkie i małe litery ---------------------------------------------------------

# Niekiedy użyteczne bywają funkcje str_to_upper(string) oraz str_to_lower(string)
# zmieniające wszystkie litery danego tekstu na wielkie lub małe.
# Pozostałe symbole (znaki interpunkcyjne i specjalne, cyfry, spacje) pozostawiają bez zmian.
# Funkcja str_to_title zamienia litery danego tekstu tak, że pierwsza litera jest wielka, a reszta mała.

str_to_upper("E=mc^2")
str_to_lower("Pan Tadeusz to dobry wybór literatury...")
str_to_title("AbeCadło z Pieca SPAdło") # każdy wyraz wielką literą (angielska pisownia)

# 1.7 Zlokalizuj, wykryj, zamień ---------------------------------------------------------

# str_locate zwraca pozycję pierwszej znalezionej szukanej sekwencji tekstowej
#           (jeśli istnieje),
# str_locale_all zwraca wszystkie pozycje znalezionych szukanych sekwencji 
#                (jeśli istnieją)
# str_replace zamienia pierwszą wyszukaną sekwencję w każdym ze słów wektora (string)
#             na dany ciąg (replacement), 
# str_replace_all wszystkie sekwencje.
# str_detect zwraca tylko wartość TRUE/FALSE w zależności czy sekwencja została
#            znaleziona.
# str_detect_all j/w, tylko wykryj wszystkie.

str_locate("Ala ma kota", "a") # znaleźliśmy tylko pierwsze wystąpienie
str_locate("Ala ma kota", "a")[1] # cyfra oznaczająca początek ciągu w tekście
str_locate_all("Ala ma kota", "a") # wszystkie wystąpienia
str_locate_all("Ala ma kota", "a")[[1]] # bezpośredni dotęp do macierzy

# jeśli szukamy zwykłego ciągu znaków (nie wyrażenia regularnego), to można zwrócić wektor::
str_locate_all("Ala ma kota", "a")[[1]][, 1] # lokalizacja początku szukanego ciągu

# Wariant z wektorem stringów:
wynik <- str_locate_all(c("Ala ma kota", "Piotr ma psa"), "a")
wynik

# lokalizacja litery "a" (w pierwszym stringu)
wynik[[1]][,1]

# lokalizacja pierwszego wystąpienia litery "a" (w pierwszym stringu)
wynik[[1]][1,1]

# Przykład z funkcją lapply:

# Zadanie: zwróć z każdego pola listy lokalizację pierwszego wystąpienia litery
# a
# lapply(wynik, function(x) x[1,1])
# sapply(wynik, function(x) x[1,1])

# Zadanie: a teraz spróbujmy zwrócić trzecie wystąpienie. Zauważmy, że w jednym 
# z pól nie ma trzeciego wystąpienia.
# lapply(wynik, function(x) x[3,1])
# sapply(wynik, function(x) x[3,1])

# Niestety, taka operacja nie zadziała - musielibyśmy zastosować kontrolę błędów.

# można też szukać dłuższych sekwencji:
str_locate_all("Ala ma kota, a kot ma Alę", "kot")[[1]]

# Znajdź i zamień:
  str_replace("mama", "m", "t")
str_replace_all("mama", "m", "t")

# Natomiast jeżeli chcemy tylko dowiedzieć się, czy jakiś pattern występuje w naszym
# wektorze string, a nie konkretnie wskazać, na których pozycjach, możemy użyć funkcji 
# str_detect:
str_detect(c("mmm","abcM"," M M M ","W"), "M")

# W przypadku wykorzystania wyrażeń regularnych, przydaje się str_extract()
str_extract(c("mmm","abcM"," M M M ","W"), "M")
str_extract_all(c("mmm","abcM"," M M M ","W"), "M")
str_extract_all(c("mmm","abcM"," M M M ","W"), "M", simplify = T) # zwraca macierz,

str_extract_all(c("mmm","abcM"," M M M ","W"), "M.?")
str_extract_all(c("mmm","abcM"," M M M ","W"), "M|W")

# 1.8 Duplikacja znaków w tekście ---------------------------------------------------------

# Funkcja str_dup służy powielaniu określonych znaków w tekście. Można ją połączyć np. z 
# funkcją str_c i tworzyć ciągi tekstów. Funkcja ta przyjmuje argument string oraz times,
# czyli ile razy ma zostać powtórzony dany element.

str_dup("ok! ", 5)
str_dup(c("jabłko", "ananas", "banan"), 2)
str_dup(c("jabłko", "ananas", "banan"), c(1,3,2))
str_c("kajak", str_dup("na", 0:5))

# 1.9 Usuwanie początkowych i końcowych spacji ---------------------------------------------------------

# Funkcja str_trim usuwa początkowe i końcowe spacji w danym tekście.
# Funkcja ta przyjmuje argumenty string oraz side, który może przyjąć wartość "left" 
# (usuwa spację od lewej strony), "right" (prawej) orz "both, czyli z obu (domyślna wartość).

str_trim(" 2001-01-01 ")
str_trim("        Ania               ", side = "left")
str_trim("        Ania               ", side = "right")
str_trim("        Ania               ") # domyślnie "both"

# Usunięcie podwójnych spacji
str_squish('Ala  ma  kota')
str_squish('Ala   ma    kota')
# Usunięcie białych spacji (whitespace)
str_squish('Ala  ma\n\r\tkota')

#### 1.10 Wydłużanie tekstu ---------------------------------------------------------

# Funkcją str_pad możemy wydłużyć nasz tekst do danej długości poprzez dodanie do niego
# określonych znaków z prawej, lewej lub obu stron. Funkcja przyjmuje argumenty 
# string, width (docelowa długość), side (czyli z której strony dodawać znaki) oraz pad,
# czyli jakie znaki dodajemy (domyślnie spacje).

str_pad("ms", width = 10)
str_pad("ms", width = 10, side = "both")
str_pad(c("x",'y','z'), width = c(5, 10, 15), pad = c("-", "_", "1"))

# 1.11 Sortowanie tekstu ---------------------------------------------------------

# Funkcja str_sort sortuje alfabetycznie dany tekst. Argumenty to string, decreasing (malejąco),
# locale = "pl" (lub "en" w zależności od wybranego języka). Opcjonalny arguemt na_last, który
# ustala, gdzie "lądują" ewentualne wartości NA.

str_sort(c("Ania", "Tomek", "Krzysiek", "Marta", "Asia"))
str_sort(c("Ania", NA, "Tomek", "Krzysiek", NA, "Marta", "Asia"))
str_sort(c("Ania", NA, "Tomek", "Krzysiek", NA, "Marta", "Asia"), decreasing = T)
str_sort(c("Ania", NA, "Tomek", "Krzysiek", NA, "Marta", "Asia", 'Łukasz'), decreasing = T, na_last = F)

# 1.12 Skracanie tekstu ---------------------------------------------------------

# Funkcją str_trunc możemy ustalić maksymalną długość tekstu oraz to, z której strony
# ma zostać skrócony. 

dlugi_tekst <- "To jest całkiem długi tekst, rzeczywiście bardzo długi"

str_trunc(dlugi_tekst, 20, "right")
str_trunc(dlugi_tekst, 20, "left")
str_trunc(dlugi_tekst, 20, "center")


# Więcej informacji:
browseURL('https://cran.r-project.org/web/packages/stringr/vignettes/stringr.html')
