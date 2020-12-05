### Sławomir Kranc ###
# Ścieżka dostępu - uwaga należy wpisać indywidualną!
setwd('...')
setwd('C:/Users/SK/Documents')


# Biblioteki
library(pdftools)
library(tidyverse)
library(tm)
library(textreadr)


# Stworzenie listy plików
lista_plikow <- dir('Lekcja 4/Dane/rpp_en/')
lista_plikow

# Pusta lista dokumentów
dokumenty <- list()

# Pętla - kolejno importowane są kolejne pliki. 
# Dodatkowo, prezentujemy dwie funkcje
# tekstowe (sprintf i str_interp) do umieszczania placeholderów w stringach.
for(i in lista_plikow){
  dokumenty[[i]] <- pdf_text(sprintf('Lekcja 4/Dane/rpp_en/%s', i)) #placeholder
  print(str_interp("Plik ${i} wczytany"))
}



# Scalanie tekstów w jedną obserwację:
dokumenty <- lapply(dokumenty, function(x) paste(x, collapse = ' '))
dokumenty <- lapply(dokumenty, paste, collapse = ' ')
dokumenty[[1]]

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

# 1. Data publikacji (1 linijka):
data_publikacji <- sapply(dokumenty, function(x) x[1])
data_publikacji

# Ekstrakcja daty:
data_publikacji <- str_extract(data_publikacji, '[0-9].*')
data_publikacji


# 2. Stopa_referencyjna (5 linijka)
stopa_referencyjna <- sapply(dokumenty, function(x) x[5])
stopa_referencyjna


# Ekstrakcja stopy:
stopa_referencyjna <- str_extract(stopa_referencyjna, '[0-9].[0-9].%')
stopa_referencyjna


# 3. Stopa_lombardowa (6 linijka)
stopa_lombardowa <- sapply(dokumenty, function(x) x[6])
stopa_lombardowa

# Ekstrakcja stopy:
stopa_lombardowa <- str_extract(stopa_lombardowa, '[0-9].[0-9].%')
stopa_lombardowa


# 4. Stopa_depozytowa (7 linijka)
stopa_depozytowa <- sapply(dokumenty, function(x) x[7])
stopa_depozytowa

# Ekstrakcja stopy:
stopa_depozytowa <- str_extract(stopa_depozytowa, '[0-9].[0-9].%')
stopa_depozytowa


# 5. Stopa_redyskonta (8 linijka)
stopa_redyskonta <- sapply(dokumenty, function(x) x[8])
stopa_redyskonta

# Ekstrakcja stopy:
stopa_redyskonta <- str_extract(stopa_redyskonta, '[0-9].[0-9].%')
stopa_redyskonta


# 6. Stan (4 linijka)
stan <- sapply(dokumenty, function(x) x[4])
stan

# Ekstrakcja stanu:
stan <- str_extract(stan, 'rates.*')
stan


# 7. Inflacja CPI (linijka, która zawiera frazę 'CPI inflation:'
inflacja_cpi <- sapply(dokumenty, function(x) x[which(str_detect(x,'CPI inflation'))])
inflacja_cpi


# zamienimy teraz tekst na datę. W tym celu zmienimy daty na anglosaskie:
Sys.setlocale("LC_TIME", "C")


# Linijki dokumentów połączmy teraz w jedną obserwację.
dokumenty[[1]]
dokumenty <- lapply(dokumenty, paste, collapse = ' ')
dokumenty[[1]]

# Zamienimy jeszcze listę na dataframe.
dok_df <- data.frame(id = names(dokumenty), text = unlist(dokumenty))
head(dok_df)

# przypiszmy date do df
dok_df$rok <- data_publikacji
dok_df$miesiac <- data_publikacji



# tworzenie kolumn roku i miesiąca wraz z danymi
dok_df$rok <- as.Date(data_publikacji, '%d %B %Y')
dok_df$rok <- str_extract(data_publikacji, '20[0-2][0-9]')

dok_df$miesiac <- as.Date(data_publikacji, '%d %B %Y')
dok_df$miesiac <- str_extract(data_publikacji, "\\s.*\\s")

dok_df$stopa_referencyjna <- stopa_referencyjna

dok_df$stopa_lombardowa <- stopa_lombardowa

dok_df$stopa_depozytowa <- stopa_depozytowa

dok_df$stopa_redyskonta <- stopa_redyskonta

dok_df

# Tabela
dok_tbl <- as.tbl(dok_df)
dok_tbl


#Przekształcanie danych string na float
float_ref <- readr::parse_number(stopa_referencyjna)
float_lom <- readr::parse_number(stopa_lombardowa)
float_dep <- readr::parse_number(stopa_depozytowa)
float_red <- readr::parse_number(stopa_redyskonta)
graph_date <- as.Date(data_publikacji, '%d %B %Y')

#Tworzenie data frame - data i dane %
ref_graph <- data.frame(graph_date, float_ref)
lom_graph <- data.frame(graph_date, float_lom)
dep_graph <- data.frame(graph_date, float_dep)
red_graph <- data.frame(graph_date, float_red)

# Wykres - wysokość referencyjnej stopy procentowej w skali czasu
plot(ref_graph$float_ref~ref_graph$graph_date, main="Wysokość referencyjnej stopy procentowej w skali czasu", type="b", lwd=3, col=rgb(0.1,0.7,0.1,0.8), ylab="Wysokość stopy [%]", xlab="Oś czasu")

# Wykres - wysokość lombardowej stopy procentowej w skali czasu
plot(lom_graph$float_lom~dep_graph$graph_date, main="Wysokość lombardowej stopy procentowej w skali czasu", type="b", lwd=3, col=rgb(0.1,0.1,0.3,0.9), ylab="Wysokość stopy [%]", xlab="Oś czasu")

# Wykres - wysokość depozytowej stopy procentowej w skali czasu
plot(dep_graph$float_dep~dep_graph$graph_date, main="Wysokość depozytowej stopy procentowej w skali czasu", type="b", lwd=3, col=rgb(0.1,0.7,0.8,0.9), ylab="Wysokość stopy [%]", xlab="Oś czasu")

# Wykres - wysokość redyskontowej stopy procentowej w skali czasu
plot(dep_graph$float_dep~dep_graph$graph_date, main="Wysokość redyskontowej stopy procentowej w skali czasu", type="b", lwd=3, col=rgb(0.7,0.3,0.3,0.7), ylab="Wysokość stopy [%]", xlab="Oś czasu")


#Tworzenie folderu i zapisanie danych do pliku.
dir.create('Lekcja 4/Dane/pliki') 
mapply(function(x, y) writeLines(x, con = sprintf('Lekcja 4/Dane/pliki/%s.txt', y)), 
       x = dokumenty, y = names(dokumenty))
