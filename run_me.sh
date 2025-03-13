#!/bin/bash
# run_me.sh
set -e # Exit on error

# Define project directories (assuming you run this from the project root)
BASE_DIR=$(pwd)
ANNOTATIONS_DIR="$BASE_DIR/dataset/annotations"
IMAGES_DIR="$BASE_DIR/dataset/images"
TEMP_IMAGES_DIR="$IMAGES_DIR/temp_images"  # temporary folder for downloaded image tars
MERGED_IMAGES_DIR="$IMAGES_DIR/merged_images"  # final destination for images
CODE_DIR="$BASE_DIR/code"

# Create necessary directories if they don't exist
mkdir -p "$ANNOTATIONS_DIR" "$IMAGES_DIR" "$TEMP_IMAGES_DIR" "$MERGED_IMAGES_DIR"

# --- Step 1: Download Annotations ---
cd "$ANNOTATIONS_DIR" || exit

echo "Step 1: Downloading Annotations..."
echo "Current working directory: $(pwd)"
echo "Downloading positive-Annotation.zip and Annotation.zip..."

# Download positive-Annotation.zip and Annotation.zip if not already downloaded (-nc)
wget -nc http://aivc.ks3-cn-beijing.ksyun.com/data/public_data/SIXray/positive-Annotation.zip
wget -nc http://aivc.ks3-cn-beijing.ksyun.com/data/public_data/SIXray/Annotation.zip

# Note: SIXray-D.zip is assumed to be already in the folder.

echo "Unzipping all zip files..."
# Unzip all zip files (overwrite files if needed with -o)
for zipfile in *.zip; do
    echo "Extracting $zipfile..."
    unzip -o "$zipfile" -d .
done

# --- Step 2: Download Image Tars ---
cd "$TEMP_IMAGES_DIR" || exit
echo "Step 2: Downloading Image Tars..."
echo "Current working directory: $(pwd)"

# Loop to download JPEGImage.tar.gz00 to JPEGImage.tar.gz17
for i in {00..17}; do
    url="http://aivc.ks3-cn-beijing.ksyun.com/data/public_data/SIXray/JPEGImage.tar.gz$i"
    echo "Downloading $url..."
    wget -nc "$url"
done

echo "Downloading complete."

# --- Step 3: Merge Image Tar Files ---
# For each downloaded tar file, extract its content directly into the merged_images folder.
# The --strip-components=1 option removes the top-level directory in the tar so that only its contents are extracted.
echo "Step 3: Merging Image Tar Files..."
echo "Current working directory: $(pwd)"

for tarfile in "$TEMP_IMAGES_DIR"/*.tar.gz*; do
    echo "Extracting $tarfile into $MERGED_IMAGES_DIR..."
    tar -xf "$tarfile" --strip-components=1 -C "$MERGED_IMAGES_DIR"
done

# Optionally, remove the temporary images directory
echo "Removing temporary images directory..."
rm -rf "$TEMP_IMAGES_DIR"

# --- Step 4: Install dependencies ---
echo "Step 4: Installing dependencies..."
cd "$CODE_DIR" || exit
echo "Current working directory: $(pwd)"

# Install dependencies using pip
pip install -r "$CODE_DIR/requirements.txt"


echo "All steps completed successfully."
