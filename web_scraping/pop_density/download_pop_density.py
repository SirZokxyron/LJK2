import requests
from bs4 import BeautifulSoup
import pandas as pd
from rich.progress import Progress

def fix_name(name):
	""" Fixes name for downloaded files
	"""
	name = name.replace("/", "")
	name = name.replace("\"", "")
	name = name.replace("é", "e")
	name = name.replace("'", " ")
	name = name.replace("ô", "o")
	return name

def get_download_url(url):
	""" Parse an url from www.observatoire-des-territoires.gouv.fr/ with download files.
		Return a list of the download links.
	"""
	req = requests.get(url)
	soup = BeautifulSoup(req.text, "html.parser")
	download_options = soup.find('select', class_ = 'form-select form-control')
	return [(fix_name(obj.text), obj['value']) for obj in download_options]

def download_file(file_url, dest_file):
	""" Download the file at {file_url} to local file {dest_file}.xlsx
	"""
	obj = requests.get(file_url)
	with open(dest_file+".xlsx", 'wb') as file:
		file.write(obj.content)

def create_csv(dest_file):
	""" Create local file {dest_file}.csv from {dest_csv}.xlsx
	"""
	read_xlsx = pd.read_excel(dest_file+".xlsx")
	read_xlsx.to_csv(dest_file+".csv", index = None, header = True)

if __name__ == "__main__":
	url = "https://www.observatoire-des-territoires.gouv.fr/densite-de-population"
	dl_urls = get_download_url(url)
	with Progress(auto_refresh=False) as prg:
		main_task = prg.add_task("[green]Overall progress", total=len(dl_urls))
		for dest_file, file_url in dl_urls:
			sub_task = prg.add_task(f"[blue]Processing {dest_file[:24]}...", total=2)
			download_file(file_url, dest_file)
			prg.update(sub_task, advance=1)
			prg.refresh()
			create_csv(dest_file)
			prg.update(sub_task, advance=1)
			prg.update(main_task, advance=1)
			prg.refresh()
