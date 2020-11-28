  #---------------------------------------------------------#
  #                       Text minign                       #
  #                          CDV                            #
  #                    Mateusz Samson                       #
  #          Funkcje tekstowe w pakiecie stringr            #
  #---------------------------------------------------------#

# Wyrażenia regularne pozwalają na definiowanie/odwoływanie się w sposób uogólniony 
# do elementów tekstowych. Są szczególnie przydatne, gdy interesują nas ciągi znaków 
# np. o danych prefiksach, sufiksach, o danej długości itp.

# Przez wyrażenie regularne rozumiemy ciąg znaków, który ma wzór - jest zbudowany
# według pewnych, nawet bardzo ogólnych znaków. Np. numer telefonu komórkowego 
# zapisany jest (zazwyczaj, nie zawsze oczywiście) jako ciąg 9 cyfr, bez separatora,
# lub pogrupowane po 3 i oddzielone od siebie myślnikiem lub spacją. Będziemy 
# podobnych wzorców szukać dziś na zajęciach.

# Poznane już funkcje takie jak str_replace, str_locate, czy str_detect
# pozwalają na wprowadzenie do argumentu pattern wyrażenia regularnego.
# Pokażemy zastosowanie wyrażeń regularnych przy okazji korzystania z tych funkcji.

library(stringr)
# 1. Klasy jednoelementowe -----------------------------------------------------

# Wyrażenie "abcd" to po prostu ciąg znaków, więc definiuje jednoelementową klasę 
# zmiennych tekstowych: tylko on sam.

# 2. Spójnik "lub" -----------------------------------------------------

# Najprościej szerszą klasę można definiować za pomocą spójnika ,,lub'' (|).
# Wyrażenie "a|b|c" odpowiada trzyelementowej klasie zmiennych tekstowych: "a", 
# "b", "c".
str_replace(c("a", "b", "c", "d"), "a|b|c", "x")

# W powyższym przykładzie można zauważyć, że w ciągu znaków użyliśmy "|" który
# nie jest interpretowany wprost czyli jest znakiem specjalnym który oznacza "lub"

# 3. Kwantyfikatory -----------------------------------------------------

# Możemy zdefiniować klasę, w której uwzględnione są powtarzające się ciągi znaków,
# Na przykład do klasy definiowanej przez wyrażenie regularne "ba*b" należy
# każdy z napisów: "bb", "bab", "baaab").

str_replace(c("cbb", "cbab", "baaabc", "aaab"), "ba*b", "x")
str_replace(c("cbb", "cbab", "baaabc", "aaab"), "ba+b", "x")
str_replace(c("cbb", "cbab", "baaabc", "aaab"), "ba?b", "x")
str_replace(c("cbb", "cbab", "baaabc", "aaab"), "ba{1,3}b", "x")

# Więcej kwantyfikatorów:

# *: przynajmniej zero powtórzeń danego znaku.
# +: przynajmniej jedno powtórzenie danego znaku.
# ?: Najwyżej jedno powtórzenie
# {n}: Dokładnie n powtórzeń
# {n,}: Co najmniej n powtórzeń 
# {n,m}: Pomiędzy n a m powtórzeń

str_replace(c("cbb", "cbab", "baaabc", "aaab"), "ba+b", "x")
str_replace(c("cbb", "cbab", "baaabc", "aaab"), "ba?b", "x")
str_replace(c("cbb", "cbab", "baaabc", "aaab"), "ba{3}b", "x")
str_replace(c("cbb", "cbab", "baaabc", "aaab"), "ba{2,}b", "x")
str_replace(c("cbb", "cbab", "baaabc", "aaab"), "ba{2,4}b", "x")
str_replace(c("cbb", "cbab", "baaabc", "aaab"), "b?a{2,4}b", "x")

# Zaprezentowane kwantyfikatory to kwantyfikatory chciwe. 

str_replace(c("cbb", "cbab", "baaaaabaaaaaaaaaac", "aaab"), "b.*b", "x")

str_replace(c("cbb", "cbab", "baaaaabaaaaaaaaaac", "aaab"), "b.*?b", "x")

str_replace(c("98-100", "98-999", "9-8", "A"), "..-...", "XX-XXX")

