#!/bin/bash

##############################################################################
# OpenShift CRC (CodeReady Containers) Installation Script
# Author: Blessing Phiri
# Description: Automated installation of OpenShift CRC for local development
# Supported OS: Linux (RHEL/CentOS/Ubuntu), macOS
##############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CRC_VERSION="2.X.X"  # Update to latest version
INSTALL_DIR="$HOME/crc"
MIN_MEMORY_GB=9 #(16GB recommended for better performance)
MIN_CPU_CORES=4
MIN_STORAGE=35

##############################################################################
# Helper Functions
##############################################################################

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

##############################################################################
# System Check Functions
##############################################################################

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if [ -f /etc/redhat-release ]; then
            DISTRO="rhel"
        elif [ -f /etc/lsb-release ]; then
            DISTRO="ubuntu"
        else
            DISTRO="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    print_info "Detected OS: $OS ($DISTRO)"
}

check_requirements() {
    print_info "Checking system requirements..."
    
    # Check CPU cores
    if [[ "$OS" == "linux" ]]; then
        CPU_CORES=$(nproc)
    elif [[ "$OS" == "macos" ]]; then
        CPU_CORES=$(sysctl -n hw.ncpu)
    fi
    
    if [ "$CPU_CORES" -lt "$MIN_CPU_CORES" ]; then
        print_warning "Minimum $MIN_CPU_CORES CPU cores required. Found: $CPU_CORES"
    else
        print_success "CPU cores: $CPU_CORES ✓"
    fi
    
    # Check memory
    if [[ "$OS" == "linux" ]]; then
        TOTAL_MEMORY_GB=$(free -g | awk '/^Mem:/{print $2}')
    elif [[ "$OS" == "macos" ]]; then
        TOTAL_MEMORY_GB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
    fi
    
    if [ "$TOTAL_MEMORY_GB" -lt "$MIN_MEMORY_GB" ]; then
        print_error "Minimum ${MIN_MEMORY_GB}GB RAM required. Found: ${TOTAL_MEMORY_GB}GB"
        exit 1
    else
        print_success "Memory: ${TOTAL_MEMORY_GB}GB ✓"
    fi
    
    # Check disk space (need at least 35GB free)
    DISK_FREE_GB=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$DISK_FREE_GB" -lt 35 ]; then
        print_error "Minimum 35GB free disk space required. Found: ${DISK_FREE_GB}GB"
        exit 1
    else
        print_success "Disk space: ${DISK_FREE_GB}GB free ✓"
    fi
}

check_virtualization() {
    print_info "Checking virtualization support..."
    
    if [[ "$OS" == "linux" ]]; then
        if grep -E 'vmx|svm' /proc/cpuinfo > /dev/null; then
            print_success "Hardware virtualization enabled ✓"
        else
            print_error "Hardware virtualization not enabled. Please enable VT-x/AMD-V in BIOS"
            exit 1
        fi
        
        # Check if KVM is available
        if [ ! -e /dev/kvm ]; then
            print_warning "KVM not available. Installing KVM..."
            install_kvm
        else
            print_success "KVM available ✓"
        fi
    elif [[ "$OS" == "macos" ]]; then
        print_info "macOS detected. Ensure you have virtualization enabled."
    fi
}

install_kvm() {
    if [[ "$DISTRO" == "rhel" ]]; then
        sudo dnf install -y qemu-kvm libvirt virt-install
        sudo dnf install qemu-system virtiofsd
        sudo systemctl enable --now libvirtd
        sudo usermod -aG libvirt $USER

    elif [[ "$DISTRO" == "ubuntu" ]]; then
        sudo apt-get update
        sudo sudo apt install qemu-kvm libvirt-daemon libvirt-daemon-system
        sudo apt install qemu-system virtiofsd
        sudo systemctl enable --now libvirtd
        sudo usermod -aG libvirt $USER
    fi
    print_success "KVM installed successfully"
}

##############################################################################
# Installation Functions
##############################################################################

