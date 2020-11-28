  #---------------------------------------------------------#
  #                       Text minign                       #
  #                          CDV                            #
  #                    Mateusz Samson                       #
  #             Importowanie danych tekstowych              #
  #---------------------------------------------------------#

# Ścieżka dostępu
setwd('...')
setwd('D:/Mat disc/R/CDV - Text mining')

# Biblioteki
library(pdftools)
library(tidyverse)
library(tm)
library(textreadr)

# 1. Import plików pdf ----------------------------------------------------

# 1.1. Import pojedynczego pliku

# Po angielsku:
dok <- pdf_text('Lekcja 4/Dane/Sauna_Isotopes.pdf')
dok

# Plik jest wektorem składającym się z 10 obserwacji. 
# Zróbmy z tego jeden plik:
dok <- paste(dok, collapse = ' ')
dok

# Teraz pójdziemy dwoma torami. 
# Z jednej strony można podzielić tekst na linijki:
dok2 <- strsplit(dok, '\r\n')
dok2
# Przyda nam się do stworzenia metadanych pliku.

# Albo od razu usunąć symbole '\r\n' oraz wielu spacji:
dok <- str_squish(dok)
dok

# Sprawdźmy jeszcze wczytywanie po polsku:
dokpl <- pdf_text('Lekcja 4/Dane/Kodeks dobrych obyczajow w pracach naukowych.pdf')
dokpl
dokpl2 <- pdf_text('Lekcja 4/Dane/Szczęście czy fart.pdf')
dokpl2

# Jeśli są polskie znaki, to znakomicie. Jeśli nie, to trzeba będzie pochylić nad
# standardem kodowania znaków w systemie, R i importowanych plikach. 

# 1.2. Import wielu plików pdf w pętli

# Stworzenie listy plików
lista_plikow <- dir('Lekcja 4/Dane/minutes_nbp_en/')
lista_plikow

# Pusta lista dokumentów
dokumenty <- list()

# Pętla - kolejno importowane są kolejne pliki. 
# Dodatkowo, prezentujemy dwie funkcje
# tekstowe (sprintf i str_interp) do umieszczania placeholderów w stringach.
for(i in lista_plikow){
  dokumenty[[i]] <- pdf_text(sprintf('Lekcja 4/Dane/minutes_nbp_en/%s', i)) #placeholder
  print(str_interp("Plik ${i} wczytany")) # Uwaga print - spowalnia pętlę!
}

# przykład placeholdera
### w R sprintf('Dane/minutes_nbp_en/%s', 'Jakas wartosc')) 

# Więcej informacji o placeholderach na przkład tutaj:
browseURL('https://www.gastonsanchez.com/r4strings/c-style-formatting.html')

# Spróbujmy teraz powtórzyć kroki czyszczenia dokumentów, 
# tylko teraz dla wszystkich plików:

# Scalanie tekstów w jedną obserwację:
dokumenty <- lapply(dokumenty, function(x) paste(x, collapse = ' '))
dokumenty <- lapply(dokumenty, paste, collapse = ' ')
dokumenty[[2]]

# Podzielenie dokumentu na linijki:
dokumenty <- lapply(dokumenty, strsplit, split = '\r\n', fixed = T)
dokumenty[[1]]

# Zredukowanie głębokości listy:
dokumenty <- lapply(dokumenty, function(x) x[[1]])
dokumenty[[1]]

# Usunięcie spacji z początku i końca linijki:
dokumenty <- lapply(dokumenty, str_trim)
dokumenty[[1]]

# Pobranie metadanych

# 1. Data spotkania (2 linijka):
data_spotkania <- sapply(dokumenty, function(x) x[2])
data_spotkania

# Ekstrakcja daty:
data_spotkania <- str_extract(data_spotkania, '[0-9].*')
data_spotkania

# 2. Data publikacji raportu (ostatnia linijka)
data_publikacji <- sapply(dokumenty, function(x) x[length(x)])
data_publikacji

# Nie działa - spróbujmy wybrać linijkę, która zawiera frazę 'Publication date:'
data_publikacji <- sapply(dokumenty, function(x) x[which(str_detect(x,'Publication date:'))])
data_publikacji

# Ekstrakcja daty:
data_publikacji <- str_extract(data_publikacji, '[0-9].*')
data_publikacji

# zamienimy teraz tekst na datę. W tym celu zmienimy daty na anglosaskie:
Sys.setlocale("LC_TIME", "C")

# Jeśli chcemy na polskie
# Sys.setlocale("LC_TIME", "Polish_Poland.1250")

data_publikacji <- as.Date(data_publikacji, '%d %B %Y')
data_publikacji

# Gotowe. 

