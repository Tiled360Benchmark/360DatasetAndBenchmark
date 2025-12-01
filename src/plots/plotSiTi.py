import argparse
from matplotlib import pyplot
import pandas

import src.plots.common as common

# Arguments
parser = argparse.ArgumentParser(description="Plots the spatial and temporal information of videos.")
parser.add_argument("data", help="Path of the CSV file with the spatial and temporal information for each video.")
parser.add_argument("figure", help="Path and filename of the figure.")

args = parser.parse_args()

# Load data
frame = pandas.read_csv(args.data)
frame = frame.groupby("input_file", as_index=False).mean(numeric_only=True)

pyplot.figure(figsize=(5.5, 2.5))

i = 0

for tile in frame["input_file"].unique():
    series = frame.query("input_file == @tile")
    marker = common.markers[i % len(common.markers)]

    pyplot.scatter(x=series.si, y=series.ti, label=tile, marker=marker, s=50)

    i += 1

pyplot.xlabel("Mean SI")
pyplot.ylabel("Mean TI")

pyplot.legend(title="Video Name and Tile ID", ncols=3, bbox_to_anchor=(0.45, -1), loc="lower center", prop={"size": 8}, title_fontsize=8)
pyplot.savefig(args.figure, bbox_inches="tight")