download_crc() {
    print_info "Downloading OpenShift CRC v${CRC_VERSION}..."
    
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    if [[ "$OS" == "linux" ]]; then
        DOWNLOAD_URL="https://developers.redhat.com/content-gateway/file/pub/openshift-v4/clients/crc/${CRC_VERSION}/crc-linux-amd64.tar.xz"
        ARCHIVE="crc-linux-amd64.tar.xz"
    elif [[ "$OS" == "macos" ]]; then
        DOWNLOAD_URL="https://developers.redhat.com/content-gateway/file/pub/openshift-v4/clients/crc/${CRC_VERSION}/crc-macos-installer.pkg"
        ARCHIVE="crc-macos-installer.pkg"
    fi
    
    print_info "Download URL: $DOWNLOAD_URL"
    print_warning "Note: You need a Red Hat account. Please download manually if needed."
    print_info "Visit: https://console.redhat.com/openshift/create/local"
    
    if command -v wget &> /dev/null; then
        wget -O "$ARCHIVE" "$DOWNLOAD_URL" || {
            print_error "Download failed. Please download manually from:"
            print_error "https://console.redhat.com/openshift/create/local"
            print_info "Then place the file in: $INSTALL_DIR"
            exit 1
        }
    elif command -v curl &> /dev/null; then
        curl -L -o "$ARCHIVE" "$DOWNLOAD_URL" || {
            print_error "Download failed. Please download manually."
            exit 1
        }
    else
        print_error "Neither wget nor curl found. Please install one."
        exit 1
    fi
    
    print_success "Download complete"
}

extract_crc() {
    print_info "Extracting CRC archive..."
    
    cd "$INSTALL_DIR"
    tar -xf crc-*.tar.xz
    
    # Move binary to a standard location
    CRC_DIR=$(find . -type d -name "crc-*" | head -n 1)
    sudo mv "$CRC_DIR/crc" /usr/local/bin/
    sudo chmod +x /usr/local/bin/crc
    
    print_success "CRC binary installed to /usr/local/bin/crc"
}

setup_crc() {
    print_info "Setting up CRC..."
    
    # Setup CRC (downloads OpenShift bundle)
    crc setup
    
    print_success "CRC setup complete"
}

configure_crc() {
    print_info "Configuring CRC with recommended settings..."
    
    # Set CPU and memory
    crc config set cpus 4
    crc config set memory 9216  # 9GB in MB
    crc config set disk-size 35
    
    # Enable monitoring
    crc config set enable-cluster-monitoring false  # Disable initially to save resources
    
    print_success "CRC configuration complete"
    
    print_info "Current configuration:"
    crc config view
}

##############################################################################
# Post-Installation
##############################################################################

start_crc() {
    print_info "Starting CRC cluster..."
    print_warning "This will take 5-10 minutes on first run..."
    
    # You'll need to provide your pull secret
    print_info "You need your pull secret from: https://console.redhat.com/openshift/create/local"
    
    crc start
    
    print_success "CRC cluster started successfully!"
}

display_info() {
    echo ""
    print_success "=================================="
    print_success "OpenShift CRC Installation Complete!"
    print_success "=================================="
    echo ""
    print_info "Next steps:"
    echo ""
    echo "1. Get your pull secret:"
    echo "   https://console.redhat.com/openshift/create/local"
    echo ""
    echo "2. Start CRC:"
    echo "   crc start"
    echo ""
    echo "3. Login to cluster:"
    echo "   eval \$(crc oc-env)"
    echo "   oc login -u developer https://api.crc.testing:6443"
    echo ""
    echo "4. Access web console:"
    echo "   crc console"
    echo ""
    echo "5. Stop CRC:"
    echo "   crc stop"
    echo ""
    echo "6. Delete CRC (cleanup):"
    echo "   crc delete"
    echo ""
    print_info "Documentation: https://crc.dev/crc/"
    echo ""
}

##############################################################################
# Main Installation Flow
##############################################################################

main() {
    echo ""
    print_info "=================================="
    print_info "OpenShift CRC Installation Script"
    print_info "=================================="
    echo ""
    
    detect_os
    check_requirements
    check_virtualization
    
    # Check if CRC is already installed
    if command -v crc &> /dev/null; then
        print_warning "CRC is already installed: $(crc version)"
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Exiting..."
            exit 0
        fi
    fi
    
    download_crc
    extract_crc
    setup_crc
    configure_crc
    display_info
}

# Run main function
main "$@"