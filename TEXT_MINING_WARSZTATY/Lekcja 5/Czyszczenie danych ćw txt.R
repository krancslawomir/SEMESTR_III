#---------------------------------------------------------#
#                       Text minign                       #
#                          CDV                            #
#                    Mateusz Samson                       #
#              Czyszczenie danych tekstowych              #
#---------------------------------------------------------#

# Ustawienie ścieżki dostępu (do folderu nadrzędnego)
setwd('...')

# Wczytanie pakietów
library(tidyverse)
library(tidytext)
library(tm)
library(stopwords)
library(textstem)
library(hunspell)
library(pdftools)


# 1. Czyszczenie plików po angielsku -------------------------------------------

# 1.1. Pakiet tidytext----------------------------------------------------------

# W tym pakiecie niemal cały proces możemy przeprowadzić dzięki funkcji unnest_tokens():
# Dodatkowe czynności można przeprowadzić za pomocą dobrze znanych funkcji 
# z pakietu\ stringr i wyrażeń regularnych.

# unnest_tokens(tbl, # data frame
#              output, 
#              input, 
#              token = "words", # inne opcje: "character", "ngrams", "character_shingles", 
#              to_lower = TRUE, # zamiana liter na małe
#              drop = TRUE, 
#              collapse = NULL, 
#              ...) # Extra arguments 

# Zaimportujmy tekst:
komunikat <- readLines("Lekcja 5/Dane/komunikat_en.txt", encoding = "UTF-8")

# Obejrzyjmy wyniki
View(komunikat)

# Usuńmy puste linie
komunikat <- komunikat[komunikat != '']

# Konwesja na data.frame
komunikat_df <- data_frame(line = 1:length(komunikat), tekst = komunikat)
komunikat_df

# Teraz możemy przejść do procesu tokenizacji
komunikat_long <- komunikat_df %>% 
  unnest_tokens(word, # nazwa kolumny z tokenami (output)
                tekst) # nazwa kolumny z tokenizowanym tekstem (input)

# Domyślną jednostką tokenizacji jest 1 słowo/wyraz:
komunikat_long

# Kilka innych przykładów:
komunikat_df %>% 
  unnest_tokens(sentence, # output
                tekst, # input
                token = "sentences") # jednostka tokenizacji

komunikat_df %>% 
  unnest_tokens(ngram, tekst, # output i input
                token = "ngrams", n = 2) # token to bigram

komunikat_df %>% 
  unnest_tokens(shingle, tekst,
                token = "character_shingles", n = 4)

# Możemy zdefiniować własne tokeny poprzez wyrażenia regularne
# a. ". " - tak jak w zdaniu
komunikat_df %>%
  unnest_tokens(zdanie, tekst, token = "regex", pattern = "\\. ")

# b. EOL (end of line) - każda linijka będzie tokenem
komunikat_df %>% 
  unnest_tokens(paragraf, tekst, token = "regex", pattern = "\n")

# Możemy również tokenować HTML 
h <- data_frame(row = 1:2,
                text = c("<h1>Tekst <b>jest</b>", "<a href='example.com'>tutaj</a>"))

h %>%
  unnest_tokens(word, text, format = "html")

# Więcej o tokenizerach używanych w tidytext:
browserURL('https://github.com/ropensci/tokenizers')
browserURL('https://stackoverflow.com/questions/44510086/preserve-punctuations-using-unnest-tokens-in-tidytext-in-r')

# Powróćmy teraz do naszego pierwszego przykładu. Nasz tekst wymaga naszej dalszej
# pracy. Nie wszystkie słowa, które są tokenami są ważne - zdecydowanie powinniśmy
# pozbyć się tak zwanych stopwords.

# Z uwzględnieniem angielskiej listy stopwords
komunikat_long <- komunikat_df %>% 
  unnest_tokens(word, tekst) %>% 
  anti_join(stop_words, by = 'word') # angielskie stopwords
