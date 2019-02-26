#!/usr/bin/python


from datetime import time, date, datetime, timedelta

# import os
import sys

# print os.getenv["ev_year"]
# print sys.argv[1:]


ev_year = int(sys.argv[1])
ev_month = int(sys.argv[2])
ev_day = int(sys.argv[3])
ev_hour = int(sys.argv[4])
ev_min = int(sys.argv[5])
ev_sec = int(sys.argv[6])
ev_msec = int(sys.argv[7])
st_year = int(sys.argv[8])
st_month = int(sys.argv[9])
st_day = int(sys.argv[10])
st_hour = int(sys.argv[11])
st_min = int(sys.argv[12])
st_sec = int(sys.argv[13])
st_msec = int(sys.argv[14])

ev_time = datetime(ev_year, ev_month, ev_day, ev_hour, ev_min, ev_sec, ev_msec)
arr_time = datetime(st_year, st_month, st_day, st_hour, st_min, st_sec, st_msec)
# print ev_time
# print arr_time

time_diff = arr_time - ev_time

f = open('time_diff.out', 'wb')
f.write("%s \n" % (time_diff))
f.close()

