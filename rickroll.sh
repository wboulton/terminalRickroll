#!/bin/bash
# Rick Astley in your Terminal adapted from this github https://github.com/keroserene/rickrollrc/blob/master/roll.sh

video_url="https://github.com/wboulton/terminalRickroll/raw/refs/heads/main/rickroll.full.bz2"
video_file="/tmp/rickroll.full"

red='\x1b[38;5;9m'
purp='\x1b[38;5;171m'

# Function to handle cleanup and exit gracefully
cleanup() {
  echo -e "\x1b[2J \x1b[0H ${purp}<3 \x1b[?25h \x1b[u \x1b[m"
  rm -f "$video_file.bz2" "$video_file"  # Clean up downloaded files
}
trap cleanup EXIT  # Call cleanup on exit

# Download the video using wget
wget -q -O "$video_file.bz2" "$video_url"

# Decompress the downloaded file
bunzip2 -f "$video_file.bz2"

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