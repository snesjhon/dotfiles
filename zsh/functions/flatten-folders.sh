#!/bin/bash

# Script to move all files from subdirectories to their parent directory
# Usage: ./flatten-folders.sh <directory>

show_help() {
    cat << EOF
flatten-folders - Move files from subdirectories to parent directory

DESCRIPTION:
    This script takes a directory and moves all files from its subdirectories
    to the parent directory. Useful for flattening photo folders or any nested
    file structure.

USAGE:
    flatten-folders.sh <directory>
    flatten-folders.sh --help

ARGUMENTS:
    directory       Path to the directory containing subdirectories with files

OPTIONS:
    --help          Show this help message

EXAMPLES:
    # Flatten all photos in /2018/folder1 and /2018/folder2 to /2018
    flatten-folders.sh ~/Photos/2018

    # Before:
    #   /2018/folder1/photo1.jpg
    #   /2018/folder1/photo2.jpg
    #   /2018/folder2/photo3.jpg
    #
    # After:
    #   /2018/photo1.jpg
    #   /2018/photo2.jpg
    #   /2018/photo3.jpg

BEHAVIOR:
    - Moves all files from subdirectories to the target directory
    - Ignores hidden files (files starting with .)
    - Handles filename conflicts by appending _copy1, _copy2, etc.
    - Removes empty subdirectories after moving files
    - Preserves file extensions when renaming

EOF
}

# Check for help flag
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    show_help
    exit 0
fi

if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory>"
    echo "Example: $0 /path/to/2018"
    echo "Run '$0 --help' for more information"
    exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist"
    exit 1
fi

echo "Flattening folders in: $TARGET_DIR"
echo "Moving files from subdirectories to parent..."

# Find all files in subdirectories (not in the target directory itself)
find "$TARGET_DIR" -mindepth 2 -type f | while read -r file; do
    # Get the filename
    filename=$(basename "$file")

    # Skip hidden files (like .DS_Store)
    if [[ "$filename" == .* ]]; then
        echo "Skipping hidden file: $filename"
        continue
    fi

    # Destination is the target directory
    dest="$TARGET_DIR/$filename"

    # Handle name conflicts by adding _copy{number}
    if [ -f "$dest" ]; then
        base="${filename%.*}"
        ext="${filename##*.}"

        # If there's no extension, handle differently
        if [ "$base" = "$ext" ]; then
            counter=1
            while [ -f "$TARGET_DIR/${filename}_copy$counter" ]; do
                ((counter++))
            done
            dest="$TARGET_DIR/${filename}_copy$counter"
        else
            counter=1
            while [ -f "$TARGET_DIR/${base}_copy$counter.$ext" ]; do
                ((counter++))
            done
            dest="$TARGET_DIR/${base}_copy$counter.$ext"
        fi

        echo "Conflict: Renaming to $(basename "$dest")"
    fi

    # Move the file
    mv "$file" "$dest"
    echo "Moved: $file -> $dest"
done

echo "Done! Removing empty subdirectories..."

# Remove empty directories
find "$TARGET_DIR" -mindepth 1 -type d -empty -delete

echo "All files have been moved to $TARGET_DIR"
