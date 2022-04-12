import requests
from bs4 import BeautifulSoup
import pandas as pd
from rich.console import Console

def fix_name(name):
	""" Fixes name for downloaded files
	"""
	name = name.replace("/", "")
	name = name.replace("\"", "")
	name = name.replace("é", "e")
	name = name.replace("'", " ")
	name = name.replace("ô", "o")
	return name

def cond(text):
	if "Regions" in text:
		return True
	if "Departements" in text:
		return True
	if "Communes" in text:
		return True
	return False

def get_download_url(url):
	""" Parse an url from www.observatoire-des-territoires.gouv.fr/ with download files.
		Return a list of the download links.
	"""
	req = requests.get(url)
	soup = BeautifulSoup(req.text, "html.parser")
	download_options = soup.find('select', id="download_list", class_ = 'form-select form-control')
	return [(fix_name(obj.text), obj['value']) for obj in download_options if cond(fix_name(obj.text))]

def download_file(file_url, dest_file):
	""" Download the file at {file_url} to local file {dest_file}.xlsx
	"""
	with requests.get(file_url) as resp:
		with open(dest_file+".xlsx", 'wb') as file:
			file.write(resp.content)

def create_csv(dest_file):
	""" Create local file {dest_file}.csv from {dest_csv}.xlsx
	"""
	read_xlsx = pd.read_excel(dest_file+".xlsx")
	read_xlsx.to_csv(dest_file+".csv", index = None, header = True)
	
def fixing_csv(dest_file):
	with open(dest_file+".csv", "r") as f_in: 
		data = f_in.readlines()[4:]
	with open(dest_file+".csv", "w") as f_out:
		f_out.writelines(data)


if __name__ == "__main__":
	cs = Console()
	url = "https://www.observatoire-des-territoires.gouv.fr/densite-de-population"
	dl_urls = get_download_url(url)
	n = len(dl_urls)
	f = lambda x, i: 3*x+i
	for url_i in range(n):
		dest_file, file_url = dl_urls[url_i]
		
		with cs.status(f"({f(url_i, 1)}/{f(n, 0)}) Downloading {dest_file[:24]}.xlsx..."):
			download_file(file_url, dest_file)
		print(f"✔ ({f(url_i, 1)}/{f(n, 0)}) Downloading {dest_file[:24]}.xlsx... DONE")
		
		with cs.status(f"({f(url_i, 2)}/{f(n, 0)}) Converting to {dest_file[:24]}.csv..."):
			create_csv(dest_file)
		print(f"✔ ({f(url_i, 2)}/{f(n, 0)}) Converting to {dest_file[:24]}.csv... DONE")
		
		with cs.status(f"({f(url_i, 3)}/{f(n, 0)}) Fixing {dest_file[:24]}.csv..."):
			fixing_csv(dest_file)
		print(f"✔ ({f(url_i, 3)}/{f(n, 0)}) Fixing {dest_file[:24]}.csv... DONE")