#dwie funkcje, ktora sprawdza, gdzie wyrażenie zaczyna sie na b nastpnie sprawdza po 
#leniwym kwantyfikatorze

#Poniżej kwantyfikatory 
# leniwe:

# ??: 0 lub 1, preferowane 0.
# +?: 1 lub więcej, preferowane mniej
# *?: 0 lub więcej, preferowane mniej
# {n,}?: n lub więcej, preferowane mniej
# {n,m}?: pomiędzy n i m, preferowane mniej

x <- "1888 is the longest year in Roman numerals: MDCCCLXXXVIII"
str_extract(x, "CC?") # C i C co najmniej raz
str_extract(x, "CC??") # C i C maksymalnie raz, ale wolimy zero
str_extract(x, c("C{2,3}.?", "C{2,3}?.?"))
str_extract(x, c("C{2,}", "C{2,}?"))
str_extract(x, c("C[LX]+", "C[LX]+?"))

##chciwy bierze zawsze wiecej

# 4. Kotwice (anchors) i granice (boundaries) ---------------------------------

# Czasamy interesuje nas znalezienie wyrażenia regularnego, które np, rozpoczyna 
# lub kończy tekst poniżej kilka wyrażeń, które może okazać się pomocne.

# ^: szuka wzorca na początku ciągu znaków.
# $: szuka wzorca na końcu ciągu znaków.
# \b: szuka wzorca na początku, lub końcu wyrazu
# \B: szuka wzorca który nie jest na początku lub końcu żadnego wyrazu 

# Przeanalizujmy na przykładzie.
strings <- c("abcd fabc ", "cdab gabc", "cabd", "c abd")
strings

str_replace_all(strings, "ab", 'x')
str_replace_all(strings, "^ab", 'x')
str_replace_all(strings, "ab$", 'x')
str_replace_all(strings, "^ab|ab$", 'x') #laczenia
str_replace_all(strings, "\\bab", 'x') #laczenia
str_replace_all(strings, "\\Bab", 'x') #laczenia


# \\ #tzw. escepe sign > znak ucieczki albo wylaczenia
# wyłączenie slasha i następnie  
setwd("D:\Mat disc/Labmaster kurs/R/Lekcja 3")
# \M # nie istnieje
# \n # już istnieje


"Cytat z ksiazki \"Pan Tadeusz\""

# Wyrażenia ^ i $ to kotwice, ponieważ wskazują na konkretną pozycję w tekście. 
# Z kolei granice (boundaries) wskazują pozycje relatywne: np. początek każdego wyrazu.
# Więcej informacji zanjdziemy np. tutaj:
# http://www.rexegg.com/regex-boundaries.html#wordboundary

# Jeszcze jeden fajny przykład:
str_replace_all("The quick brown fox", "\\b", "_")
#> [1] "_The_ _quick_ _brown_ _fox_"
str_replace_all("The quick brown fox", "\\B", "_")
#> [1] "T_h_e q_u_i_c_k b_r_o_w_n f_o_x"

# oraz tu:
# http://www.rexegg.com/regex-quickstart.html#anchors

# 5. Klasy znaków --------------------------------------------------------------

# W szukaniu ciągu znaków możemy definiować wzory ogólniejsze od konkretnych znaków. 
# Przyjrzyjmy się najważniejszym z nich:

# [:digit:] cyfry: 0 1 2 3 4 5 6 7 8 9 można napisać też: [0-9] lub \d.
# \D: wszystko, ale nie cyfry - alternatywnie [^0-9].
# [:lower:]: małe litery, rownoznaczne [a-z].
# [:upper:]: duże litery, rownoznaczne  [A-Z].
# [:alpha:]: dowolne litery, równoznaczne: [[:lower:][:upper:]] or [A-z].
# [:alnum:]: dowolne litery bądź znaki, równoznaczne: [[:alpha:][:digit:]] or [A-z0-9].

str_replace(c("98-100", "98-999", "9-8", "A"), "\\d\\d-\\d\\d\\d...", "XX-XXX")
#lub
str_replace(c("98-100", "98-999", "9-8", "A"), "\\d{2}-\\d{3}...", "XX-XXX")
#lub
str_replace(c("98-100", "98-999", "9-8", "A"), "[0-9]{2}-[0-9]{3}...", "XX-XXX")

