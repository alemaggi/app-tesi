from bs4 import BeautifulSoup
import requests as rq
import re
import csv

baseUrl = 'https://www.giallozafferano.it/ricette-cat/Antipasti/'

#lista contenente i link alle pagine con le singole ricette
urlList = []
urlList.append(baseUrl)

#genero gli url delle pagine (Per ora mi fermo a 4)
for i in  range(2, 5):
    tmpUrl = 'https://www.giallozafferano.it/ricette-cat/page'+ str(i) + '/Antipasti/'
    urlList.append(tmpUrl)

#stampa per controllare i link
print('[%s]' % ', '.join(map(str, urlList)))
print('------------')

#funzione per avere il sorgente di ogni pagina
def estrapola_source(url):
    return(rq.get(url).text)

#Prendo tutti i link alle ricette
def estrapola_a_class(source):
    soup = BeautifulSoup(source, 'html.parser')
    div_list = soup.find_all("div", class_='gz-link-more-recipe')
    if div_list:
        for div in div_list:
            a = div.find('a').attrs['href']
            print(a)

#scraping di tuttle pagine dei tornei
for page_link in urlList:
    source = estrapola_source(page_link)
    estrapola_a_class(source)
