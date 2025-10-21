#!/bin/bash

# NECCDC 2025 - Build All Required AMIs
# This script builds all custom AMIs needed for the blue team infrastructure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base directory
BASE_DIR="/mnt/c/Users/billn/Downloads/ccdc/neccdc-2025-public"

# Array of AMI builds (full_path:display_name)
declare -a BUILDS=(
    # Regional Pre-builds
    "ansible/regionals/pre/pfsense/packer:pfSense Firewall (Regional Pre)"
    "ansible/regionals/pre/windows/client/packer:Windows Workstation (Regional Pre)"
    "ansible/regionals/pre/windows/gui/packer:Windows GUI Server (Regional Pre)"
    "ansible/regionals/pre/teleport/packer:Teleport (Regional Pre)"
    "ansible/regionals/pre/kubernetes/ctrl-plane/packer:Kubernetes Control Plane (Regional Pre)"
    "ansible/regionals/pre/kubernetes/containerd/packer:Kubernetes Containerd Node (Regional Pre)"
    "ansible/regionals/pre/database/packer:Database Server (Regional Pre)"
    "ansible/regionals/pre/graylog/packer:Graylog Server (Regional Pre)"
)

# Function to print colored output
print_status() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check if directory exists
check_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        print_warning "Directory not found: $dir"
        return 1
    fi
    return 0
}

# Function to build a single AMI
build_ami() {
    local build_path="$1"
    local build_name="$2"
    local full_path="${BASE_DIR}/${build_path}"
    
    print_status "Starting build: $build_name"
    print_status "Build directory: $full_path"
    
    # Check if directory exists
    if ! check_directory "$full_path"; then
        print_error "Skipping $build_name - directory not found"
        return 1
    fi
    
    # Change to build directory
    if ! cd "$full_path"; then
        print_error "Failed to change to directory: $full_path"
        return 1
    fi
    
    # Check for required files
    if [ ! -f "builder.pkr.hcl" ]; then
        print_error "Skipping $build_name - builder.pkr.hcl not found"
        return 1
    fi
    
    print_status "Initializing Packer plugins..."
    if ! packer init .; then
        print_error "Failed to initialize Packer for $build_name"
        return 1
    fi
    
    print_status "Validating Packer configuration..."
    if ! packer validate .; then
        print_error "Packer validation failed for $build_name"
        return 1
    fi
    
    print_status "Building AMI for $build_name (this may take 20-30 minutes)..."
    if packer build -var-file="${BASE_DIR}/packer.pkrvars.hcl" .; then
        print_success "Successfully built AMI: $build_name"
        return 0
    else
        print_error "Failed to build AMI: $build_name"
        return 1
    fi
}

# Function to show cost estimate
show_cost_estimate() {
    local num_builds=${#BUILDS[@]}
    echo
    print_status "=== COST ESTIMATE ==="
    echo "Number of AMIs to build: $num_builds"
    echo "Estimated cost per AMI: \$0.50 - \$2.00"
    echo "Total estimated cost: \$$(echo "$num_builds * 0.5" | bc) - \$$(echo "$num_builds * 2" | bc)"
    echo "Estimated total time: $(echo "$num_builds * 25" | bc) minutes"
    echo
}

# Function to show build plan
show_build_plan() {
    print_status "=== BUILD PLAN ==="
    echo "The following AMIs will be built:"
    local i=1
    for build in "${BUILDS[@]}"; do
        IFS=':' read -r path name <<< "$build"
        echo "  $i. $name"
        ((i++))
    done
    echo
}

# Main function
main() {
    echo
    print_status "=== NECCDC 2025 AMI Builder ==="
    echo
    
    # Check if we're in WSL/Linux
    if [[ ! "$PWD" =~ ^/mnt/c ]]; then
        print_error "This script should be run from WSL (Windows Subsystem for Linux)"
        print_error "Current directory: $PWD"
        exit 1
    fi
    
    # Check if AWS credentials are configured
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        print_error "AWS credentials not configured or invalid"
        print_error "Please run: aws configure"
        exit 1
    fi
    
    print_success "AWS credentials validated"
    
    # Show build plan and cost estimate
    show_build_plan
    show_cost_estimate
    
    # Ask for confirmation
    read -p "Do you want to proceed with building all AMIs? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Build cancelled by user"
        exit 0
    fi
    
    # Initialize counters
    local success_count=0
    local failure_count=0
    local start_time=$(date +%s)
    
    print_status "Starting AMI builds..."
    echo
    
    # Build each AMI
    local total_builds=${#BUILDS[@]}
    local current_build=1
    
    for build in "${BUILDS[@]}"; do
        IFS=':' read -r path name <<< "$build"
        
        echo "=================================="
        print_status "Building AMI $current_build of $total_builds"
        print_status "Remaining: $((total_builds - current_build)) AMIs"
        echo "=================================="
        
        if build_ami "$path" "$name"; then
            ((success_count++))
            print_success "Completed $current_build of $total_builds builds"
        else
            ((failure_count++))
            print_error "Build failed for $name, but continuing with remaining builds..."
        fi
        
        ((current_build++))
        
        # Return to base directory for next build
        cd "$BASE_DIR" || {
            print_error "Critical: Failed to return to base directory"
            exit 1
        }
        
        if [ $current_build -le $total_builds ]; then
            print_status "Proceeding to next AMI build in 3 seconds..."
            sleep 3
        fi
        echo
    done
    
    # Calculate total time
    local end_time=$(date +%s)
    local total_time=$((end_time - start_time))
    local minutes=$((total_time / 60))
    local seconds=$((total_time % 60))
    
    # Show final results
    echo "=================================="
    print_status "=== BUILD SUMMARY ==="
    echo "Successful builds: $success_count"
    echo "Failed builds: $failure_count"
    echo "Total time: ${minutes}m ${seconds}s"
    echo
    
    if [ $failure_count -eq 0 ]; then
        print_success "All AMI builds completed successfully!"
        print_status "You can now deploy the blue team infrastructure with:"
        echo "  cd /mnt/c/Users/billn/Downloads/ccdc/neccdc-2025-public/terraform/regionals/environments/blue"
        echo "  terraform plan"
        echo "  terraform apply"
    else
        print_warning "Some builds failed. Check the output above for details."
        print_status "You may need to fix issues and re-run specific builds."
    fi
}

# Handle Ctrl+C gracefully
trap 'print_error "Build interrupted by user"; exit 130' INT

# Run main function
main "$@"