# \w: dowolne znaki alfanumeryczne, równoznaczne: [[:alnum:]_] or [A-z0-9_].
# \W: znak nie alfanumeryczny [^A-z0-9_].
# [:blank:]: znaki nie widoczne, np. spacja lub tabulator. (podobne: [:space:]:)
# \s: spacja
# \S: nie spacja
# [:punct:]: znaki interpunkcyjne, punktory symbole - ściślej: ! " # $ % & ’ ( ) * + , - . / : ; < = > ? @ [  ] ^ _ ` { | } ~.
# [:graph:]: znaki mające reprezentację graficzną: [[:alnum:][:punct:]].
# [:print:]: znaki drukowane - graficzne i spacja, czyli można też [[:alnum:][:punct:]\\s].
# [:cntrl:]: znaki kontrolne, np. \n or \r, inaczej: [\x00-\x1F\x7F].
# . - dowolny znak

# Uwagi:
# 1) Zauważmy że "[]" "::" to znaki specjalne, które muszą zostać poprzedzone \ 
# żeby zostać użyte w zwykłym tekście, np.

str_replace("[nawias kwadratowy]","[","x") # dlatego stosuje to co niżej
str_replace("[nawias kwadratowy]","\\[","x")

# albo
str_split_fixed('[Ala]', fixed('['), n = 2)

# Ponadto:
str_replace(c("A", "*A", "**A", "*AA"), "\\*A", "x")
str_replace(c("A", "*A", "**A", "*AA"), "\\**A", "x")

# 2) \ slash jest znakiem specjalnym który sam w sobie potrzebuje wyłączenia (z ang. escape) \\d. Przykłady:

# \\d cyfry
str_replace_all("Bitwa pod Grunwaldem miała miejsce w...    1410    roku.", "\\d", "*")
# \\D nie-cyfry
str_replace_all("Bitwa pod Grunwaldem miała miejsce w...    1410    roku.", "\\D", "*")
# \\s spacje
str_replace_all("Bitwa pod Grunwaldem miała miejsce w...    1410    roku.", "\\s", "*")
# \\S nie-spacje
str_replace_all("Bitwa pod Grunwaldem miała miejsce w...    1410    roku.", "\\S", "*")
# \\w słowa (litery i cyfry)
str_replace_all("Bitwa pod Grunwaldem miała miejsce w...    1410    roku.", "\\w", "*")
# \\W nie-słowa
str_replace_all("Bitwa pod Grunwaldem miała miejsce w...    1410    roku.", "\\W", "*")
# 
# 3) Nie należy mylic \d z R-owymi znakami specjalnymi: \n, \r, \t etc.

# 6. Grupowanie fraz -----------------------------------------------------------

# Niekiedy definiując klasę ciągów znaków chcemy traktować pewien ciąg jako jeden 
# spójny, nierozdzielalny kawałek. W tym celu ujmujemy w nawiasy segment, który 
# ma stanowić całość. Przykładowo, klasę złożoną z napisów typu X, XYX, XYXYX itd. 
# możemy zdefiniować jako "(XY)*X". Kwantyfikator nie odnosi się wtedy do ostatniego 
# znaku, ale do ciągów znaków.
str_replace(c("XXX", "XY", "YXY", "XYXYXYYXY", "XYX"), "XY*X", "0")
str_replace(c("XXX", "XY", "YXY", "XYXYXYYXY", "XYX"), "(XY)*X", "0")
str_replace_all(c("XXX", "XY", "YXY", "XYXYXYYXY", "XYX"), "(XY)*X", "0")

# Zwróćmy uwagę jeszcze na różnicę w wyrażeniach:
str_extract(c("grey", "gray"), "gre|ay")
str_extract(c("grey", "gray"), "grey|gray")
str_extract(c("grey", "gray"), "gr(e|a)y")
str_extract(c("grey", "gray"), "gr[ae]y")
str_extract(c("(np.", "np."), "\\(")
str_extract(c("(np.", "np."), fixed("("))

# To jest to samo:
str_locate_all("abc and ABC", "(ab)|c")
str_locate_all("abc and ABC", regex("(ab)|c", ignore_case = TRUE))
str_locate_all("abc and ABC", "ab|c")

# To jest to samo:
str_locate_all("abc and ABC", "[ab]|c")
str_locate_all("abc and ABC", "a|b|c")

