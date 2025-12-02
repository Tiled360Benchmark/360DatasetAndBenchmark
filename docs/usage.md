# Installation

To run the [benchmark](#benchmark) :

1. Install [FFmpeg 7.1](https://ffmpeg.org/).
1. Install [Powershell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell).
1. To run the [Spatial and Temporal Information experiment](#spatial-and-temporal-information), also install [siti-tools](https://github.com/VQEG/siti-tools#requirements).

To generate the [plots](#plots) :

1. [Install the uv package manager](https://docs.astral.sh/uv/getting-started/installation/). It will download the right version of Python automatically.
1. Install the required Python packages using `uv sync`.

# Benchmark

A description of each script parameters is available inside the script.

## Spatial and Temporal Information

This script calculates the spatial and temporal information of videos according to the [ITU-T P.910 (07/2022) recommendation](https://www.itu.int/rec/T-REC-P.910-202207-I/en) using the [reference software](https://github.com/VQEG/siti-tools).

```powershell
siTi.ps1 -tiles "tile1.y4m", "tile2.y4m" -resultsFile sitiTiles.csv
```

## Bitrate, Visual Quality and Segment's Encoding Time Benchmark

This script evaluates the bitrate, visual quality and the segment's encoding time of videos with different encoding parameters.
First, generate the tasks to be performed.

```powershell
bitrateVmafSegmentsEncodingTimeTasks.ps1 -tiles "tile1.y4m", "tile2.y4m" -codecs "h264_nvenc", "hevc_nvenc" -presets p1, p2 -qps 18, 20 -heights 0, 320 -outputFile tasks.csv
```

Then, start the benchmark.

```powershell
bitrateVmafSegmentsEncodingTime.ps1 -inputFile tasks.csv -segmentTime 2 -segmentGOP 60 -logsDirectory ".\logs" -outputFile bitrateVmafSegmentsEncodingTime.csv
```

If the benchmark stops for any reason, you may restart it again by using the incomplete output file (here `bitrateVmafSegmentsEncodingTime.csv`) as the input file.
The script will automatically resume the execution of the remaining tasks.

## Total Encoding Time Benchmark

This script evaluates the time needed to segment and encode the videos with different encoding parameters.
First, generate the tasks to be performed.

```powershell
totalEncodingTimeTasks.ps1 -tiles "tile1.y4m", "tile2.y4m" -codecs "h264_nvenc", "hevc_nvenc" -presets p1, p2 -qps 18, 20 -heights 0, 320 -repetitions 5 -outputFile tasks.csv
```

Then, start the benchmark.

```powershell
totalEncodingTime.ps1 -inputFile tasks.csv -segmentTime 2 -segmentGOP 60 -outputFile totalEncodingTime.csv
```

If the benchmark stops for any reason, you may restart it again by using the incomplete output file (here `totalEncodingTime.csv`) as the input file.
The script will automatically resume the execution of the remaining tasks.

# Plots

## Spatial and Temporal Information

This script plots the spatial and temporal information of videos.
Example usage :

```bash
uv run -m src.plots.plotSiTi siTi.csv siTi.pdf
```

## Bjøntegaard-Delta rate

This script plots the BD-rate performance for all tiles, codecs and presets.
Example usage :

```bash
uv run -m src.plots.plotBdRate bitrateVmafSegmentsEncodingTime.csv h264_nvenc p1 bdRate.pdf --heightLabels 0='8K' 320='4K' 
```

## Encoding Speed

This script plots the encoding speed in frames per second of different codecs, presets and resolutions.
Example usage :

```bash
uv run -m src.plots.plotEncodingSpeed totalEncodingTime.csv encodingSpeed.pdf --heightLabels 0='8K' 320='4K'
```
