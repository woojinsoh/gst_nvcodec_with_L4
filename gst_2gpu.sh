#!/bin/bash
mkdir -p encoded_outputs
mkdir -p logs
mkdir -p outputs

START=1
END=$@
for (( c=$START; c<=$END; c++ )) do {
if [ $((c % 2)) -eq 1 ]
then
gpu_index=0
GPUDECODER="nvh264dec"
GPUENCODER="nvh264enc"
GPUHEVCENCODER="nvh265enc"
echo "Use $GPUDECODER and $GPUENCODER";
else
gpu_index=1
GPUDECODER="nvh264device"$gpu_index"dec"
GPUENCODER="nvh264device"$gpu_index"enc"
GPUHEVCENCODER="nvh265device"$gpu_index"enc"
CUDADEVICEID="cuda-device-id="$gpu_index
echo "Use $GPUDECODER and $GPUENCODER";
fi
time GST_DEBUG_NO_COLOR=1 \
GST_DEBUG_FILE=./logs/gst_$c.log \
GST_DEBUG=GST_SCHEDULING:5 \
gst-launch-1.0 \
filesrc location=4k_avc.mp4 ! qtdemux ! h264parse \
! queue ! $GPUDECODER ! tee name=t1 \
t1. \
! queue ! videorate ! video/x-raw\(memory:CUDAMemory\),framerate=60/1 ! cudascale $CUDADEVICEID ! cudaconvert $CUDADEVICEID ! video/x-raw\(memory:CUDAMemory\),width=1920,height=1080 \
! queue ! $GPUHEVCENCODER preset=1 gop-size=30 rc-mode=3 max-bitrate=6000 vbv-buffer-size=12000 bitrate=6000 ! h265parse \
! qtmux ! filesink location=./encoded_outputs/1080_hevc_$c.mp4 \
t1. \
! queue ! videorate ! video/x-raw\(memory:CUDAMemory\),framerate=60/1 ! cudascale $CUDADEVICEID ! cudaconvert $CUDADEVICEID ! video/x-raw\(memory:CUDAMemory\),width=1920,height=1080 \
! queue ! $GPUENCODER preset=1 gop-size=30 rc-mode=3 max-bitrate=7500 vbv-buffer-size=15000 bitrate=7500 ! h264parse \
! qtmux ! filesink location=./encoded_outputs/1080_$c.mp4 \
t1. \
! queue ! videorate ! video/x-raw\(memory:CUDAMemory\),framerate=30/1 ! cudascale $CUDADEVICEID ! cudaconvert $CUDADEVICEID ! video/x-raw\(memory:CUDAMemory\),width=1280,height=720 \
! queue ! $GPUENCODER preset=1 gop-size=30 rc-mode=3 max-bitrate=2500 vbv-buffer-size=5000 bitrate=2500 ! h264parse \
! qtmux ! filesink location=./encoded_outputs/720_$c.mp4 \
t1. \
! queue ! videorate ! video/x-raw\(memory:CUDAMemory\),framerate=30/1 ! cudascale $CUDADEVICEID ! cudaconvert $CUDADEVICEID ! video/x-raw\(memory:CUDAMemory\),width=854,height=480 \
! queue ! $GPUENCODER preset=1 gop-size=30 rc-mode=3 max-bitrate=1500 vbv-buffer-size=3000 bitrate=1500 ! h264parse \
! qtmux ! filesink location=./encoded_outputs/480_$c.mp4 \
t1. \
! queue ! videorate ! video/x-raw\(memory:CUDAMemory\),framerate=30/1 ! cudascale $CUDADEVICEID ! cudaconvert $CUDADEVICEID ! video/x-raw\(memory:CUDAMemory\),width=640,height=368 \
! queue ! $GPUENCODER preset=1 gop-size=30 rc-mode=3 max-bitrate=800 vbv-buffer-size=1600 bitrate=800 ! h264parse \
! qtmux ! filesink location=./encoded_outputs/360_$c.mp4 > ./outputs/out_$c.txt &pid=$!PID_LIST+=" $pid";
} done
trap "kill $PID_LIST" SIGINT
echo "Parallel processes have started";
wait $PID_LIST
echo
echo "All processes have completed"
