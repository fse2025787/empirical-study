#!/bin/bash

dataset_path="./mainnet"

log_file="run_sca.log"

start_time=$(date +%s)

for file in "$dataset_path"/*.sol; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "Processing file: $filename" >> "$log_file"
        sbt "run runTest mainnet_sample/$filename" >> "$log_file" 2>&1
        exit_code=$?
        echo "Exit status: $filename $exit_code" >> "$log_file"
        echo "" >> "$log_file"  
    fi
done

end_time=$(date +%s)

execution_time=$((end_time - start_time))

echo "Total execution time: $execution_time seconds" >> "$log_file"