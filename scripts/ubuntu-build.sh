#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# sudo ./ubuntu-build.sh 2>&1 | tee ubuntu-build.log

counter=0
subcounter=0
start_time=${SECONDS}

function new_step() {
    export counter=$((counter + 1))
    export subcounter=0
    echo ""
    echo "Step ${counter}: ${1}"
}

function sub_step() {
    export subcounter=$((subcounter + 1))
    echo ""
    echo "  Substep ${counter}.${subcounter}: ${1}"
}

function display_total_elapsed_time() {
    local total_elapsed_time=$((SECONDS - start_time))
    local total_minutes=$((total_elapsed_time / 60))
    local total_seconds=$((total_elapsed_time % 60))
    echo ""
    printf "Total elapsed time: %02d:%02d (MM:SS)\n" "$total_minutes" "$total_seconds"
}

PACKAGES=(
    # Build essentials and compilers
    build-essential
    gcc
    g++
    gfortran
    clang
    flang
    pkg-config
    pkgconf
    binutils
    
    # CMake packages
    cmake             # Basic CMake
    cmake-curses-gui  # ccmake terminal UI
    cmake-qt-gui      # cmake-gui graphical interface
    cmake-doc         # Documentation
    cmake-data        # Architecture independent files

    # Extra build tools
    ninja-build       # Ninja build system
    
    # Parallel Fortran
    open-coarrays-bin
    libcoarrays-dev
    gfortran 
    
    # Parallel Languages
    chapel
    chapel-doc   
    
    # Parallel C/C++ Frameworks
    libupcxx-dev        # UPC++ distributed computing
    libhpx-dev          # HPX parallel runtime system
    libhpx-plugins-dev  # HPX plugins
    charm++             # Charm++ parallel programming framework
    libopenmpi-dev      # OpenMPI for MPI programs
    libmpich-dev        # MPICH alternative MPI implementation
    libomp-dev          # OpenMP support
    libopenacc-dev      # OpenACC support
    libkokkos-dev       # Kokkos performance portability
    libthrust-dev       # NVIDIA Thrust template library
    libtbb-dev          # Intel Threading Building Blocks
    
    # Julia Language and Tools
    julia             # Base Julia
    julia-doc         # Documentation
    julia-common      # Architecture independent files
    libjulia-dev     # Development files
    
    # Octave and Toolboxes F@&^ MATLAB: they charge for this
    octave                    # Base system
    octave-control           # Control systems
    octave-signal           # Signal processing
    octave-statistics       # Statistics and probability
    octave-image            # Image processing
    octave-io              # Input/output functions
    octave-optim           # Optimization
    octave-symbolic        # Symbolic math
    octave-linear-algebra  # Linear algebra
    octave-parallel        # Parallel computing
    octave-communications  # Communications
    octave-financial       # Financial tools
    octave-data-smoothing # Data smoothing
    octave-database       # Database interface
    octave-doc           # Documentation
    octave-general      # General tools
    octave-geometry     # Geometry
    octave-miscellaneous # Miscellaneous tools
    octave-nan          # Statistics with missing data
    octave-nurbs       # Non-uniform rational B-splines
    octave-ocs        # Circuit simulation
    octave-odepkg    # ODE solvers
    octave-optiminterp # Optimal interpolation
    octave-specfun    # Special functions
    octave-strings    # String manipulation
    octave-struct    # Structure handling
    
    # Programming Languages and Development Tools
    golang-go        # Go programming language
    cargo           # Rust package manager
    rustc           # Rust compiler
    rust-src        # Rust source code
    rust-doc        # Rust documentation
    rust-gdb        # GDB for Rust
    rust-lldb       # LLDB for Rust
    zig             # Zig compiler and tools
    
    # Visualization and Debug Tools
    paraview
    paraview-dev
    paraview-python
    
    # Debug tools
    gdb
    lldb
    valgrind
    strace
    ltrace

    # Performance analysis and monitoring
    perf
    systemtap
    oprofile
    htop
    iotop
    iftop
    dstat
    bpfcc-tools
    iperf3
    libpapi-dev 
    papi-tools
    pdtoolkit
    likwid           # Performance monitoring and benchmarking
    scorep           # Scalable performance measurement tool
    otf2-tools       # Open Trace Format 2 tools
    extrae           # Dynamic instrumentation package
    paraver          # Parallel program visualization and analysis tool
    
    # Network analysis and utilities
    nmap
    net-tools
    tcpdump
    wireshark
    curl
    wget
    traceroute

    # Version control
    git

    # Programming languages and package managers
    python3
    python3-pip

    # crumbs
    cdf             # Common Data Format utilities
    dialog          # Display dialog boxes from shell scripts
    dos2unix        # Text file format converters
    fio             # Flexible I/O tester
    gedit           # GNOME text editor
    intltool        # Internationalization tool
    lshw            # Hardware lister
    lsof            # List open files
    ncurses         # Terminal interface library
    pbcopy          # Not typically in Ubuntu (it's macOS specific)
    lsb-core        # Linux Standard Base core support
    rsync           # Fast, versatile file copying tool
    ssh             # Secure shell client and server
    time            # Program resource usage measurement
    tree            # Display directory tree structure
    nvim            # Jake has a sweet implementation
    vim             # Vi IMproved text editor
    vtop            # Visual system monitor
    xclip 
    xsel
    zip             # Compression utility

    # LLVM toolchain
    llvm
    llvm-dev
    clang
    clang-tools
    clang-format
    flang
    mlir
    lld
    libomp-dev
    libclang-dev
    libmlir-dev
    libllvm-dev
    )

