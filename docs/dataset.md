# Benchmark Data

To reproduce our results, first [learn how to use our benchmarking software](usage.md).

If you use any part of this dataset, please [cite our work](../README.md#citation) and observe our [ethics code](#ethics).

## 360° videos

The video material used in our benchmark consists of the following 360° videos that we filmed using an [Insta Pro 2 camera](https://www.insta360.com/product/insta360-pro2).

| Name           | Duration (s) | Cut Video From | Cut Video To | Download Links |
|:---------------|:------------:|:--------------:|:------------:|:--------------:|
| BridgeDay      | 248          | 00:00:00.00    | End          | [Unstitched]() <br> [Stitched Monoscopic (2D)]() <br> [Stitched Stereo (3D)]() |
| BridgeNight    | 761          | 00:00:00.00    | End          | |
| Cathedral      | 263          | 00:00:02.00    | 00:04:23.00  | |
| Cats           | 580          | 00:00:10.00    | 00:09:50.00  | |
| Excavating     | 680          | 00:00:00.00    | 00:11:20.00  | |
| Fireplace      | 735          | 00:00:04.00    | 00:12:19.00  | |
| Forest         | 401          | 00:00:00.00    | 00:06:41.00  | |
| Mowing         | 599          | 00:00:00.00    | 00:09:59.00  | |
| Muffins        | 1207         | 00:00:02.00    | 00:20:08.00  | |
| Quad           | 901          | 00:00:00.00    | End          | |
| Raking         | 732          | 00:00:05.00    | 00:12:17.00  | |
| Running        | 309          | 00:00:01.00    | 00:05:09.00  | |
| SuburbDay      | 287          | 00:00:02.00    | 00:04:49.00  | |
| SuburbNight    | 287          | 00:00:00.00    | 00:04:47.00  | |
| Swing          | 303          | 00:00:00.00    | 00.05:03.00  | |
| Train          | 349          | 00:00:00.00    | End          | |
| Turkeys        | 642          | 00:00:23.00    | 00:11:05.00  | |
| University     | 344          | 00:00:01.00    | 00:05:44.00  | |
| Vacuuming      | 543          | 00:00:00.00    | 00:09:03.00  | |
| VirtualReality | 255          | 00:00:07.00    | 00:04:22.00  | |

We stitched the 360° videos in equirectangular projection using the [Insta360 Stitcher 3.1.3 software](https://www.mantis-sub.com/support/) and the following parameters.

| Parameter                   | Value                                            |
|:----------------------------|:------------------------------------------------:|
| Content Type                | Monoscopic <br> Stereo (Left Eye on Top)         |
| Stitching Mode              | New Optical Flow                                 |
| Sampling Type               | Fast                                             |
| Blender Type                | Cuda                                             |
| Opticalflow stitching range | 20 (Monoscopic) <br> 16 (Stereo)                 |
| Template stitching range    | 0.5                                              |
| Use Original Offset         | Enabled                                          |
| Smooth Stitch               | Enabled                                          |
| Use Hardware Decoding       | 8                                                |
| Use Hardware Encoding       | Enabled                                          |
| Use nadir logo              | Disabled                                         |
| Cut Video                   | See previous table                               |
| Resolution                  | 8K (7680 $\times$ 3840 pixels)                   |
| Output Format               | MP4                                              |
| Codec Type                  | H265 codec                                       |
| Bitrate                     | 144 Mibps* (Monoscopic) <br> 288 Mibps* (Stereo) |
| Frame Rate                  | 29.97                                            |
| Audio Type                  | Spatial                                          |

\* Even though Insta360 Stitcher shows the bitrate in Mbps, Mibps are used during encoding.
A bitrate of 144 Mibps is approximately 151 Mbps and 288 Mibps is approximately 302 Mbps.

## Tiles

The 360° videos were cut into 6 by 6 tiles (from left to right, then top to bottom) using the following FFmpeg command.

```bash
ffmpeg -y -hide_banner -i video.mp4 -vf "crop=1280:640:0:0" -pix_fmt yuv420p tile1.y4m -vf "crop=1280:640:1280:0" -pix_fmt yuv420p tile2.y4m -vf "crop=1280:640:2560:0" -pix_fmt yuv420p tile3.y4m -vf "crop=1280:640:3840:0" -pix_fmt yuv420p tile4.y4m -vf "crop=1280:640:5120:0" -pix_fmt yuv420p tile5.y4m -vf "crop=1280:640:6400:0" -pix_fmt yuv420p tile6.y4m -vf "crop=1280:640:0:640" -pix_fmt yuv420p tile7.y4m -vf "crop=1280:640:1280:640" -pix_fmt yuv420p tile8.y4m -vf "crop=1280:640:2560:640" -pix_fmt yuv420p tile9.y4m -vf "crop=1280:640:3840:640" -pix_fmt yuv420p tile10.y4m -vf "crop=1280:640:5120:640" -pix_fmt yuv420p tile11.y4m -vf "crop=1280:640:6400:640" -pix_fmt yuv420p tile12.y4m -vf "crop=1280:640:0:1280" -pix_fmt yuv420p tile13.y4m -vf "crop=1280:640:1280:1280" -pix_fmt yuv420p tile14.y4m -vf "crop=1280:640:2560:1280" -pix_fmt yuv420p tile15.y4m -vf "crop=1280:640:3840:1280" -pix_fmt yuv420p tile16.y4m -vf "crop=1280:640:5120:1280" -pix_fmt yuv420p tile17.y4m -vf "crop=1280:640:6400:1280" -pix_fmt yuv420p tile18.y4m -vf "crop=1280:640:0:1920" -pix_fmt yuv420p tile19.y4m -vf "crop=1280:640:1280:1920" -pix_fmt yuv420p tile20.y4m -vf "crop=1280:640:2560:1920" -pix_fmt yuv420p tile21.y4m -vf "crop=1280:640:3840:1920" -pix_fmt yuv420p tile22.y4m -vf "crop=1280:640:5120:1920" -pix_fmt yuv420p tile23.y4m -vf "crop=1280:640:6400:1920" -pix_fmt yuv420p tile24.y4m -vf "crop=1280:640:0:2560" -pix_fmt yuv420p tile25.y4m -vf "crop=1280:640:1280:2560" -pix_fmt yuv420p tile26.y4m -vf "crop=1280:640:2560:2560" -pix_fmt yuv420p tile27.y4m -vf "crop=1280:640:3840:2560" -pix_fmt yuv420p tile28.y4m -vf "crop=1280:640:5120:2560" -pix_fmt yuv420p tile29.y4m -vf "crop=1280:640:6400:2560" -pix_fmt yuv420p tile30.y4m -vf "crop=1280:640:0:3200" -pix_fmt yuv420p tile31.y4m -vf "crop=1280:640:1280:3200" -pix_fmt yuv420p tile32.y4m -vf "crop=1280:640:2560:3200" -pix_fmt yuv420p tile33.y4m -vf "crop=1280:640:3840:3200" -pix_fmt yuv420p tile34.y4m -vf "crop=1280:640:5120:3200" -pix_fmt yuv420p tile35.y4m -vf "crop=1280:640:6400:3200" -pix_fmt yuv420p tile36.y4m
```

## Spatial and Temporal Information

We evaluated the spatial information (SI) and temporal information (TI) of the tiles using the following command.

```powershell
siTi.ps1 -tiles "tile1.y4m", "tile2.y4m", "tile3.y4m", "tile4.y4m", "tile5.y4m", "tile6.y4m", "tile7.y4m", "tile8.y4m", "tile9.y4m", "tile10.y4m", "tile11.y4m", "tile12.y4m", "tile13.y4m", "tile14.y4m", "tile15.y4m", "tile16.y4m", "tile17.y4m", "tile18.y4m", "tile19.y4m", "tile20.y4m", "tile21.y4m", "tile22.y4m", "tile23.y4m", "tile24.y4m", "tile25.y4m", "tile26.y4m", "tile27.y4m", "tile28.y4m", "tile29.y4m", "tile30.y4m", "tile31.y4m", "tile32.y4m", "tile33.y4m", "tile34.y4m", "tile35.y4m", "tile36.y4m" -resultsFile siTiVideo.csv
```

<!--TODO Update link-->
The result files for all videos are available in this repository.
The files follow this format.

| Column Name | Description                            |
|:------------|:---------------------------------------|
| input_file  | The file name of the tile.             |
| n           | The index of the frame (starts at 1).  |
| si          | The spatial information of the frame.  |
| ti          | The temporal information of the frame. |

To visualize the results, we ran the following command.

```bash
uv run -m src.plots.plotSiTi siTi.csv siTi.pdf
```

## Bitrate, Visual Quality and Segment's Encoding Time Benchmark

To calculate the rate-distortion of each tile, we first evaluate the bitrate and visual quality of their segments according to their encoding parameters using the following commands.

```powershell
bitrateVmafSegmentsEncodingTimeTasks.ps1 -tiles "bridgeDay24.y4m", "bridgeNight1.y4m", "cathedral20.y4m", "cats13.y4m", "excavating1.y4m", "fireplace3.y4m", "forest30.y4m", "mowing33.y4m", "muffins25.y4m", "quad32.y4m", "raking7.y4m", "running18.y4m", "suburbDay14.y4m", "suburbNight16.y4m", "swing17.y4m", "train3.y4m", "turkeys17.y4m", "university23.y4m", "vacuuming13.y4m", "virtualReality29.y4m" -codecs "h264_nvenc", "hevc_nvenc" -presets p1, p2, p3, p4, p5, p6, p7 -qps 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40 -heights 0, 320 -outputFile bitrateVmafSegmentsEncodingTimeTasks.csv
```

```powershell
bitrateVmafSegmentsEncodingTime.ps1 -inputFile tasbitrateVmafSegmentsEncodingTimeTasks.csv -segmentTime 2 -segmentGOP 60 -logsDirectory ".\logs" -outputFile bitrateVmafSegmentsEncodingTime.csv
```

<!--TODO Update link-->
The results file for the selected tiles (`bitrateVmafSegmentsEncodingTime.csv`) is available in this repository.
The file follows this format.

<!--TODO Update link-->
To get detailed information about the visual quality, download the [VMAF log files]() for all segments.
Every file contains the PSNR (Y, Cb and Cr), VIF, VMAF and more of every frame.

| Column Name | Description                                                                                                                      |
|:------------|:---------------------------------------------------------------------------------------------------------------------------------|
| tile        | The file name of the tile.                                                                                                       |
| segment     | The index of the segment (starts at 0).                                                                                          |
| codec       | The codec used to encode the segment.                                                                                            |
| preset      | The preset used to encode the segment.                                                                                           |
| qp          | The quantization parameter to encode the segment.                                                                                |
| height      | The segment's height in pixels. A value of zero means that the height is unchanged.                                              |
| bitrate     | The number of bits in the encoded segment.                                                                                       |
| meanVmaf    | The mean VMAF of the encoded segment.                                                                                            |
| meanPsnrY   | The mean PSNR of the luma component.                                                                                             |
| meanPsnrCb  | The mean PSNR of the blue-difference chroma component.                                                                           |
| meanPsnrCr  | The mean PSNR of the red-difference chroma component.                                                                            |
| logFile     | The name of the VMAF results file for this segment, which includes all supported metrics, such as PSNR and SSIM, for each frame. |
| time        | The time required to encode this segment in seconds.                                                                             |

To visualize the results, we ran the following command.

```bash
uv run -m src.plots.plotBdRate bitrateVmafSegmentsEncodingTime.csv h264_nvenc p1 bdRate.pdf --heightLabels 0='8K' 320='4K' 
```

## Total Encoding Time Benchmark

To benchmark the encoding speed of NVENC, we evaluate the time needed to segment and encode the videos with different encoding parameters using the following commands.

```powershell
totalEncodingTimeTasks.ps1 -tiles "bridgeDay24.y4m", "bridgeNight1.y4m", "cathedral20.y4m", "cats13.y4m", "excavating1.y4m", "fireplace3.y4m", "forest30.y4m", "mowing33.y4m", "muffins25.y4m", "quad32.y4m", "raking7.y4m", "running18.y4m", "suburbDay14.y4m", "suburbNight16.y4m", "swing17.y4m", "train3.y4m", "turkeys17.y4m", "university23.y4m", "vacuuming13.y4m", "virtualReality29.y4m" -codecs "h264_nvenc", "hevc_nvenc" -presets p1, p2, p3, p4, p5, p6, p7 -qps 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40 -heights 0, 320 -outputFile totalEncodingTimeTasks.csv
```

```powershell
totalEncodingTime.ps1 -inputFile tasks.csv -segmentTime 2 -segmentGOP 60 -outputFile totalEncodingTime.csv
```

<!--TODO Update link-->
The results file for the selected tiles (`totalEncodingTime.csv`) is available in this repository.
The file follows this format.

| Column Name | Description                                                                         |
|:------------|:------------------------------------------------------------------------------------|
| tile        | The file name of the tile.                                                          |
| codec       | The codec used to encode the segment.                                               |
| preset      | The preset used to encode the segment.                                              |
| qp          | The quantization parameter to encode the segment.                                   |
| height      | The segment's height in pixels. A value of zero means that the height is unchanged. |
| repetition  | The ID of the repetition.                                                           |
| numFrames   | The number of frames in this tile.                                                  |
| time        | The time required to encode all the segments of the tile in seconds.                |

To visualize the results, we ran the following command.

```bash
uv run -m src.plots.plotEncodingSpeed totalEncodingTime.csv encodingSpeed.pdf --heightLabels 0='8K' 320='4K'
```

## Ethics

We have obtained the consent of the recognizable people in the videos to publish the data.
Follow these rules when using the videos.

- Don't use the videos in illegal, immoral, offensive, misleading or deceptive content.
- Don't sell or redistribute the videos on other platforms.
- Don't use the videos in your trade-mark, design-mark, trade-name, business name or service mark.
- Videos containing recognizable trademarks, logos or brands cannot be used for commercial purposes.
- Don't imply that any recognizable person or brand in the videos endorses your content or product.