# Na koniec jeszcze o znakach \\1, \\2, ... \\N -  Alias n-tej grupy znalezionej
# w ciągu znaków

# Znajdź pierwsze wystąpienie grupy (ab) i podmień na podwójne wyrażenie znalezione:
str_replace("abc and ABC", "(ab)", "\\1\\1")
# Znajdź pierwsze wystąpienie grupy ([ab]) - czyli a BĄDŹ b 
# i podmień na podwójne znalezione wyrażenie:
str_replace("abc and ABC", "([ab])", "\\1\\1")
# Bez nawiasów nie działa - ich jedyna funkcja to stworzenie aliasu \\1
str_replace("abc and ABC", "[ab]", "\\1\\1")

# Teraz jw. ale podmieniamy wszystkie:
str_replace_all("abc and ABC", "([ab])", "\\1\\1") # nawiasy kwadratowe - klasa wyrażeń
str_replace_all("abc and ABC", "([A-z])", "\\1\\1") # nawiasy kwadratowe - klasa wyrażeń

# Zwróćmy uwagę jeszcze na ten przykład:
str_replace("YXABCDXABCDYX", '.*([A-Z]{4})(X)([A-Z]{4}).*', '\\1\\3')
#                             YX    ABCD   X    ABCD   YX
# symbole \\n wrażliwe są jedynie na grupy:
str_replace("YXABCDXABCDYX", '(.*)([A-Z]{4})(X)([A-Z]{4}).*', '\\1\\3')
str_replace("YXABCDXABCDYX", '(.*)([A-Z]{4})(X)([A-Z]{4}).*', '\\2\\4')

# Dzięki temu możemy zamienić jedno wyrażenie regularne na inne, np. zamieńmy wektor:
c('Sklep 1', 'Sklep 32', 'Sklepy 117', 'Sklepowo 18791', 'Sklep 002', 'Sklepik 16', 'Sklepowy 1165')

# powinniśmy to zrobić tak:
c("1 Sklep", "32 Sklep", "117 Sklepy", "18791 Sklepowo", "002 Sklep", "16 Sklepik", "1165 Sklepowy")

# Za pomocą takiego wyrażenia, można szybciej i prościej:
str_replace(c('Sklep 1', 'Sklep 32', 'Sklepy 117', 'Sklepowo 18791', 'Sklep 002', 'Sklepik 16', 'Sklepowy 1165'),
            '([A-z]{1,})\\s([0-9]{1,})','\\2 \\1') #litera wielka/mala co najmniej 1 raz, jest grupa
                    # grupa druga, spacja cyfry , co najmniej 1 raz, 
                    # zamienia miejscami

# do wyrażeń możemy odwoływać się też bezpośrednio we wzorcu:
str_extract(c('ananas', 'kokos', 'jabłko', 'kiwi'), "(..)")
str_extract(c('ananas', 'kokos', 'jabłko', 'kiwi'), "(..).*\\1")

# 7. Znajdowanie emoji ---------------------------------------------------------

# A. Emoji
xvect = c('😂', 'no', '🍹', '😀', 'no', '😛')

Encoding(xvect) <- "UTF-8"

which(str_detect(xvect,"[^[:ascii:]]")==T) # ktory nie jest w standardzie znaków ascii

# Albo: 
str_detect(c('😀','😗'),'\\N{grinning face}') # wyrazenia regularne, dla buziek
str_detect(c('😀','😗','😁'),'\\N{kissing face}')

# B. Asercje "Aookarounds"  -----------------------------------------------------
# uznanie jakiegoś zdania za prawdziwe

# Niekiedy, wyszukując pewne wyrażenie, interesuje nas tylko taki przypadek, który
# poprzedza/okala lub po którym następuje określony inny ciąg znaków. Ograniczeniem jest
# niestety fakt, że asercja musi składać się ze skończonej liczby znaków,

# Następowanie (pozytywne/negatywne)
str_extract_all('100 osób wydało na lody średnio 15 zł', '\\d+')
str_extract_all('100 osób wydało na lody średnio 15 zł', '\\d+(?= zł)') 
str_extract_all('100 osób wydało na lody średnio 15 zł', '\\d+(?! zł)')
str_extract_all('100 osób wydało na lody średnio 15 zł', '\\d+(?! zł|\\d+)')

