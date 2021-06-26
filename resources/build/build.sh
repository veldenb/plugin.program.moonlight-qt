#!/bin/bash

set -e

cd "$(dirname "$0")"

bash "$(bash ../bin/get-platform.sh)/build.sh"
