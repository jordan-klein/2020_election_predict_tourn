import csv, os
import json

files = [f for f in os.listdir() if 'json' in f]

dict = {}
for file in files:
	market_map = {}
	with open(file, "r+") as f:
		markets = json.loads(f.read().replace("'", '"'))
	filtered_markets = [m for m in markets if "10-31" in m['date'] or "11-01" in m['date'] or "11-02" in m['date']]
	market_map["2020-10-31"] = {}
	market_map["2020-11-01"] = {}
	market_map["2020-11-02"] = {}
	for market in filtered_markets:
		market_map[market['date'][0:10]][market['contractName'][0]] = market['closeSharePrice']
	dict[file[:-len(".json")]] = market_map

with open('cleaned.csv', 'w+') as output:
	writer = csv.writer(output)
	for state in dict.keys():
		for date in dict[state].keys():
			rep_price = dict[state][date]["R"]
			dem_price = dict[state][date]["D"]
			writer.writerow([date, state, dem_price, rep_price])
