#!/bin/bash

# NECCDC 2025 Single AMI Builder
# Build one AMI at a time

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_status() { echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Available builds
declare -A BUILDS

# Regional Pre-builds
BUILDS["1"]="ansible/regionals/pre/pfsense/packer:pfSense Firewall (Regional Pre)"
BUILDS["2"]="ansible/regionals/pre/windows/client/packer:Windows Workstation (Regional Pre)"
BUILDS["3"]="ansible/regionals/pre/windows/gui/packer:Windows Server (Regional Pre)"
BUILDS["4"]="ansible/regionals/pre/teleport/packer:Teleport (Regional Pre)"
BUILDS["5"]="ansible/regionals/pre/kubernetes/ctrl-plane/packer:Kubernetes Control Plane (Regional Pre)"
BUILDS["6"]="ansible/regionals/pre/kubernetes/containerd/packer:Kubernetes Containerd Node (Regional Pre)"
BUILDS["7"]="ansible/regionals/pre/database/packer:Database Server (Regional Pre)"
BUILDS["8"]="ansible/regionals/pre/graylog/packer:Graylog Server (Regional Pre)"

# Qualifiers Pre-builds
BUILDS["9"]="ansible/qualifiers/pre/database/packer:Database Server (Qualifier Pre)"
BUILDS["10"]="ansible/qualifiers/pre/kubernetes/packer:Kubernetes (Qualifier Pre)"
BUILDS["11"]="ansible/qualifiers/pre/windows/packer:Windows (Qualifier Pre)"

# Function to show menu
show_menu() {
    echo "=================================="
    echo "NECCDC 2025 - Single AMI Builder"
    echo "=================================="
    echo "Select an AMI to build:"
    echo
    for key in $(echo ${!BUILDS[@]} | tr ' ' '\n' | sort -n); do
        IFS=':' read -r path name <<< "${BUILDS[$key]}"
        echo "$key) $name"
    done
    echo
    echo "0) Exit"
    echo "=================================="
}

# Function to build single AMI
build_single_ami() {
    local selection=$1
    
    if [[ ! ${BUILDS[$selection]} ]]; then
        print_error "Invalid selection"
        return 1
    fi
    
    IFS=':' read -r path name <<< "${BUILDS[$selection]}"
    local full_path="/mnt/c/Users/billn/Downloads/ccdc/neccdc-2025-public/$path"
    
    echo "=================================="
    print_status "Building: $name"
    print_status "Path: $path"
    echo
    
    # Check if directory exists
    if [ ! -d "$full_path" ]; then
        print_error "Directory not found: $full_path"
        return 1
    fi
    
    # Change to build directory
    cd "$full_path"
    
    # Check for required files
    if [ ! -f "builder.pkr.hcl" ]; then
        print_error "builder.pkr.hcl not found in $full_path"
        return 1
    fi
    
    print_status "Initializing Packer plugins..."
    if ! packer init .; then
        print_error "Failed to initialize Packer"
        return 1
    fi
    
    print_status "Validating Packer configuration..."
    if ! packer validate .; then
        print_error "Packer validation failed"
        return 1
    fi
    
    print_status "Building AMI for $name (this may take 20-30 minutes)..."
    echo "Press Ctrl+C to cancel if needed"
    echo
    
    if packer build .; then
        echo
        print_success "Successfully built AMI: $name"
        echo "=================================="
        return 0
    else
        echo
        print_error "Failed to build AMI: $name"
        echo "=================================="
        return 1
    fi
}

# Main function
main() {
    # Check AWS credentials
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        print_error "AWS credentials not configured"
        print_error "Please run: aws configure"
        exit 1
    fi
    
    while true; do
        show_menu
        read -p "Enter your choice (0-11): " choice
        echo
        
        case $choice in
            0)
                print_status "Goodbye!"
                exit 0
                ;;
            [1-9]|1[01])
                build_single_ami "$choice"
                echo
                read -p "Press Enter to continue..." 
                ;;
            *)
                print_error "Invalid choice. Please enter 0-11."
                echo
                ;;
        esac
    done
}

# Run main function
main "$@"