komunikat_long

# Przyjrzyjmy się obiektowi:
stop_words

# Mamy kilka leksykonów
stop_words %>% 
  count(lexicon)

# Możem też wykorzystać pakiet stopwords:
help("stopwords")
stopwords_getsources()

for (i in stopwords_getsources()){
  print(i)
  if (i == 'misc') next
  print(length(stopwords(language = 'en', source = i)))
}

# Źródła:
help('stopwords-package')

# Pytanie oczywiście czy potrzebujemy liczby. W komunikatach NBP może to być ważne.

# Dzięki pakietowi hunspell można przeprowadzić lematyzację i inne operacje językowe:
hunspell_stem(c('meeting', 'meets', 'met'))

# Inne funkcje
hunspell_check('becuase') # sprawdzanie pisowni
hunspell_suggest('becuase') # proponowanie poprawek
hunspell_parse('Becuase I said so.') # jest też tokenizatorem
hunspell_analyze(c('meeting', 'meets', 'met'))

# Więcej informacji:
# https://cran.r-project.org/web/packages/hunspell/vignettes/intro.html#spell_checking

# Sprawdzanie pisowni:
komunikat_long <- komunikat_long %>%
  mutate(check = hunspell_check(word),
         suggest = ifelse(!check, hunspell_suggest(word), word))

komunikat_long$word2 <- sapply(komunikat_long$suggest, function(x) x[1])
komunikat_long

# Lematyzacja:
komunikat_long <- komunikat_long %>%
  mutate(word3 = hunspell_stem(word2))

komunikat_long$word3 <- sapply(komunikat_long$word3, function(x) x[1])


# Czasami są braki danych. Spróbujmy je wyeliminować:
komunikat_long <- komunikat_long %>% 
  mutate(word4 = ifelse(is.na(word3), word, word3))

# Zadanie wykonane:
komunikat_long

# Na marginesie, gdybyśmy  chcieli usunąć liczby z tego pliku, to zrobilibyśmy tak:
komunikat_long %>% 
  filter(!str_detect(word4, '[0-9]'))


# 1.2. Pakiet tm -----------------------------------------------------------------
getSources()

# Cały korpus za jednym zamachem:
dfCorpus <- Corpus(DirSource(paste0(getwd(),'/Lekcja 5/Dane/minutes_nbp_en_text_long/')))
dfCorpus

# Najpierw lista transformacji:
getTransformations()

# Zamieniamy duże litery na małe:
dfCorpus <- tm_map(dfCorpus, content_transformer(tolower))
inspect(dfCorpus[1])

# Usuńmy cyfry
dfCorpus <- tm_map(dfCorpus, removeNumbers)
inspect(dfCorpus[1])

# Usunięcie niepotrzebnych słów:
dfCorpus <- tm_map(dfCorpus, removeWords, tm::stopwords('en'))
inspect(dfCorpus[1])

# Usuńmy znaki niedrukowalne (https://pl.wikipedia.org/wiki/Znaki_niedrukowalne)
dfCorpus <- tm_map(dfCorpus, stripWhitespace)
inspect(dfCorpus[1])

# Usuńmy punktory 
dfCorpus <- tm_map(dfCorpus, removePunctuation)
inspect(dfCorpus[1])

# Następnie stemming dokumentu...
dfCorpus_stem <- tm_map(dfCorpus, stemDocument)
inspect(dfCorpus_stem[1])

# Lematyzacja tekstu (inny lematyzator, hunspell nie działa)
dfCorpus_lem <- tm_map(dfCorpus, content_transformer(lemmatize_strings))
inspect(dfCorpus_lem[1])

# Można też wszystko umieścić w jednej funkcji. Kolejność nie jest przypadkowa
clean.corpus <- function(corpus){
  corpus <- tm_map(corpus, tolower) 
  corpus <- tm_map(corpus, removeWords, stopwords('en')) 
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace) 
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, stemDocument)
  return(corpus)
}

