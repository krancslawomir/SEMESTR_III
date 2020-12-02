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


# 2.1. Pakiet tidytext ---------------------------------------------------------

lista_plikow <- dir('Lekcja 5/Dane/rpp_pl/')
lista_plikow

# Pusta lista dokumentów
dokumenty <- list()


# Wczytywanie danych
for(i in lista_plikow){
  dokumenty[[i]] <- read.delim(sprintf('Lekcja 5/Dane/rpp_pl/%s', i)) #placeholder
  print(str_interp("Plik ${i} wczytany"))
}

# Obejrzyjmy wyniki
View(dokumenty)

# Usuńmy puste linie
dokumenty <- dokumenty[dokumenty != '']

# Konwesja na data.frame
dokumenty_df <- data_frame(line = 1:length(dokumenty), tekst = dokumenty)
dokumenty_df
View(dokumenty_df)

# Teraz możemy przejść do procesu tokenizacji ### UWAGA NIE DZIAŁA! ###
dokumenty_long <- dokumenty_df %>% 
  unnest_tokens(word, # nazwa kolumny z tokenami (output)
                tekst) # nazwa kolumny z tokenizowanym tekstem (input)

# Domyślną jednostką tokenizacji jest 1 słowo/wyraz:
dokumenty_long

# Na początku musimy zaimportować listę polskich stopwords:
pl_stop_words <- readLines("Lekcja 5/Dane/polski/polish_stopwords.txt")

pl_stop_words <- str_split(pl_stop_words, ', ', simplify = T)
pl_stop_words <- drop(pl_stop_words)

# data frame
stopwords_pl <- data_frame(word = pl_stop_words)
stopwords_pl

# Aby pozbyć się tych słów, będziemy używać funkcji anti_join (dplyr)
dokumenty_long <- dokumenty_df %>% 
  unnest_tokens(word, tekst) %>% 
  anti_join(stopwords_pl)
dokumenty_long

# Lematyzacja

# Lokalizacja polskiego słownika (nie jest domyślny)
Sys.setenv(DICPATH = './Lekcja 5/Dane/polski')

#Policzenie lematyzacji
dokumenty_long <- dokumenty_long %>%
  mutate(word2 = hunspell_stem(word, dict = dictionary('pl_PL')))
dokumenty_long
View(dokumenty_long)

# Obiekt jest skomplikowany, Uprośćmy:
dokumenty_long$word3 <- unlist(lapply(dokumenty_long$word2, function(x) x[1]))
dokumenty_long

# Czasami są braki danych. Spróbujmy je wyeliminować:
dokumenty_long <- dokumenty_long %>% 
  mutate(word4 = ifelse(is.na(word3), word, word3))

#Zobaczmy
View(dokumenty_long)






# 2.2. Pakiet tm ---------------------------------------------------------
dfCorpus <- VCorpus(DirSource('Lekcja 5/Dane/rpp_pl//')) 
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

# Usuńmy znaki niedrukowalne:
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

