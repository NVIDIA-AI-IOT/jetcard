#!/bin/bash

# Copyright (c) 2019, NVIDIA CORPORATION. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  * Neither the name of NVIDIA CORPORATION nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
# OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This is a script to resize partition and filesystem on the root partition
# This will consume all un-allocated sapce on SD card after boot.

set -e

function cleanup()
{
	# Delete nvresizefs.sh, nvresizefs.service and its symlink
	rm "/etc/systemd/nvresizefs.sh"
	rm "/etc/systemd/system/nvresizefs.service"
	rm "/etc/systemd/system/multi-user.target.wants/nvresizefs.service"
}

#if [ -e "/proc/device-tree/compatible" ]; then
#	model="$(tr -d '\0' < /proc/device-tree/compatible)"
#	if [[ "${model}" =~ "jetson-nano" ]]; then
#		model="jetson-nano"
#	fi
#fi
#
#if [ "${model}" != "jetson-nano" ]; then
#	cleanup
#	exit 0
#fi

# Move backup GPT header to end of disk
sgdisk --move-second-header /dev/mmcblk0

# Get root partition name i.e partition No. 1
partition_name="$(sgdisk -i 1 /dev/mmcblk0 | \
	grep "Partition name" | cut -d\' -f2)"

partition_type="$(sgdisk -i 1 /dev/mmcblk0 | \
	grep "Partition GUID code:" | cut -d' ' -f4)"

partition_uuid="$(sgdisk -i 1 /dev/mmcblk0 | \
	grep "Partition unique GUID:" | cut -d' ' -f4)"

# Get start sector of the root partition
start_sector="$(cat /sys/block/mmcblk0/mmcblk0p1/start)"

# Delete and re-create the root partition
# This will resize the root partition.
sgdisk -d 1 -n 1:"${start_sector}":0 -c 1:"${partition_name}" \
	-t 1:"${partition_type}" -u 1:"${partition_uuid}" /dev/mmcblk0

# Inform kernel and OS about change in partitin table and root
# partition size
partprobe /dev/mmcblk0

# Resize filesystem on root partition to consume all un-allocated
# space on disk
resize2fs /dev/mmcblk0p1

# Clean up
cleanup
