
# coding: utf-8

# In[65]:


import os
import math
import sys
import time
import copy

import cv2

import numpy as np
import pandas as pd 
import matplotlib.pyplot as plt

import seaborn as sns


# In[66]:


"""
- get responsible files for our target time durations (e.g., 7am to 9am)
"""
DATA_COLUMNS_NAME = ['taxiID', 'lat', 'lng', 'alt', 'time', 'azim', 'vel', 'gpstype', 'occ']

DATA_BASEDIR = "/home/gskim/data/CE545 Taxi/data"

TARGET_DATE = "2018-04-02"
TARGET_DURATION = ["073000", "093000"]

taget_date_dir = os.path.join(DATA_BASEDIR, TARGET_DATE)
taget_date_files = os.listdir(taget_date_dir)
taget_date_files.sort()

taget_date_files_in_duration = []
for filename in taget_date_files:
    if TARGET_DURATION[0] < filename[:-4] and filename[:-4] < TARGET_DURATION[1]:
        taget_date_files_in_duration.append(filename)
print(taget_date_files_in_duration)
print("\nThe number of files: ", len(taget_date_files_in_duration))


# In[67]:


def cleaning_df(df):
    return df


# In[68]:


"""
- merge all (in that time zone) files 
- make data frame per each car 
"""

dfs = []
for filename in taget_date_files_in_duration:
    # read
    df_path = os.path.join(taget_date_dir, filename)
    df = pd.read_csv(df_path)
    df.columns = DATA_COLUMNS_NAME  

    # clean
    df = cleaning_df(df)

    # add
    dfs.append(df)

# merge and make all-in-one dataframe   
df_all = pd.concat(dfs)   

# for memory saving 
del dfs
df_all = df_all.drop("gpstype", axis=1)


# In[69]:


# sort by taxi ID
# df_all = df_all.sort_values(["taxiID"], ascending=[True])
# df_all = df_all.reset_index(drop=True)

# grouping by taxi ID
taxi_grouped = df_all.groupby('taxiID')
taxi_grouped.count()


# In[63]:


taxi = taxi_grouped.get_group(180783636)
taxi = taxi.sort_values(["time"], ascending=[True])
taxi = taxi.reset_index(drop=True)

taxi


# In[70]:


fig, ax = plt.subplots(figsize=(10, 10))
ax = sns.scatterplot(x="time", y="occ", data=taxi)
plt.xlabel('center_x and center_y', fontsize=15)
plt.show()

