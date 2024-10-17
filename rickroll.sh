#!/bin/bash
# Rick Astley in your Terminal - Adapted from this github page: https://github.com/keroserene/rickrollrc/tree/master
video_url="https://github.com/wboulton/terminalRickroll/raw/refs/heads/main/rickroll.full.bz2"
audio_url="https://github.com/wboulton/terminalRickroll/raw/refs/heads/main/roll.wav"  # Assuming the correct .wav file URL

video_file="/tmp/rickroll.full"
audio_file="/tmp/roll.wav"

red='\x1b[38;5;9m'
purp='\x1b[38;5;171m'

# Function to handle cleanup and exit gracefully
cleanup() {
  echo -e "\x1b[2J \x1b[0H ${purp}<3 \x1b[?25h \x1b[u \x1b[m"
  rm -f "$video_file.bz2" "$video_file" "$audio_file"  # Clean up files
}
trap cleanup EXIT  # Call cleanup on exit

# Download video and audio using wget
wget -q -O "$video_file.bz2" "$video_url"
wget -q -O "$audio_file" "$audio_url"

# Decompress the video file
bunzip2 -f "$video_file.bz2"

# Play the audio in the background using paplay
paplay "$audio_file" &
audio_pid=$!

# Play the video using Python to manage frame sync
python3 <(cat << 'EOF'
import sys
import time

fps = 25
time_per_frame = 1.0 / fps
buf = ''
frame = 0
next_frame = 0
begin = time.time()

try:
    for i, line in enumerate(sys.stdin):
        if i % 32 == 0:
            frame += 1
            sys.stdout.write(buf)
            buf = ''
            elapsed = time.time() - begin
            repose = (frame * time_per_frame) - elapsed
            if repose > 0.0:
                time.sleep(repose)
            next_frame = elapsed / time_per_frame
        if frame >= next_frame:
            buf += line
except KeyboardInterrupt:
    pass
EOF
) < "$video_file"

# Wait for the audio to finish
wait $audio_pid