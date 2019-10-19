
import os
import math
import sys
import time
import copy
from tqdm import tqdm

import datetime

import numpy as np
import pandas as pd 
import matplotlib.pyplot as plt

import seaborn as sns

def datetime2unixtime(datetime_float):
    """
    e.g., datetime (float): 20180402072450 
    """
    
    datetime_str = str(datetime_float)
    
    year = int(datetime_str[:4])
    month = int(datetime_str[4:6])
    day = int(datetime_str[6:8])
    hour = int(datetime_str[8:10])
    minute = int(datetime_str[10:12])
    second = int(datetime_str[12:14])
    
    unixtime_str = datetime.datetime(year, month, day, hour, minute, second).timestamp()
    return unixtime_str


DATA_COLUMNS_NAME = ['taxiID', 'lng', 'lat', 'alt', 'time', 'azim', 'vel', 'gpstype', 'occ']

DATA_BASEDIR = "/home/gskim/data/CE545 Taxi/data"
TARGET_DATE_LIST = ["2018-04-03", "2018-04-07", "2018-04-10", "2018-04-14", 
                    "2018-04-17", "2018-04-21", "2018-04-24", "2018-04-28"]

TARGET_DURATION_NIGHT = ["000000", "040000"]

TARGET_DURATION_LIST = [TARGET_DURATION_NIGHT]

for TARGET_DURATION in TARGET_DURATION_LIST:
    print(TARGET_DURATION)

    for TARGET_DATE in TARGET_DATE_LIST:
        print("\n\n", TARGET_DATE)

        taget_date_dir = os.path.join(DATA_BASEDIR, TARGET_DATE)
        taget_date_files = os.listdir(taget_date_dir)
        taget_date_files.sort()
        print(taget_date_dir)
        
        taget_date_files_in_duration = []
        for filename in taget_date_files:
            if TARGET_DURATION[0] < filename[:-4] and filename[:-4] < TARGET_DURATION[1]:
                taget_date_files_in_duration.append(filename)
        print(taget_date_files_in_duration)
        print("\nThe number of files: ", len(taget_date_files_in_duration))

        # parse all data in the corresponding time duration 
        dfs = []
        for filename in taget_date_files_in_duration:
            # read
            df_path = os.path.join(taget_date_dir, filename)
            df = pd.read_csv(df_path)
            df.columns = DATA_COLUMNS_NAME  
            # add
            dfs.append(df)

        # merge and make all-in-one dataframe   
        df_all = pd.concat(dfs)   

        # for memory saving 
        del dfs
        df_all = df_all.drop("gpstype", axis=1)

        # grouping by taxi ID
        taxi_grouped = df_all.groupby('taxiID')
        taxi_grouped.count()

        #
        EVENT_OFF_TO_ON = 1
        EVENT_ON_TO_OFF = -1

        ## main
        taxi_id_dict = taxi_grouped.groups

        taxi_onoff_pair_history_start_flag = 0
        taxi_onoff_pair_history = None

        for for_idx, taxi_id in enumerate(tqdm(taxi_id_dict, mininterval=0.5)):                

            taxi = taxi_grouped.get_group(taxi_id)
            taxi = taxi.sort_values(["time"], ascending=[True])
            taxi = taxi.reset_index(drop=True)
            taxi_np = taxi.values

            OCC_COL_IDX = -1
            taxi_np_occ_diff = taxi_np[1:, OCC_COL_IDX] - taxi_np[:-1, OCC_COL_IDX] # EVENT_OFF_TO_ON = 1
            
            opertation_started = 0
            start_time = 0
            end_time = 0
            for occ_idx, occ_flag in enumerate(taxi_np_occ_diff.tolist()):  

                # the parser should start at EVENT_OFF_TO_ON for ordered pairng (ON, OFF)
                if not opertation_started:
                    if(occ_flag == EVENT_OFF_TO_ON):
                        event = taxi_np[occ_idx, :]
                        event = np.expand_dims(event, axis=0)
                        start_time = datetime2unixtime(event[0, 4])
                        
                        # save 
                        taxi_onoff_pair = event
                        
                        # on the switch (wait for the pair OFF event)
                        opertation_started = 1
                else:
                    if(occ_flag == EVENT_ON_TO_OFF):
                        event = taxi_np[occ_idx, :]
                        event = np.expand_dims(event, axis=0)
                        end_time = datetime2unixtime(event[0, 4])
                        
                        time_diff_sec = np.expand_dims(np.array([end_time - start_time]), 1)
                        
                        # save 
                        taxi_onoff_pair = np.concatenate((taxi_onoff_pair, event), axis=1)
                        taxi_onoff_pair = np.concatenate((taxi_onoff_pair, time_diff_sec), axis=1)
                        
                        # append the data 
                        if(taxi_onoff_pair_history_start_flag == 0):
                            taxi_onoff_pair_history = taxi_onoff_pair
                            taxi_onoff_pair_history_start_flag = 1
                        else:
                            taxi_onoff_pair_history = np.concatenate((taxi_onoff_pair_history, taxi_onoff_pair), axis=0)
                            
                        # reset the switch (wait for the next ON event)
                        opertation_started = 0

        # save 
        print(taxi_onoff_pair_history.shape)
        taxi_onoff_pair_history_save_name = "data/taxi_onoffpair_" + TARGET_DATE + "_" + TARGET_DURATION[0] + "_" + TARGET_DURATION[1] + ".csv"
        np.savetxt(taxi_onoff_pair_history_save_name, taxi_onoff_pair_history, delimiter=",")

