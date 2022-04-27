import requests
from bs4 import BeautifulSoup
import pandas as pd
from rich.console import Console
from os.path import exists

def download_file(file_url, dest_file):
	""" Download the file at {file_url} to local file {dest_file}.xlsx
	"""
	with requests.get(file_url) as resp:
		with open(dest_file+".xlsx", 'wb') as file:
			file.write(resp.content)

def create_csv(file):
	""" Create local file {file}.csv from {dest_csv}.xlsx
	"""
	read_xlsx = pd.read_excel(file+".xlsx")
	read_xlsx.to_csv(file+".csv", index = None, header = True)
	
def remove_first_lines(file, n):
	""" Removes the first {n} lines of the given {file}.
	"""
	with open(file, "r") as f_in: 
		data = f_in.readlines()[n:]
	with open(file, "w") as f_out:
		f_out.writelines(data)

def remove_lines_between(file, a, b):
	""" Removes the lines between {a} and {b} of the given {file}.
	"""
	with open(file, "r") as f_in: 
		data = f_in.readlines()
	with open(file, "w") as f_out:
		f_out.writelines(data[:a])
		f_out.writelines(data[b:])

def remove_last_lines(file, n):
	""" Removes the last {n} lines of the given {file}.
	"""
	with open(file, "r") as f_in: 
		data = f_in.readlines()
		data = data[:len(data)-n]
	with open(file, "w") as f_out:
		f_out.writelines(data)

if __name__ == "__main__":
	cs = Console()

	# Retrieve download links from our txt
	with open("download_links.txt") as file:
		urls = [url.split(',') for url in file.read().splitlines()]

	n = len(urls)
	
	f = lambda x, i: 3*x+i

	for i in range(n):
		# Get the current filename and url to process
		dest_file, file_url = urls[i]
		
		# Check if file was already previously downloaded
		if (not exists(dest_file+".xlsx")):
			with cs.status(f"({f(i, 1)}/{f(n, 0)}) Downloading {dest_file[:24]}.xlsx..."):
				download_file(file_url, dest_file)		# Download the file from the url
			print(f"\x1b[32m✔\x1b[0m ({f(i, 1)}/{f(n, 0)}) Downloading {dest_file[:24]}.xlsx... \x1b[32mDONE\x1b[0m")
		
		if (not exists(dest_file+".csv")):
			with cs.status(f"({f(i, 2)}/{f(n, 0)}) Converting to {dest_file[:24]}.csv..."):
				create_csv(dest_file)					# Convert the .xlsx to the .csv
			print(f"\x1b[32m✔\x1b[0m ({f(i, 2)}/{f(n, 0)}) Converting to {dest_file[:24]}.csv... \x1b[32mDONE\x1b[0m")
			
			with cs.status(f"({f(i, 3)}/{f(n, 0)}) Removing first 4 lines of {dest_file[:24]}.csv..."):
				remove_first_lines(dest_file+".csv", 4)	# Remove the first 4 lines of the newly created .csv
			print(f"\x1b[32m✔\x1b[0m ({f(i, 3)}/{f(n, 0)}) Removing first 4 lines of {dest_file[:24]}.csv... \x1b[32mDONE\x1b[0m")

	print("\x1b[34mAdditionnal Cleaning\x1b[0m: Do you want to remove Overseas France ? (\x1b[32m[y]es\x1b[0m/\x1b[31m[n]o\x1b[0m)", end=" ")
	usr_inp = input().lower()
	while usr_inp != 'y' and usr_inp != 'n':
		print("\x1b[31mError\x1b[0m: Invalid input.")
		print("\x1b[34mAdditionnal Cleaning\x1b[0m: Do you want to remove Overseas France ? ([y]es/[n]o)", end=" ")
		usr_inp = input().lower()

	# Leaving if all good
	if (usr_inp == 'n'): exit(0)

	# More filtering in the .csv
	file_commune = urls[0][0]+".csv"
	file_departe = urls[1][0]+".csv"
	file_regions = urls[2][0]+".csv"

	# Fix communes
	remove_last_lines(file_commune, 1032)
	print(f"\x1b[32m✔\x1b[0m (1/3) Removing Overseas France from {file_commune[:24]}... \x1b[32mDONE\x1b[0m")

	# Fix departements
	remove_last_lines(file_departe, 55)
	print(f"\x1b[32m✔\x1b[0m (2/3) Removing Overseas France from {file_departe[:24]}... \x1b[32mDONE\x1b[0m")

	# Fix regions
	remove_lines_between(file_regions, 1, 56)
	print(f"\x1b[32m✔\x1b[0m (3/3) Removing Overseas France from {file_regions[:24]}... \x1b[32mDONE\x1b[0m")
