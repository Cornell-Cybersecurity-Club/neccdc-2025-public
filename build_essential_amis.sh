#!/bin/bash

# NECCDC 2025 - Build Essential AMIs Only
# Builds the core AMIs needed for basic blue team deployment

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

BASE_DIR="/mnt/c/Users/billn/Downloads/ccdc/neccdc-2025-public/ansible/regionals/pre"

# Essential builds only
declare -a ESSENTIAL_BUILDS=(
    "pfsense/packer:pfSense Firewall"
    "database/packer:Database Server"
    "kubernetes/ctrl-plane/packer:Kubernetes Control Plane"
)

build_ami() {
    local build_path="$1"
    local build_name="$2"
    local full_path="${BASE_DIR}/${build_path}"
    
    print_status "Building: $build_name"
    cd "$full_path"
    
    packer init .
    packer validate .
    packer build .
    
    echo -e "${GREEN}✓ Completed: $build_name${NC}"
}

main() {
    print_status "Building essential AMIs only..."
    
    for build in "${ESSENTIAL_BUILDS[@]}"; do
        IFS=':' read -r path name <<< "$build"
        build_ami "$path" "$name"
    done
    
    print_status "Essential AMIs completed!"
}

main "$@"