# Poprzedzanie (pozytywne/negatywne)
str_extract_all('Sprzedano 100 sztuk, kupiono 120','(?<=[sS]przed[a-z]{1,10}\\s)\\d+')
str_extract_all('Sprzedano 100 sztuk, kupiono 120','(?<![sS]przed[a-z]{1,10}\\s)\\d+')
str_extract_all('Sprzedano 100 sztuk, kupiono 120','(?<![sS]przed[a-z]{1,10}\\s|\\d)\\d+')

# Ale...

# Lista assercji:
# (?=...): positive look-ahead assertion
# (?!...): negative look-ahead assertion. 
# (?<=...): positive look-behind assertion.
# (?<!...): negative look-behind assertion. 


library(rvest)
library(stringr)

browseURL("https://pl.wikipedia.org/wiki/Lista_bank%C3%B3w_dzia%C5%82aj%C4%85cych_w_Polsce")
www <- read_html("https://pl.wikipedia.org/wiki/Lista_bank%C3%B3w_dzia%C5%82aj%C4%85cych_w_Polsce")
tables <- html_table(www, fill = TRUE)
banki <- tables[[1]][,2]
banki

# Nazwa banku ma cztery litery i słowa Bank nie poprzedza Euro ani Plus.
str_extract(banki, '\\b\\w{4}(?<![Euro|Plus])\\sBank')

# Lewe i prawe granice
str_extract(c('niezapomniany', 'nie robię', 'niedziela', 'poniedziałek', 'bieganie'), 
            '\\b(?=\\w)nie.*') # zaczyna się od frazy 'nie' ale nie poprzedza frazy 'nie' żadna litera
str_extract(c('niezapomniany', 'nie robię', 'niedziela', 'poniedziałek', 'bieganie'), '.*nie\\b(?<=\\w)')
str_extract(c('niezapomniany', 'nie robię', 'niedziela', 'poniedziałek', 'bieganie'), '.*\\Bnie\\B.*')

# D. Funkcje str_match i str_subset --------------------------------------------

# Funkcja str_subset od razu odrzuca dane które nie spełniają wymogów wyrażenia regularnego
banki %>% 
  str_subset('.{20,}')

# Z kolei funkcja str_match identyfikuje wychwytu/e grupy: 
telefony <- c("785-234-432", "555 575 325", "Ania", "pomarańcza", "11", "198 234 235", "923-444-565",
           "876-543-212","876.543.212")
numery <- "([5-8][0-9]{2})[- .]([0-9]{3})[- .]([0-9]{3})" # wyrażenie z grupami
numery2 <- "[5-8][0-9]{2}[- .][0-9]{3}[- .][0-9]{3}" # wyrażenie bez grup:

str_match(telefony, numery)
str_match(telefony, numery2)
str_extract(telefony, numery)
str_extract(telefony, numery2)

# Lista numerów w interesującym nas formacie:
wynik <- str_match(telefony, numery)
str_c(wynik[,2], wynik[,3], wynik[,4]) %>% na.omit %>% as.numeric
str_c(wynik[,2], wynik[,3], wynik[,4], sep = '-') %>% na.omit

