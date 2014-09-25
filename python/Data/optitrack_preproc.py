#!/usr/bin/env python
#
# Pre-processing of OptiTrack data
#
# by Fernando L. Garcia Bermudez
#
# v.0.1 alpha
#
# created on 2012-2-17
#

import os, glob, csv

# Load OptiTrack data from exported csv
root = os.path.expanduser('~/Research/Data/tests/optitrack/arena_tile/')
name = 'octoroach_test'
datareader = csv.reader(open(root + name + '.csv', 'r'), delimiter=',', \
    quotechar='"', quoting=0)

trackable = []
frame = []
frame_tracked = []
other = []
for row in datareader:
    if row[0] == 'trackable':
        trackable.append(row)
    elif row[0] == 'frame':
        frame.append(row)
        if row[3] == '1': # trackable is being tracked
            frame_tracked.append(row)
    else:
        other.append(row)

# Write parsed data
datawriter = csv.writer(open(root + name + '_frame_tracked.csv', 'wb'))
datawriter.writerows(frame_tracked)
