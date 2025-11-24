import argparse
from matplotlib import pyplot
import pandas

from src.plots.keyPairArg import parseKeyPair
from src.plots.common import common
from src.plots.bdRate import bdRate

# Arguments
parser = argparse.ArgumentParser(description="Plots the BD-rate performance for all tiles, codecs and presets.")
parser.add_argument("data", help="Path of the CSV file with the bitrate and the distortion.")
parser.add_argument("height", type=int, help="The height to show in the figure.")
parser.add_argument("anchorCodec", help="The reference codec to calculate the BD-rate.")
parser.add_argument("anchorPreset", help="The reference preset to calculate the BD-rate.")
parser.add_argument("figure", help="Path and filename of the figure.")

args = parser.parse_args()

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
codecs = bdRates.codec.unique()

figure, axes = pyplot.subplots(4, 5, constrained_layout=True)

figure.set_size_inches(12, 6.25)

lines = []

for i, tile in enumerate(tiles):
    axis = axes.flat[i]
    axis.set_title(tile, size=10)

    for k, codec in enumerate(codecs):
        series = bdRates.query("tile == @tile and height == @args.height and codec == @codec")

        x = series.preset.unique()
        y = series.bdrate

        color = common.codecs[codec]["color"]
        marker = common.markers[k]
        
        line = axis.scatter(x, y, label=codec, facecolors="None", edgecolors=color, marker=marker)

        if (i == 0):
                lines.append(line)

        axis.grid(True)

figure.supxlabel("Preset")
figure.supylabel("BD-rate (%)")

figure.legend(title="Codec", ncol=2, loc="upper center", bbox_to_anchor=(0.5, 0), handles=lines)

pyplot.savefig(args.figure, bbox_inches="tight")
