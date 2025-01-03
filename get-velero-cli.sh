#!/usr/bin/env bash

#------------------------------------------------------------------------------

# Copyright 2024 Nutanix, Inc
#
# Licensed under the MIT License;
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”),
# to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#------------------------------------------------------------------------------

# Maintainer:   Eric De Witte (eric.dewitte@nutanix.com)
# Contributors: 

#------------------------------------------------------------------------------
VELERORELEASE=$(curl -s https://api.github.com/repos/vmware-tanzu/velero/releases/latest | jq -r .tag_name)
if [[ ${VELERORELEASE} == "null" ]]; then
    echo "github api rate limiting blocked request"
    echo "get latest version failed. Exiting."
    exit 1
fi

echo "Downloading velero ${VELERORELEASE}"
url="https://github.com/vmware-tanzu/velero/releases/download/${VELERORELEASE}/velero-${VELERORELEASE}-linux-amd64.tar.gz"

# Download the file with wget and check for errors
wget -O velero_Linux_amd64.tar.gz "$url"
if [ $? -ne 0 ]; then
    echo "Download failed. Exiting."
    exit 1
fi

# Extract the downloaded file and check for errors
tar xzf velero_Linux_amd64.tar.gz 
if [ $? -ne 0 ]; then
    echo "Extraction failed. Exiting."
    exit 1
fi

VELERODIR=$(ls -d "velero-${VELERORELEASE}-linux-amd64")

# Make the file executable and move it to /usr/local/bin
chmod +x $VELERODIR/velero
if [ $? -eq 0 ]; then
    sudo mv $VELERODIR/velero /usr/local/bin
else
    echo "Failed to make velero executable. Exiting."
    exit 1
fi

# Clean up downloaded files
rm -f velero_Linux_amd64.tar.gz  $VELERODIR

# Success message
echo "velero CLI ${VELERORELEASE} installed successfully!"
echo "checking version"
velero version -n kommander

echo "setting default velero namespace to kommander"
velero client config set namespace=kommander