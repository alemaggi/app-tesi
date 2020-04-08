from bs4 import BeautifulSoup
import requests as rq
import re
import csv
from recipe_scrapers import scrape_me
import json

baseUrl = 'https://www.giallozafferano.it/ricette-cat/Antipasti/'

#lista contenente i link alle pagine con le singole ricette
urlList = []
urlList.append(baseUrl)

recipeLinks = []

#genero gli url delle pagine (Per ora mi fermo a 4)
for i in  range(2, 5):
    tmpUrl = 'https://www.giallozafferano.it/ricette-cat/page'+ str(i) + '/Antipasti/'
    urlList.append(tmpUrl)

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
            recipeLinks.append(a)
            
#Prendo le calorie di ogni ricetta
def estrapola_calorie(source):
    soup = BeautifulSoup(source, 'html.parser')
    div_list = soup.find_all("div", class_='gz-text-calories-total')
    if div_list:
        for span in div_list:
            s = span.find('span').get_text()
            return s

#Prendo altre informazioni per ogni ricetta
def estrapola_informazioni(source):
    soup = BeautifulSoup(source, 'html.parser')
    div_list = soup.find_all("div", class_="gz-list-featured-data")
    span_list = soup.find_all("span", class_='gz-name-featured-data')
    if span_list:
        informazioni = []
        for span in span_list:
            s = span.find('strong').get_text()
            informazioni.append(s)
        return informazioni


#scraping di tuttle pagine
for page_link in urlList:
    source = estrapola_source(page_link)
    estrapola_a_class(source)
    

print("------------------------------------------------------------------------------------------")

#Ora lo faccio con gli antipasti
data = {}
data['ricette'] = []
for link in recipeLinks:
    scraper = scrape_me(link)
    info = estrapola_informazioni(estrapola_source(link))
    data['ricette'].append({
        'title': scraper.title(),
        'duration' : scraper.total_time(),
        'type': 'Antipasto',
        'calories': estrapola_calorie(estrapola_source(link)),
        'difficulty': info[0],
        'doses': info[3],
        'ingredients': [scraper.ingredients()],
        'prepration': [scraper.instructions()],
        'imageLink': scraper.image(),
    })

with open('data.json', 'w') as outfile:
    json.dump(data, outfile, indent=4)
