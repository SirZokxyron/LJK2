import requests
import html
import re
import csv
from bs4 import BeautifulSoup

# A first version v0.02 (naive)

def process(url):

    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')

    #print(soup.find_all('a', class_='departement')[0].get_text())

    # Opening DB.csv file in writing mode
    f = open('DB.csv', 'w')

    writer = csv.writer(f)

    # Filling the first row of the csv file
    writer.writerow(['Latitude', 'Longitude', 'Nom', 'URL', 'Type'])

    # Retrieving the links of all the departements
    for element in soup.find_all('a', class_='departement'):
        link = element['href']
        #print("##################################################################")
        #print(element.text)
        #L.append(element['href'])
        data = requests.get(link)
        soup = BeautifulSoup(data.text, 'html.parser')

        raw_data = soup.find_all('script')

        # Iterating over all the HTML elements with script tag
        for unit in raw_data:
            # If the keyword 'locations.push' is present in the text of the current element
            if 'locations.push' in unit.text:
                # Splitting according to the keyword 'locations.push' in the JS code
                # in which the author appends the information to the list
                data = unit.text.split('locations.push')
        
        # data is an array, we get rid of the very first and very last element
        # because they contain nothing interesting and we continue the investigation
        # of the elements in between
        for i in data[1:-1]:
            DB = []
            # Again, splitting by comma
            for j in i.split(','):
                # Getting rid of "irrelevant" characters
                j = j.replace('([','').replace(']);','').replace('\n','').replace('"','')
                j = re.split('  +', j) # Splitting according to two spaces or more
                j = list(filter(None, j)) # Getting rid of empty elements

                if j: # In case j is not empty
                    DB.append(html.unescape(j[0])) # Decoding HTML entities of special caracters

            writer.writerow(DB) # Writing the row into the csv file [DB.csv]

    # End of Writing 
    f.close()


# EXECUTION #
url = 'https://ma-dechetterie.fr/'
process(url)