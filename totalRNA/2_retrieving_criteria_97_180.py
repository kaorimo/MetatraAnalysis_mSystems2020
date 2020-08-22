#!/usr/bin/env python
# coding:utf-8

import sys
import pandas as pd
import numpy as np

sample = sys.argv[1]    # ex "insitu_6_2"

def retrieving_criteria(sample): 
    # criteria: identity >= 97%, alignmentlength >= 180
    blast_result = "Data/" + sample + "_200_1e-20"
    df = pd.read_csv(blast_result, header = None, sep="\t")
    df.columns = ["query_id", "subject_id", "identity", "alignmentlength", "mismatches", "gap_opens", "q_start", "q_end", "s_start", "s_end", "evalue", "bitscore"]

    df_dat = df[(df["identity"] >= 97) & (df["alignmentlength"] >= 180)]
    
    # retrieve top hit with bitscore
    query_list = list(df_dat.drop_duplicates(subset='query_id').loc[:,'query_id'])
    df_output = pd.DataFrame(columns = df_dat.columns)
    for i in range(len(query_list)):
            df_tmp = df_dat[df_dat['query_id'] == query_list[i]]
            df_score = df_tmp[df_tmp["bitscore"] == df_tmp["bitscore"].max()]
            
            df_output = pd.concat([df_output, df_score])
            
    return df_output

df_output = read_samples(sample)

df_output.to_csv('Data/'+sample+'_retrieved', sep="\t")