import urllib.request
import xml.etree.ElementTree as ET
import json
import time
from os import path

#url = "https://www.predictit.org/api/marketdata/all/"
#response = urllib.request.urlopen(url).read()
#markets = json.loads(response.decode("utf-8"))['markets']
#arr = []
#ids = []
#i = 0
#for market in markets:
#	ids.append(market['id'])
#	if "party will win" in market['shortName'] and 'presidential' in market['name']:
#		i+=1
#		arr.append((market['id'], market['shortName'][len("Which party will win "):-len(" in 2020?")]))
#for id in range(6500, 6700):
#	if id in ids: continue
#	url = "https://www.predictit.org/api/marketdata/markets/" + str(id)
#	try:
#		response = urllib.request.urlopen(url).read()
#	except urllib.error.HTTPError:
#		continue
#	market = json.loads(response.decode("utf-8"))
#	print(market)
#	if "party will win" in market['shortName'] and 'presidential' in market['name']:
#		i+=1
#		arr[id] = market['shortName']
#	time.sleep(1)
#
#print(ids)
#print(arr)
#print(i)
#
#for id, state in arr:
#	if path.exists(state+".json"): continue
#	url = "https://www.predictit.org/api/Public/GetMarketChartData/" + str(id) + "?timespan=7d&maxContracts=6&showHidden=true"
#	response = urllib.request.urlopen(url).read()
#	data = json.loads(response.decode("utf-8"))
#	with open(str(state) + ".json", "w+") as file:
#		file.write(str(data))
#	time.sleep(3)
while True:
	id = input("Enter id: ")
	state = input("Enter state: ")
	
	url = "https://www.predictit.org/api/Public/GetMarketChartData/" + str(id) + "?timespan=7d&maxContracts=6&showHidden=true"
	response = urllib.request.urlopen(url).read()
	data = json.loads(response.decode("utf-8"))
	with open(str(state) + ".json", "w+") as file:
		file.write(str(data))
