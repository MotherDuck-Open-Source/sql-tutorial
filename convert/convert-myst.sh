#!/bin/bash

PYTHON_SCRIPT="convert_myst.py"

# Check if the Python script exists
if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "Python script $PYTHON_SCRIPT not found!"
    exit 1
fi

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
echo "Created temporary directory: $TEMP_DIR"

# List of files to process
FILES_TO_PROCESS=(
    "1_intro-sql-1.md"
    "2_intro-sql-2.md"
    "3_sql-and-python.md"
)

# Copy specified files from parent directory to temp directory
echo "Copying files from parent directory to temporary directory..."
for file in "${FILES_TO_PROCESS[@]}"; do
    if [ -f "../$file" ]; then
        cp "../$file" "$TEMP_DIR"
        echo "Copied $file"
    else
        echo "Warning: $file not found in parent directory"
    fi
done

# Process copied .md files in the temp directory
for file in "${FILES_TO_PROCESS[@]}"; do
    if [ -f "$TEMP_DIR/$file" ]; then
        echo "Processing $file..."
        python "$PYTHON_SCRIPT" "$TEMP_DIR/$file" "$TEMP_DIR/${file%.md}.md"
    fi
done

# Convert all *.md files to .ipynb and move them to current directory
echo "Converting *.md files to .ipynb and moving them to the /notebooks directory..."
for file in "$TEMP_DIR"/*.md; do
    if [ -f "$file" ]; then
        jupytext "$file" --to ipynb
        mv "${file%.md}.ipynb" ../notebooks/
    fi
done

# Clean up: remove the temporary directory
echo "Cleaning up temporary directory..."
rm -r "$TEMP_DIR"

echo "All done!"