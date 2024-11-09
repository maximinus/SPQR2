#!/bin/bash

# Initialize a variable to hold the total number of lines
total_lines=0

# Function to count lines in files with specific extensions
count_lines() {
    for file in $(find "$1" -type f \( -name "*.gd" -o -name "*.gdshader" \)); do
        # Count the lines in the file and add to the total
        lines_in_file=$(wc -l < "$file")
        total_lines=$((total_lines + lines_in_file))
    done
}

# Traverse the "scenes" directory
if [ -d "scenes" ]; then
    count_lines "scenes"
fi

# Traverse the "scripts" directory
if [ -d "scripts" ]; then
    count_lines "scripts"
fi

# Output the total number of lines
echo "Total lines of code: $total_lines"
