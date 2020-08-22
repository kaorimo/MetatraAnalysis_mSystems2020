#!/usr/bin/env python
# coding:utf-8

import sys
import pandas as pd
from collections import Counter

sample = sys.argv[1]   # insitu_6_2
stabilizationmethod = sys.argv[2]   # insitu

if stabilizationmethod == 'insitu':
    samples = ['insitu_6_2','insitu_8_1','insitu_9_1','insitu_10_1','insitu_11_1','insitu_12_1']
else:
    samples = ['onboard_1_2','onboard_2_2','onboard_7_1','onboard_8_1','onboard_9_1','onboard_10_1','onboard_11_1']

### datasets
def concat_dataframe():
    dfall=pd.DataFrame()
    for i in range(samples):
        df = pd.read_csv('Data/'+samples[i]+'_retrieved', header = 0, index_col=0, sep="\t")
        dfall = pd.concat([dfall, df])
    return dfall
        
dfall = concat_dataframe()
dfsample = pd.read_csv('Data/'+sample+'_retrieved', header = 0, index_col=0, sep="\t")

### chosing the most frequent identifier
def search_rank_get_key(qlist_sub, dic_ranks):
    ranks = []
    dic_tmp = {}
    
    for i in range(len(qlist_sub)):
        rank = dic_ranks[qlist_sub[i]]               # frequency of identifier
        ranks.append(rank)
        dic_tmp[qlist_sub[i]] = rank
    keys = [k for k, v in dic_tmp.items() if v == max(ranks)][0]
    return keys

def chosing_the_most_frequent_identifier():
    dfoutput = pd.DataFrame(columns=["query_id", "subject_id"])

    slist = list(dfall.subject_id)
    dic_ranks = Counter(slist)                        # frequency of identifiers

    qlist = list(set(list(dfsample.query_id)))       # query list

    for j in range(len(qlist)):
        d={}
        d[qlist[j]] = list(dfall[dfall["query_id"] == qlist[j]]["subject_id"])     # annotations of query

        keys = search_rank_get_key(d[qlist[j]], dic_ranks)
        dfoutput.loc[j] = [qlist[j], str(keys)]
    return dfoutput

dfoutput = chosing_the_most_frequent_identifier()

dfoutput.to_csv('Data/' + sample + '_chosen', sep="\t")