dfCorpus <- Corpus(DirSource('Lekcja 5/Dane/minutes_nbp_en_text_long/')) 
inspect(dfCorpus[1])
dfCorpus <-  clean.corpus(dfCorpus)
inspect(dfCorpus[1])

# Ciekawostka - inne stemmery
library(SnowballC)

# Przykład steminizacji
wordStem(c('loving', 'loves', 'love', 'lovestory', 'loved', 'lovely', 'lover'))

# Zobaczmy dostępne językki:
getStemLanguages() 

# Nie ma polskiego. Spróbujmy jest stemizator dostępny w pakiecie Rweka:
# system("java -version")
# Sys.setenv(JAVA_HOME = "C:/Program Files/Java/jdk-9.0.4/")
library(RWeka)

IteratedLovinsStemmer(c('loving', 'loves', 'love', 'lovestory', 'loved', 'lovely', 'lover'), control = NULL)
LovinsStemmer(c('loves', 'love', 'loved', 'lovely', 'lover'), control = NULL)

# są jeszcze inne pakiety do stemmingu/lematyzacji:
# https://github.com/trinker/textstem
# https://cran.r-project.org/web/packages/corpus/vignettes/stemmer.html

# 2. Czyszczenie dokumentów po polsku ------------------------------------------

# 2.1. Pakiet tidytext ---------------------------------------------------------

# Zaimportujmy tekst:
komunikat <- readLines("Lekcja 5/Dane/komunikat_pl.txt", encoding = "UTF-8")

# Obejrzyjmy wyniki
View(komunikat)

# Usuńmy puste linie
komunikat <- komunikat[komunikat != '']

# Konwesja na data.frame
komunikat_df <- data_frame(line = 1:length(komunikat), tekst = komunikat)
komunikat_df

# Teraz możemy przejść do procesu tokenizacji 
komunikat_long <- komunikat_df %>% 
  unnest_tokens(word, # nazwa kolumny z tokenami (output)
                tekst) # nazwa kolumny z tokenizowanym tekstem (input)

# Domyślną jednostką tokenizacji jest 1 słowo/wyraz:
komunikat_long

# Na początku musimy zaimportować listę polskich stopwords:
pl_stop_words <- readLines("Lekcja 5/Dane/polski/polish_stopwords.txt")

pl_stop_words <- str_split(pl_stop_words, ', ', simplify = T)
pl_stop_words <- drop(pl_stop_words)

# data frame
stopwords_pl <- data_frame(word = pl_stop_words)
stopwords_pl

# Aby pozbyć się tych słów, będziemy używać funkcji anti_join (dplyr)
komunikat_long <- komunikat_df %>% 
  unnest_tokens(word, tekst) %>% 
  anti_join(stopwords_pl)
komunikat_long

# Lematyzacja

# Lokalizacja polskiego słownika (nie jest domyślny)
Sys.setenv(DICPATH = './Lekcja 5/Dane/polski')

#Policzenie lematyzacji
komunikat_long <- komunikat_long %>%
  mutate(word2 = hunspell_stem(word, dict = dictionary('pl_PL')))
komunikat_long
View(komunikat_long)

# Obiekt jest skomplikowany, Uprośćmy:
komunikat_long$word3 <- unlist(lapply(komunikat_long$word2, function(x) x[1]))
komunikat_long

# Czasami są braki danych. Spróbujmy je wyeliminować:
komunikat_long <- komunikat_long %>% 
  mutate(word4 = ifelse(is.na(word3), word, word3))

#Zobaczmy
View(komunikat_long)

# 2.1. Pakiet tm ---------------------------------------------------------
dfCorpus <- VCorpus(DirSource('Lekcja 5/Dane/minutes_nbp_pl_text//')) 
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





# 3. Ćwiczenia ------------------------------------

# 1. Powtórz przekształcenia w pakietach tm lub tidytext, dla polskich komunikatów RPP.

