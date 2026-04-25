#!/usr/bin/env bash
set -e

sudo apt-get update
sudo apt-get install -y unzip jq tree

terraform -version
git --version
