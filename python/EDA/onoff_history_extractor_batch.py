
import os
# import sys
# import time
# import copy
from tqdm import tqdm

# import cv2

import numpy as np
import pandas as pd 

# import matplotlib.pyplot as plt
# import seaborn as sns

DATA_COLUMNS_NAME = ['taxiID', 'lng', 'lat', 'alt', 'time', 'azim', 'vel', 'gpstype', 'occ']

DATA_BASEDIR = "/home/gskim/data/CE545 Taxi/data"
TARGET_DATE_LIST = ["2018-04-02", "2018-04-06", "2018-04-09", 
                    "2018-04-13", "2018-04-16", "2018-04-20",
                    "2018-04-23", "2018-04-27"]

TARGET_DURATION = ["070000", "100000"] # 3 hours required nearly 10GB memory. 
for TARGET_DATE in TARGET_DATE_LIST:
    print("\n\n")
    print(TARGET_DATE)

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
    EVENT_OFF_TO_ON = -1
    EVENT_ON_TO_OFF = 1

    #
    taxi_id_dict = taxi_grouped.groups

    taxi_on_history_start_flag = 0
    taxi_off_history_start_flag = 0
    taxi_on_history = np.zeros(1)
    taxi_off_history = np.zeros(1)
    for for_idx, taxi_id in enumerate(tqdm(taxi_id_dict, mininterval=10)):                

        taxi = taxi_grouped.get_group(taxi_id)
        taxi = taxi.sort_values(["time"], ascending=[True])
        taxi = taxi.reset_index(drop=True)

        taxi_np = taxi.values
        taxi_np = taxi_np[1:, :]
        taxi_np_occ_diff = taxi_np[:-1, -1] - taxi_np[1:, -1] # EVENT_OFF_TO_ON = 1, EVENT_ON_TO_OFF = -1
        for occ_idx, occ_flag in enumerate(taxi_np_occ_diff.tolist()):

            if(occ_flag == EVENT_OFF_TO_ON):
                event = taxi_np[occ_idx, :]
                event = np.expand_dims(event, axis=0)
                if(taxi_on_history_start_flag == 0):
                    taxi_on_history = event
                    taxi_on_history_start_flag = 1
                else:
                    taxi_on_history = np.concatenate((taxi_on_history, event), axis=0)
                                    
            if(occ_flag == EVENT_ON_TO_OFF):
                event = taxi_np[occ_idx, :]
                event = np.expand_dims(event, axis=0)
                if(taxi_off_history_start_flag == 0):
                    taxi_off_history = event
                    taxi_off_history_start_flag = 1
                else:
                    taxi_off_history = np.concatenate((taxi_off_history, event), axis=0)

    # save 
    taxi_on_history_ = taxi_on_history[:, :-1]
    taxi_off_history_ = taxi_off_history[:, :-1]
    print(taxi_on_history_.shape)
    print(taxi_off_history_.shape)

    taxi_on_history_save_name = "data/taxi_on_" + TARGET_DATE + "_" + TARGET_DURATION[0] + "_" + TARGET_DURATION[1] + ".csv"
    taxi_off_history_save_name = "data/taxi_off_" + TARGET_DATE + "_" + TARGET_DURATION[0] + "_" + TARGET_DURATION[1] + ".csv"
    np.savetxt(taxi_on_history_save_name, taxi_on_history_, delimiter=",")
    np.savetxt(taxi_off_history_save_name, taxi_off_history_, delimiter=",")
