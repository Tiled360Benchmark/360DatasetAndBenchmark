<#
	.DESCRIPTION
		Returns a JSON object with the bitrate, width, height and duration of the streams of a video file using FFprobe.
		The JSON fields will be converted to numerical types.
		Note : not all streams have a bitrate.

	.PARAMETER file
		The path of the file to probe
	
	.OUTPUTS
		PSCustomObject
#>
function Probe {
    param (
		[Parameter(Mandatory)][String] $file
	)

	$result = ffprobe -select_streams v -show_entries stream=bit_rate,width,height,duration -print_format json -loglevel warning -i $file | ConvertFrom-Json
	
	# Convert the data types
	foreach ($stream in $result.streams)
	{
		# Not all streams have a bitrate
		if ($stream.bit_rate) {
			$stream.bit_rate = $stream.bit_rate -as [int]
		}

		$stream.width = $stream.width -as [int]
		$stream.height = $stream.height -as [int]
		$stream.duration = $stream.duration -as [double]
	}

    return $result
}

<#
	.DESCRIPTION
		Changes the parameters of a video file and returns the elapsed encoding time.

	.PARAMETER in
		The file to transcode.

	.PARAMETER codec
		The codec.
	
	.PARAMETER qp
		The quantization parameter.

	.PARAMETER height
		The height in pixels.

	.PARAMETER preset
		The preset.

	.PARAMETER gop
		The group of pictures (i.e., the frequency of I frames).

	.PARAMETER out
		The path and filename of the transcoded video.

	.OUTPUTS
		double The elapsed encoding time.
#>
function Transcode {
	param(
		[Parameter(Mandatory)][String] $in,
		[Parameter(Mandatory)][String] $codec,
		[Parameter(Mandatory)][int] $qp,
		[Parameter(Mandatory)][int] $height,
		[Parameter(Mandatory)][String] $preset,
		[Parameter(Mandatory)][int] $gop,
		[Parameter(Mandatory)][String] $out
	)

	if ($height -eq 0)
	{
		$output = ffmpeg -benchmark -hide_banner -vsync passthrough -hwaccel cuda -hwaccel_output_format cuda `
					-i $in -c:v $codec -qp $qp -b:v 0 -preset $preset -rc constqp -g $gop -movflags faststart $out 2>&1 | Out-String
	}
	else
	{
		$output = ffmpeg -benchmark -hide_banner -vsync passthrough -hwaccel cuda -hwaccel_output_format cuda `
					-i $in -vf "hwupload,scale_cuda=-2:$height" -c:v $codec -qp $qp -b:v 0 -preset $preset -rc constqp -g $gop -movflags faststart $out 2>&1 | Out-String
	}

	# Extract the encoding time
	$output -match "rtime=(\d+\.{0,1}\d+)s" | Out-Null
	$rtime = $matches[1] -as [double]

	return $rtime
}

<#
	.DESCRIPTION
		Evaluates the visual quality of a video file using libvmaf and returns the content of the log file.

	.PARAMETER distorted
		The video to evaluate.

	.PARAMETER reference
		The reference video.

	.PARAMETER log
		The path and filename of the libvmaf log. Warning, do not use backslashes (\) even on Windows. Otherwise, libvmaf will fail.

	.OUTPUTS
		PSCustomObject The content of the log file.
#>
function VisualQuality {
	param(
		[Parameter(Mandatory)][String] $distorted,
		[Parameter(Mandatory)][String] $reference,
		[Parameter(Mandatory)][String] $log
	)

	$probeDistorted = (Probe $distorted).streams[0]
	$probeReference = (Probe $reference).streams[0]
	$referenceWidth = $probeReference.width
	$referenceHeight = $probeReference.height

	if ($probeDistorted.width -eq $referenceWidth -and $probeDistorted.height -eq $referenceHeight)
	{
		ffmpeg -loglevel error -i $distorted -i $reference -filter_complex "libvmaf=feature=name=psnr:n_threads=8:log_path=$log\:log_fmt=json" -f null -
	}
	# Resize the distorted file if its resolution does not match the reference file
	else
	{
		ffmpeg -loglevel error -i $distorted -i $reference -filter_complex "[0]scale=${referenceWidth}x${referenceHeight},libvmaf=feature=name=psnr:n_threads=8:log_path=$log\:log_fmt=json" -f null -
	}

	# Get the mean VMAF
	$results = Get-Content -Raw $log | ConvertFrom-Json
	
	return $results
}