# Linijki dokumentów połączmy teraz w jedną obserwację.
dokumenty[[1]]
dokumenty <- lapply(dokumenty, paste, collapse = ' ')
dokumenty[[1]]

# Zamienimy jeszcze listę na dataframe.
dok_df <- data.frame(id = names(dokumenty), text = unlist(dokumenty))
head(dok_df)

# przypiszmy date do df
dok_df$data <- data_publikacji

# zamienmy tekstowa wartosc na date w kolumnie spotkania
dok_df$spotkanie <- as.Date(data_spotkania, '%d %B %Y')

dok_df$roznica <- dok_df$data - dok_df$spotkanie

dok_df
# rozklad uplywu czasu do publikacji
table(dok_df$roznica)

# A gdyby to były tibble?
dok_tbl <- as.tbl(dok_df)
dok_tbl

# Trochę lepiej. Dane są gotowe do dalszej analizy.

# Zapiszemy teraz pliki w formie txt. 
# Przyda się to później do czyszczenia i ćwiczeń.
dir.create('Lekcja 4/Dane/minutes_nbp_en_text') 
mapply(function(x, y) writeLines(x, con = sprintf('Lekcja 4/Dane/minutes_nbp_en_text/%s.txt', y)), 
       x = dokumenty, y = names(dokumenty))

# Zapisane. Sprawdźmy zawartość folderu.

# Ćwiczenia 

# 1. Wczytaj komunikaty RPP po angielsku. Następnie:
# Oczyść tekst z niepotrzebnych znaków (jeśli występują) i następnie dokonaj
# ekstrakcji z tekstu jak najwięcej danych (o ile to możliwe):
# a) daty komunikatów/publikacji (Stwórz następnie osobne kolumny dla roku i miesiąca)
# b) poziomy stóp procentowych
# c) czy zostały zmienione czy utrzymane na stałym poziomie
# d) dodoatkowo inne informacje, które uważasz za istotne
# e) dla danych ustrukturyzowanych spróbuj pokazać zmiany wskaźników w czasie na wykresie
# jeśli potrafimy, albo chociaż spróbujcie - 1 wykres*
# f) plik z danymi zapisz do pliku .RData - przyda się później
# g) utwórz nowy folder i wczytane pliki zapisz jako txt - przyda się później


# 2. Pliki tekstowe ------------------------------------------------------------

# Załadować pliki tekstowe możemy za pomocą funkcji readLines("..."), na początku
# musimy jednak ustalić ścieżkę:
setwd("...")
a <- readLines('Lekcja 4/Dane/Szczescie czy fart.txt') # plik z danymi
# a <- readLines('Lekcja 4/Dane/Szczescie czy fart.txt', encoding = "UTF-8") 
      # Warto pamiętać o formacie kodowania polskich znaków 
a     

# Pliki tekstowe mogą być również wczytane jak pliki csv, jeśli tekst jest kolumną
# z tekstu:
b <- read.csv('Lekcja 4/Dane/komunikat_pl.txt',
              encoding = "UTF-8", # rozkodowanie
              header = F, # TRUE jeśli tekst ma nagłówki w pierwszym wierszu
              sep='|', # Musimy użyć separatora 'strange', czyli taki, którego nie znajdziemy w tekście
              stringsAsFactors = F) # jeśli nie chcemy, aby wektory znaków były zamienione na dane typu factor
b

# 4. Pakiet tm -----------------------------------------------------------------

# Jednym z najpopularniejszych pakietów do text mining jest pakiet tm.

# Aby zaimportować pliki, możemy skorzystać z dwóch metod, W praktyce różnica niewielka.
# Corpus() - tworzy zwykły Corpus
# VCorpus() - tworzy obiekt typu Volatile Corpus 

?VCorpus # możemy zajrzeć do pomocy

# Metody source'owania tekstu
getSources()

# setwd("..") Famous speeches
# Wczytanie tekstu z dokumentów
docs <-  VCorpus(DirSource('./Lekcja 4/Dane/minutes_nbp_en_text/', encoding = "UTF-8")) 
summary(docs)   

# Obiekt jest rozbudowaną listą:
docs[1]
docs[1][[1]]$meta # informacja o tekście
docs[1][[1]]$meta$author # informacja o autorze
docs[1][[1]]$meta
docs[1][[1]]$content

# zamiana Corpusu na data frame (będzie to potrzebne w pakiecie tidytext:
df <- data.frame(id = sapply(docs, function(x) x$meta$id), 
                 text = sapply(docs, function(x) x$content),
                 stringsAsFactors = F)

tb_df <- as_tibble(df)
tb_df

head(df, 1)

# 5. Pliki docx i doc ----------------------------------------------------------
docx <- textreadr::read_docx('Lekcja 4/Dane/Struktury.docx')
docx

str(docx)
