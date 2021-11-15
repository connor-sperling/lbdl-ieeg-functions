import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


def write_pairs(df, rreg, creg, pair, pair_path):
	df_pair = df[(df['R_Region']==rreg) & (df['C_Region']==creg)]
	if rreg != creg:
		df_pair.append(df[(df['R_Region']==creg) & (df['C_Region']==rreg)])
	# df_pair.to_excel("%s/%s_connections.xlsx" %(pair_pth, pair))
	if len(pd.unique(df_pair["Subj"])) > 2:
		print(pair, df_pair.size, pd.unique(df_pair["Subj"]), pd.unique(df_pair["Condition"]))#, pd.unique(df_pair["Lock"]), pd.unique(df_pair["Band"]))

def choose_regions():
	region1 = input("Choose first region: ")
	region2 = input("Choose second reigon: ")
	return (region1, region2)


separation = "SubTaskCongruency" 
file = "connections_Average-%s-PoO.xlsx" % separation
path = "/Volumes/LBDL_Extern/bdl-raw/iEEG_San_Diego/Subjs/thesis/undirected_connectivity/connections/Stroop_CIC-CM"

zeros = False
user_input = True
pair_path = "%s/connection_tables/%s" %(path,separation)

dfwz = pd.read_excel("%s/%s" %(path,file))
dfnz = dfwz[dfwz["Weight"]!=0]

pair_list = []

if zeros:
	df = dfwz
	pair_pth = "%s/connection_tables/%s" %(path,separation)
else:
	df = dfnz
	pair_pth = "%s/connection_tables/%s/no_zeros" %(path,separation)

row_regions = df["R_Region"]
col_regions = df["C_Region"]

if user_input:
	ureg1, ureg2 = choose_regions()
else:
	ureg1 = ureg2 = ''

for rreg, creg in zip(row_regions, col_regions):
	pair = "%s_%s" %(rreg, creg)
	pair_rev = "%s_%s" %(creg,rreg)
	if pair in pair_list or pair_rev in pair_list:
		continue 
	else:
		pair_list.append(pair)

	if not ureg1 and not ureg2:
		write_pairs(df, rreg, creg, pair, pair_path)
	if not ureg2:
		if ureg1 in pair:
			write_pairs(df, rreg, creg, pair, pair_path)
	else:
		if ureg1 in pair and ureg2 in pair:
			write_pairs(df, rreg, creg, pair, pair_path)


