import argparse
from matplotlib import pyplot
import matplotlib
import numpy
import pandas

from src.plots.bdRate import bdRate
import src.plots.common as common
from src.plots.keyPairArg import parseKeyPair

# Arguments
parser = argparse.ArgumentParser(description="Plots the BD-rate performance for all tiles, codecs and presets.")
parser.add_argument("data", help="Path of the CSV file with the bitrate and the distortion.")
parser.add_argument("anchorCodec", help="The reference codec to calculate the BD-rate.")
parser.add_argument("anchorPreset", help="The reference preset to calculate the BD-rate.")
parser.add_argument("figure", help="Path and filename of the figure.")
parser.add_argument("--heightLabels", nargs="+", help="The labels for the resolutions in key-value pairs (e.g. 0='Label 1' 500='Label 2').")

args = parser.parse_args()
heightLabels = parseKeyPair(args.heightLabels, int, str)

# Load data
frame = pandas.read_csv(args.data)
frame = frame.groupby(["tile", "codec", "preset", "qp", "height"], as_index=False).mean(numeric_only=True)

# Compute BD-rate
bdRates = []

for tile in frame.tile.unique():
    for height in frame.height.unique():
        original = frame.query("tile == @tile and height == @height and codec == @args.anchorCodec and preset == @args.anchorPreset")

        for codec in frame.codec.unique():
            for preset in frame.preset.unique():
                compared = frame.query("tile == @tile and height == @height and codec == @codec and preset == @preset")

                rate = bdRate(list(original.bitrate), list(original.meanVmaf), list(compared.bitrate), list(compared.meanVmaf))

                bdRates.append({
                    "tile": tile,
                    "codec": codec,
                    "preset": preset,
                    "height": height,
                    "bdrate": rate
                })

bdRates = pandas.DataFrame(bdRates)

# Plot data
tiles = bdRates.tile.unique()
heights = bdRates.height.unique()
codecs = bdRates.codec.unique()

matplotlib.rcParams["hatch.linewidth"] = 0.5

figure, axes = pyplot.subplots(4, 5, constrained_layout=True)

figure.set_size_inches(12, 6.25)

width = 0.2
lines = []

for i, tile in enumerate(tiles):
    axis = axes.flat[i]
    axis.set_title(tile, size=10)
    m = 0

    for height in heights:
        for codec in codecs:
            series = bdRates.query("tile == @tile and height == @height and codec == @codec")

            x = numpy.arange(len(series.preset))
            y = series.bdrate

            color = common.colors[m % len(common.colors)]
            hatch = common.hatches[m % len(common.hatches)]

            line = axis.bar(x + (width * m), y, width, color=color, hatch=hatch, label=f"{codec} {heightLabels[height]}")

            if (i == 0):
                    lines.append(line)

            axis.set_xticks(x + (width * 2 - (width / 2)), series.preset)
            axis.grid(True)

            m += 1

figure.supxlabel("Preset")
figure.supylabel("BD-rate (%)")

figure.legend(title="Codec and Resolution", ncol=4, loc="upper center", bbox_to_anchor=(0.5, 0), handles=lines)

pyplot.savefig(args.figure, bbox_inches="tight")
