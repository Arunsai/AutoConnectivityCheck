#!/bin/bash

# Input and output file names
input_file="Telnet_Input.csv"
output_file="Telnet_Result.csv"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file '$input_file' not found."
    exit 1
fi

# Clear output file or create if it doesn't exist
> "$output_file"

# Header for the output CSV file
echo "Computer,Port1,Result1" > "$output_file"

# Skip the first line (header) and read subsequent lines of the input CSV file
tail -n +2 "$input_file" | while IFS=, read -r hostname port result; do
    # Test connectivity for each host and port
    nc -z -w 3 "$hostname" "$port"

    # Check the exit code to determine the connection status
    if [ $? -eq 0 ]; then
        result="Success"
    else
        result="Failed"
    fi

    # Append results to the output CSV file
    echo "$hostname,$port,$result" >> "$output_file"
done

echo "Connection testing completed. Results saved in $output_file"