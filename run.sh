#!/bin/bash

# Check for required argument
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <workload_template.f>"
  exit 1
fi

template_file="$1"

if [[ ! -f "$template_file" ]]; then
  echo "Error: File '$template_file' not found."
  exit 1
fi

# Define test parameters
dirs=(/mnt/leanfs /mnt/ext4 /mnt/xfs /mnt/btrfs)
iosizes=(4k 32k 128k 1m)

# Map filesystems to devices
declare -A fs_map
fs_map[/mnt/leanfs]=sdb
fs_map[/mnt/ext4]=sdc
fs_map[/mnt/xfs]=sdd
fs_map[/mnt/btrfs]=sde

template_dir=$(dirname "$template_file")
template_name="${template_file%.*}"

# Output CSV
csv_file="${template_name}.csv"
echo "filesystem,iosize,ops,total_ops_per_sec,read_ops,write_ops,throughput,latency,avg_usr,avg_sys,avg_util" > "$csv_file"

# Loop over all combinations
for dir in "${dirs[@]}"; do
  for iosize in "${iosizes[@]}"; do
    echo "=== Running workload: dir=$dir, iosize=$iosize ==="
    if [[ "$dir" == "/mnt/leanfs" ]]; then
      pm2 restart leanfs > /dev/null 2>&1
      sleep 2
    fi

    # Create output and workload file names
    tag="${dir##*/}_${iosize}"
    workload_file="generated_${tag}.f"
    output_file="${template_name}-${tag}.out"

    # Generate workload file with substituted variables
    sed \
      -e "s|set \$dir=.*|set \$dir=$dir|" \
      -e "s|set \$iosize=.*|set \$iosize=$iosize|" \
      "$template_file" > "$workload_file"

    # Run and capture output
    filebench -f "$workload_file" | tee "$output_file" | grep "IO Summary:" > tmp_summary.txt
    pkill iostat
    rm "$workload_file"

    # Compute avg usr/sys, avg disk util from stat.log
    if [[ -f stat.log ]]; then
      stats=$(grep -v 'Average' stat.log | awk -v dev="${fs_map[$dir]}" ' /^avg-cpu:/ { getline; usr  += $1; sys  += $3; ncpu++ ; next } $1 == dev { util += $(NF); ndev++ } END { if (ncpu && ndev) printf "%.2f,%.2f,%.2f", usr/ncpu, sys/ncpu, util/ndev; else print ",,"; }')
    else
      stats=",,"
    fi

    # Parse IO Summary
    if [[ -s tmp_summary.txt ]]; then
      summary_line=$(cat tmp_summary.txt)

      if [[ $summary_line =~ ([0-9\.]+):\ IO\ Summary:\ *([0-9]+)\ ops\ ([0-9\.]+)\ ops/s\ ([0-9]+)/([0-9]+)\ rd/wr\ *([0-9\.a-zA-Z/]+)\ +([0-9\.]+)ms/op ]]; then
        ops="${BASH_REMATCH[2]}"
        ops_per_sec="${BASH_REMATCH[3]}"
        rd_ops="${BASH_REMATCH[4]}"
        wr_ops="${BASH_REMATCH[5]}"
        throughput="${BASH_REMATCH[6]}"
        latency="${BASH_REMATCH[7]}"
        echo "${dir##*/},$iosize,$ops,$ops_per_sec,$rd_ops,$wr_ops,$throughput,$latency,$stats" >> "$csv_file"
      else
        echo "${dir##*/},$iosize,PARSE_ERROR,,,,,,$stats" >> "$csv_file"
      fi
    else
      echo "${dir##*/},$iosize,NO_SUMMARY,,,,,,$stats" >> "$csv_file"
    fi

    echo
  done

  if [[ "$dir" == "/mnt/leanfs" ]]; then
    sleep 1
    pm2 stop leanfs > /dev/null 2>&1
    sleep 1
  fi
done

# Clean up temp
rm -f tmp_summary.txt