##     ##     ##     ##     ##     ##     ##     ##     ##     ##     ##     ##     ##     ##     ##

new_step "System Update and Upgrade"
sub_step "Running apt-get update"
    apt-get update
sub_step "Running apt-get upgrade"
    apt-get upgrade -y
    
new_step "Adding latest LLVM repository"
sub_step "wget https://apt.llvm.org/llvm-snapshot.gpg.key"
    wget https://apt.llvm.org/llvm-snapshot.gpg.key
sub_step "gpg --dearmor llvm-snapshot.gpg.key"
    gpg --dearmor llvm-snapshot.gpg.key
sub_step "mv llvm-snapshot.gpg.key.gpg /etc/apt/trusted.gpg.d/llvm-snapshot.gpg"
    mv llvm-snapshot.gpg.key.gpg /etc/apt/trusted.gpg.d/llvm-snapshot.gpg
sub_step "echo ... >> /etc/apt/sources.list.d/llvm.list"
    echo "deb http://apt.llvm.org/noble/ llvm-toolchain main" >> /etc/apt/sources.list.d/llvm.list
sub_step "apt-get update (again)"
    apt-get update

new_step "Setting Timezone to Albuquerque"
timedatectl set-timezone America/Denver

new_step "Creating user john.beighle"
sub_step "Adding user with sudo privileges"
    useradd -m -s /bin/bash john.beighle
    echo "john.beighle:john.beighle" | chpasswd
    usermod -aG sudo john.beighle

new_step "Installing via apt-get"
for pkg in "${PACKAGES[@]}"; do
    sub_step "apt-get install -y ${pkg}"
    apt-get install -y ${pkg} > "${LOG_DIR}/${pkg}.log" 2>&1
    if [ $? -eq 0 ]; then
        echo "Successfully installed ${pkg}"
    else
        echo "Error installing ${pkg}. Check ${LOG_DIR}/${pkg}.log"
    fi
done

new_step "Creating spack for user john.beighle"
    sub_step "Cloning Spack as user john.beighle"
        su - john.beighle -c 'git clone -c feature.manyFiles=true https://github.com/spack/spack.git ~/spack'
    sub_step "Finding system compilers"
        su - john.beighle -c 'source ~/spack/share/spack/setup-env.sh && spack compiler find'
    sub_step "Adding Spack to john.beighle's environment"
        su - john.beighle -c 'echo ". ~/spack/share/spack/setup-env.sh" >> ~/.bashrc'
    sub_step "Installing py-astropy"
        su - john.beighle -c 'source ~/spack/share/spack/setup-env.sh && spack install py-astropy'
    
display_total_elapsed_time

# TAU often needs to be built from source for best results
#sub_step "Downloading and installing TAU"
#wget http://tau.uoregon.edu/tau.tgz
#tar xf tau.tgz
#cd tau-2.*
#./configure -papi -pdt=/usr/local/pdtoolkit
#make install
