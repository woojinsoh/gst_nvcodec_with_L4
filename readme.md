# Simple GStreamer pipeline with NVCODEC HW Encoder/Decoder Module

Reproducing different performance between two GPUs.

## Version and environment

- Processor: two L4-24GB GPUs
- OS: Ubuntu 22.04.2 LTS
- CUDA Driver: 535.129.03
- CUDA: 12.2
- NGC container: nvcr.io/nvidia/pytorch:23.07-py3
- GStreamer: 1.19.2

## Reproduction

1. Run NGC container
	```sh
	$ docker run --gpus all -it --rm --security-opt seccomp=unconfined --cap-add=SYS_ADMIN -v {path_to_my_workspace}:/workspace nvcr.io/nvidia/pytorch:23.07-py3 /bin/bash
	```

2. Install Gstreamer from the source

	`apt-get` from Linux doesn't seem to support installing the GStreamer verion > 16. To install the later version, [building from the source](https://gstreamer.freedesktop.org/documentation/installing/building-from-source-using-meson.html?gi-language=c) is required.
	```sh
	$ bash install_gstreamer.sh
	```

3. Download the sample video

	A sample clip from [Pexels](https://www.pexels.com/video/waves-rushing-and-splashing-to-the-shore-1409899/) will be downloaded through the script below.
	```sh
	$ bash download_samples.sh
	```

4. Execute test

	Add a single integer value as a postfix argument indicating the number of repetition when launching the script.

	For a single GPU with 8 repetitions(looping 8 times),
	```sh
	$ bash gst_1gpu.sh 8
	```

	Check the exeuction time for each loop.	The execution times are quite simiar:
	```
	wsoh@nvidia:/workspace# ls outputs| xargs -I {} cat 'outputs/'{}| grep Execution

	Execution ended after 0:00:15.887351431
	Execution ended after 0:00:15.800656215
	Execution ended after 0:00:15.875792631
	Execution ended after 0:00:16.018722223
	Execution ended after 0:00:15.699323816
	Execution ended after 0:00:15.802470331
	Execution ended after 0:00:15.938367952
	Execution ended after 0:00:14.648903630
	```

	For two GPUs processing the pipeline alternately(4 loops in device0, 4 loops in device1), 
	```sh
	$ bash gst_2gpu.sh 8
	```

	The execution time seems to have some gap between two GPUs.
	```
	wsoh@nvidia:/workspace# ls outputs| xargs -I {} cat 'outputs/'{}| grep Execution
	
	Execution ended after 0:00:02.648390668
	Execution ended after 0:00:16.572606867
	Execution ended after 0:00:39.800798081
	Execution ended after 0:00:17.190941542
	Execution ended after 0:00:39.713895777
	Execution ended after 0:00:16.187387359
	Execution ended after 0:00:39.626907670
	Execution ended after 0:00:17.001084400
	```



