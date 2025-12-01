import argparse
from matplotlib import pyplot
import numpy
import pandas

import src.plots.common as common
from src.plots.keyPairArg import parseKeyPair

# Arguments
parser = argparse.ArgumentParser(description="Plots the encoding speed in frames per second of different codecs and presets. Produces one figure for each codec and resolution combination.")
parser.add_argument("data", help="Path of the CSV file with the encoding time.")
parser.add_argument("figure", help="Path and filename of the figure.")
parser.add_argument("--heightLabels", nargs="+", help="The labels for the resolutions in key-value pairs (e.g. 0='Label 1' 500='Label 2').")

args = parser.parse_args()
heightLabels = parseKeyPair(args.heightLabels, int, str)

# Load data
frame = pandas.read_csv(args.data)
frame = frame.groupby(["tile", "codec", "preset", "height"], as_index=False).mean(numeric_only=True)

# Compute encoding speed
frame["speed"] = frame["numFrames"] / frame["time"]

# Plot data
tiles = frame.tile.unique()
heights = frame.height.unique()
codecs = frame.codec.unique()

figure, axes = pyplot.subplots(4, 5, constrained_layout=True, sharey=True)
figure.set_size_inches(12, 6.25)

width = 0.2
lines = []

for i, tile in enumerate(tiles):
    axis = axes.flat[i]
    axis.set_title(tile, size=10)
    m = 0

    for height in heights:
        for codec in codecs:
            series = frame.query("tile == @tile and height == @height and codec == @codec")

            x = numpy.arange(len(series.preset))
            y = series.speed

            color = common.colors[m % len(common.colors)]
            
            line = axis.bar(x + (width * m), y, width, color=color, label=f"{codec} {heightLabels[height]}")

            if (i == 0):
                lines.append(line)

            axis.set_xticks(x + (width * 2 - (width / 2)), series.preset)
            axis.grid(True)
            
            m += 1

figure.supxlabel("Preset")
figure.supylabel("Encoding speed (frames per second)")

figure.legend(title="Codec and Resolution", ncol=4, loc="upper center", bbox_to_anchor=(0.5, 0), handles=lines)

figure.savefig(args.figure, bbox_inches="tight")