# Spójrzmy jeszcze na nieco ogólniejszy regexp na numery telefonów i skorzystajmy z możliwości
# pisania komentarzy w regexach
phone <- regex("
  \\(?     # opcjonalny nawias
  (\\d{3}) # pierwszy człon numeru
  [)- ]?   # opcjonalny spójnik pomiędzy cyframi
  (\\d{3}) # kolejne trzy liczby
  [ -]?    # # opcjonalny spójnik pomiędzy cyframi
  (\\d{3}) # ostatnie trzy liczby
  ", comments = TRUE)

str_detect(c('456789222', '456-789-222', '(456)789-222', '(+48)456789222'), phone)
str_extract(c('456789222', '456-789-222', '(456)789-222', '(+48)456789222'), phone)

# Komentarze można pisać bez funkcji regex tak:
str_extract("xyz", "x(?#this is a comment)")

# E. Przykłodowe wzorce
'([A-Za- regex -------------------------------------------------z0-9-]+)' # co najmniej 1 znak alfanumeryczny i myślnik
str_extract('NUMER}_','([A-_]+)') # do testów (cały zakres ASCII działa)

'(\\d{1,2}\\/\\d{1,2}\\/\\d{4})' # data
str_extract('12/02/2018','(\\d{1,2}\\/\\d{1,2}\\/\\d{4})') # do testów

'([^\\s]+(?=\\.(jpg|gif|png))\\.\\2)' # ....
str_extract('anime.jpg','([^\\s]+(?=\\.(jpg|gif|png))\\.\\2)') # do testów

'(^[1-9]{1}$|^[1-4]{1}[0-9]{1}$|^50$)'# Liczba od 1 do 5
str_extract(c('44','62'),'(^[1-9]{1}$|^[1-4]{1}[0-9]{1}$|^50$)') # do testów

'(#?[A-Fa-f0-9]){3}(([A-Fa-f0-9]){3})?)'# kolor w systemie RGB
str_extract('#164899', '(#?[A-Fa-f0-9]){3}(([A-Fa-f0-9]){3})?') # do testów

'(\\w+@[a-zA-Z_]+?\\.[a-zA-Z]{2,6})'# ....
str_extract('p.cwiakowski@gmail.com', '(\\w+@[a-zA-Z_]+?\\.[a-zA-Z]{2,6})') # do testów


'(\\<(/?^/>]+)\\>)'# ....
str_extract('<div>', '(\\<(/?[^/>]+)\\>)') # do testów
str_extract('</div>', '(\\<(/?[^/>]+)\\>)') # do testów

# F. Odległości Dodatkowo: o pomiędzy słowami - ciekawlacja pakietów:
#install.packages('stringdist')

# Wczytanie bibliotek
library(stringdist)

# Proste obliczenia:
stringdist('crabapple','apple',method="osa") # OSA
stringdist('crabapple','apple',method="lv") # Levenshtein
stringdist('crabapple','apple',method="dl") # Damerau–Levenshtein
stringdist('crabapple','apple',method="hamming") # Hamming
stringdist('crabapple','apple',method="lcs") # Longest common string
stringdist('crabapple','apple',method="qgram")

# Exact Matching
match('apple',c('crabapple','pear'))
match('apple',c('crabapple','pear', 'apple'))
match(c('apple','crabapple'),c('crabapple','pear', 'apple'))

# Fuzzy matching
amatch('apple',c('crabapple','pear'), maxDist=3, method='dl')
amatch('apple',c('crabapple','pear'), maxDist=4, method='dl')

# Binarny marching:
ain('raspberry',c('berry','pear'), maxDist=4, method='dl')

# Można stworzyć macierz odległości...
fruit <-c('crabapple','apple','raspberry')
fruit.dist <- stringdistmatrix(fruit)
fruit.dist

# I następnie można zrobić klastrowanie (grupowanie hierarchiczne, HCA)
plot(hclust(fruit.dist),labels=fruit)

### I już wykonaliśmy jakaś analize danych tekstowych ;) ###

#Wikipedia o grupowaniu hierarchicznym:  # gdyby ktoś nie wiedział co to

#Służy do dzielenia obserwacji na grupy (klastry) bazując na podobieństwach 
#między nimi. W przeciwieństwie do wielu algorytmów służących do klastrowania 
#w tym wypadku nie jest konieczne wstępne określenie liczby tworzonych klastrów


# Źródła: ----------------------------------------------------------------------
# 
# 1. https://rstudio-pubs-static.s3.amazonaws.com/74603_76cd14d5983f47408fdf0b323550b846.html
#    https://cran.r-project.org/web/packages/stringr/vignettes/regular-expressions.html

# Ponadto warto zajrzeć tutaj:
# 
# 2. http://regexlib.com/CheatSheet.aspx?AspxAutoDetectCookieSupport=1
# 
# 3. http://www.rexegg.com/regex-quickstart.html
#    http://www.rexegg.com/regex-boundaries.html
#    
# 4. http://gastonsanchez.com/Handling\_and\_Processing\_Strings\_in\_R.pdf strony 63--96
# 
# 5. http://biostat.mc.vanderbilt.edu/wiki/pub/Main/SvetlanaEdenRFiles/regExprTalk.pdf

# 6. https://www.regular-expressions.info/rlanguage.html
