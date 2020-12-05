### Sławomir Kranc ###
# Ścieżka dostępu - uwaga należy wpisać indywidualną!
setwd('C:/Users/SK/Documents')

# Wczytanie pakietów
library(tidyverse)
library(tidytext)
library(tm)
library(stopwords)
library(textstem)
library(hunspell)
library(pdftools)
library(tibble)
library(dplyr,warn.conflicts = TRUE)

###-------------------- DZIAŁANIE WSTĘPNE--------------------###
### KONWERSJA i WSTĘPNE CZYSZCZENIE PIERWOTNYCH PLIKÓW .PDF DO PLIKÓW .TXT ###
### DZIAŁANIE NIEZBĘDNE DO POŹNIEJSZEGO PRAWIDŁOWEGO DZIAŁANIA PAKIETU TIDYTEXT ###

lista_plikow_pdf <- dir('Lekcja 5/Dane/rpp_pl/')
lista_plikow_pdf

# Pusta lista dokumentów
dokumenty_pdf <- list()

# Pętla - kolejno importowane są kolejne pliki. 
# Dodatkowo, prezentujemy dwie funkcje
# tekstowe (sprintf i str_interp) do umieszczania placeholderów w stringach.
for(i in lista_plikow_pdf){
  dokumenty_pdf[[i]] <- pdf_text(sprintf('Lekcja 5/Dane/rpp_pl/%s', i)) 
  print(str_interp("Plik ${i} wczytany"))
}

# Scalanie tekstów w jedną obserwację:
dokumenty_pdf <- lapply(dokumenty_pdf, function(x) paste(x, collapse = ' '))
dokumenty_pdf <- lapply(dokumenty_pdf, paste, collapse = ' ')
dokumenty_pdf[[1]]

# Podzielenie dokumentu na linijki:
dokumenty_pdf <- lapply(dokumenty_pdf, strsplit, split = '\r\n', fixed = T)
dokumenty_pdf[[1]]

# Zredukowanie głębokości listy:
dokumenty_pdf <- lapply(dokumenty_pdf, function(x) x[[1]])
dokumenty_pdf[[1]]

# Usunięcie spacji z początku i końca linijki:
dokumenty_pdf <- lapply(dokumenty_pdf, str_trim)
dokumenty_pdf[[1]]

# Linijki dokumentów połączmy teraz w jedną obserwację.
dokumenty_pdf[[1]]
dokumenty_pdf <- lapply(dokumenty_pdf, paste, collapse = ' ')
dokumenty_pdf[[1]]

# Zamienimy jeszcze listę na dataframe.
dok_df <- data.frame(id = names(dokumenty_pdf), text = unlist(dokumenty_pdf))

# Zapiszemy teraz pliki w formie txt. 
dir.create('Lekcja 5/Dane/rpp_pl_txt') 
mapply(function(x, y) writeLines(x, con = sprintf('Lekcja 5/Dane/rpp_pl_txt/%s.txt', y)), 
       x = dokumenty_pdf, y = names(dokumenty_pdf))





###--------------------Pakiet tidytext--------------------###


#### WCZYTYWANIE DANYCH SPOSÓB 1 (PĘTLA) ###
lista_plikow_txt <- dir('Lekcja 5/Dane/rpp_pl_txt/')
lista_plikóW_txt

# Pusta lista dokumentów
dokumenty_txt <- list()


for(i in lista_plikow_txt){
  dokumenty_txt[[i]] <- readLines(sprintf("Lekcja 5/Dane/rpp_pl_txt/%s", i, encoding = "UTF-8"))
  print(str_interp("Plik ${i} wczytany"))
}
dokumenty_txt[[1]]
view(dokumenty_txt)

# Usuńmy puste linie
dokumenty_txt <- dokumenty_txt[dokumenty_txt != '']

# Konwesja na data.frame
dokumenty_txt_df <- data_frame(line = 1:length(dokumenty_txt), tekst = dokumenty_txt)
dokumenty_txt_df

# Teraz możemy przejść do procesu tokenizacji 
dokumenty_txt_long <- dokumenty_txt_df %>% 
  unnest_tokens(word, # nazwa kolumny z tokenami (output)
                tekst) # nazwa kolumny z tokenizowanym tekstem (input)

# Domyślną jednostką tokenizacji jest 1 słowo/wyraz:
dokumenty_txt_long
view(dokumenty_txt_long)

# Na początku musimy zaimportować listę polskich stopwords:
pl_stop_words <- readLines("Lekcja 5/Dane/polski/polish_stopwords.txt", encoding = "UTF-8")

pl_stop_words <- str_split(pl_stop_words, ', ', simplify = T)
pl_stop_words <- drop(pl_stop_words)

# data frame
stopwords_pl <- data_frame(word = pl_stop_words)
stopwords_pl

# Aby pozbyć się tych słów, będziemy używać funkcji anti_join (dplyr)
dokumenty_txt_long <- dokumenty_txt_df %>% 
  unnest_tokens(word, tekst) %>% 
  anti_join(stopwords_pl)

dokumenty_txt_long

# Lematyzacja

# Lokalizacja polskiego słownika (nie jest domyślny)
Sys.setenv(DICPATH = './Lekcja 5/Dane/polski')

#Policzenie lematyzacji
dokumenty_txt_long <- dokumenty_txt_long %>%
  mutate(word2 = hunspell_stem(word, dict = dictionary('pl_PL')))

dokumenty_txt_long
View(dokumenty_txt_long)

# Obiekt jest skomplikowany, Uprośćmy:
dokumenty_txt_long$word3 <- unlist(lapply(dokumenty_txt_long$word2, function(x) x[1]))
dokumenty_txt_long

# Czasami są braki danych. Spróbujmy je wyeliminować:
dokumenty_txt_long <- dokumenty_txt_long %>% 
  mutate(word4 = ifelse(is.na(word3), word, word3))

#Zobaczmy
View(dokumenty_txt_long)





###--------------------Pakiet tm--------------------###
dfCorpus <- VCorpus(DirSource('Lekcja 5/Dane/rpp_pl_txt//')) 
dfCorpus

# Zamieniamy duże litery na małe:
dfCorpus <- tm_map(dfCorpus, content_transformer(tolower))
inspect(dfCorpus[[1]])

# Usuńmy cyfry
dfCorpus <- tm_map(dfCorpus, removeNumbers)
inspect(dfCorpus[[1]])

# Usunięcie niepotrzebnych słów:
dfCorpus <- tm_map(dfCorpus, removeWords, pl_stop_words)
inspect(dfCorpus[[1]])

# Usuńmy znaki niedrukowalne (https://pl.wikipedia.org/wiki/Znaki_niedrukowalne)
dfCorpus <- tm_map(dfCorpus, stripWhitespace)
inspect(dfCorpus[[1]])

# Usuńmy interpunkcję:
dfCorpus <- tm_map(dfCorpus, removePunctuation)
inspect(dfCorpus[[1]])

# Do lematyzacji musimy napisać funkcję...
pl_stemmer <- content_transformer( function(txt) {
  paste(
    sapply(hunspell_stem(strsplit(txt, " ")[[1]], dic = 'pl_PL'), function(x) x[1]), 
    collapse = ' ')
})

dfCorpus <- tm_map(dfCorpus, pl_stemmer)
inspect(dfCorpus[[1]])

# Pojawiają się braki danych, może się ich pozbyć przez custom stopwords:
dfCorpus <- tm_map(dfCorpus, removeWords, 'NA')
dfCorpus <- tm_map(dfCorpus, stripWhitespace)

inspect(dfCorpus[[1]])
