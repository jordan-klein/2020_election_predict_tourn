import csv, os
from datetime import datetime

files = []
for file in os.listdir("."):
	if ".csv" in file and "final" not in file: files.append(file)

files.sort()
with open('final.csv', 'w+', newline='') as output:
	writer = csv.writer(output)
	header = ["Date", "State", "Dem_Price", "Rep_Price"]
	writer.writerow(header)	
	for file in files:
		state = file[:-4]
		with open(file, 'r', newline='') as input:
			reader = csv.reader(input)
			header = next(reader)
			for row in reader:
				row2 = next(reader)
				date = datetime.strptime(row[1], '%m/%d/%Y %I:%M:%S %p')
				date = date.strftime("%Y-%m-%d")

				dem = row if "Dem" in row[0] else row2
				rep = row if "Rep" in row[0] else row2

				writer.writerow([date, state, dem[5][1:], rep[5][1:]])
