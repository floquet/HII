#!/usr/bin/env bash
printf "%s\n" "$(tput bold)$(date) ${BASH_SOURCE[0]}$(tput sgr0)"

# docker run -it  -v /Users/dantopa:/dantopa ubuntu:25.04
# mkdir -p apt-get/log; cd apt-get/ ; apt-get update ; apt-get install -y vim
# select 2, 49
# cp /dantopa/repos-xiuhcoatl/github/hii/scripts/ubuntu-build-03.sh .
# chmod +x ubuntu-build-03.sh
# sudo ./ubuntu-build-03.sh 2>&1 | tee ubuntu-build.log

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
    # open-coarrays-bin
    opencoarrays
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
    #pbcopy          # Not typically in Ubuntu (it's macOS specific)
    #lsb-core        # Linux Standard Base core support
    lsb             # Linux Standard Base core support
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
    gzip            # Default for Linux, fast
    bzip2           # Better compression than gzip
    xz-utils        # High compression (used in .deb files)
    unzip           # Windows-compatible archives
    p7zip-full      # High compression (7-Zip)
    zstd            # Facebook's fast compression, used in Linux kernels
    atool           # Unified CLI for .zip, .tar, .gz, etc.
    dtrx            # Smart extractor (auto-detects format)
    lz4             # Extremely fast, low compression
    lrzip           # Long-range compression, good for large files
    ncompress       # Old Unix LZW compression
    p7zip-full
    pigz            # parallel gzip
    lbzip2          # Parallel bzip2
    pixz            # Parallel xz

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

new_step "Creating pass/fail logging"
sub_step "Creating log files"
    touch success.txt
    touch failure.txt
sub_step "Setting up logging variables"
    SUCCESS_LOG="success.txt"
    FAILURE_LOG="failure.txt"

new_step "System Update and Upgrade"
sub_step "Running apt-get update"
    apt-get update > "update.log" 2>&1
sub_step "Running apt-get upgrade"
    apt-get upgrade -y > "upgrade.log" 2>&1

new_step "Setting Timezone to Albuquerque"
timedatectl set-timezone America/Denver

new_step "Creating user john.beighle"
sub_step "Adding user with sudo privileges"
    useradd -m -s /bin/bash john.beighle
    echo "john.beighle:john.beighle" | chpasswd
    usermod -aG sudo john.beighle

new_step "Installing via apt-get"
for pkg in "${PACKAGES[@]}"; do
    sub_step "Installing ${pkg}"
    if apt-get install -y "$pkg" > "./log/${pkg}.log" 2>&1; then
        echo "$pkg: SUCCESS" >> $SUCCESS_LOG
    else
        echo "$pkg: FAILED" >> $FAILURE_LOG
        echo "Failed to install $pkg - check ./log/${pkg}.log for details"
    fi
done

new_step "Creating vim configuration in /etc/vim/vimrc"
    sudo bash -c 'cat > /etc/vim/vimrc << EOF
syntax on
set number
set ruler
set laststatus=2
set showmode
set title
set statusline=%F%m%r%h%w\ [%{&ff}]\ [%Y]\ [%l,%v][%p%%]
set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
set hlsearch
set incsearch
set ignorecase
set smartcase
EOF'  

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
    apt-get update >> "./apt-get/update.log" 2>&1

new_step "Switching to spack"
    sub_step "Cloning Spack as user john.beighle"
        su - john.beighle -c 'git clone -c feature.manyFiles=true https://github.com/spack/spack.git ~/spack'
    sub_step "Creating spack log directory"
        su - john.beighle -c 'mkdir -p ~/spack/log'
        su - john.beighle -c 'touch ~/spack/log/success.txt ~/spack/log/failure.txt'
    sub_step "cd /home/john.beighle"
        cd /home/john.beighle
    sub_step "initialize spack"
        source spack/share/spack/setup-env.sh
    sub_step "spack compiler find"
        spack compiler find 2>&1 | tee ~/spack/log/compiler_find.log
    sub_step "Installing base Python tools"
        spack install py-astropy 2>&1 | tee ~/spack/log/py-astropy.log
        spack install py-virtualenv 2>&1 | tee ~/spack/log/py-virtualenv.log
    sub_step "Installing Core Parallel Processing"
        spack install py-mpi4py 2>&1 | tee ~/spack/log/py-mpi4py.log
        spack install py-dask 2>&1 | tee ~/spack/log/py-dask.log
        spack install py-ray 2>&1 | tee ~/spack/log/py-ray.log
        spack install py-ipyparallel 2>&1 | tee ~/spack/log/py-ipyparallel.log
    sub_step "Installing GPU/Accelerator Support"
        spack install py-numba 2>&1 | tee ~/spack/log/py-numba.log
        spack install py-cupy 2>&1 | tee ~/spack/log/py-cupy.log
        spack install py-pycuda 2>&1 | tee ~/spack/log/py-pycuda.log
    sub_step "Installing Distributed Computing"
        spack install py-distributed 2>&1 | tee ~/spack/log/py-distributed.log
        spack install py-pyspark 2>&1 | tee ~/spack/log/py-pyspark.log
        spack install py-multiprocessing-logging 2>&1 | tee ~/spack/log/py-multiprocessing-logging.log
    sub_step "Installing Scientific Computing"
        spack install py-scipy 2>&1 | tee ~/spack/log/py-scipy.log
        spack install py-petsc4py 2>&1 | tee ~/spack/log/py-petsc4py.log
        spack install py-slepc4py 2>&1 | tee ~/spack/log/py-slepc4py.log
    sub_step "Installing Machine Learning"
        spack install py-pytorch 2>&1 | tee ~/spack/log/py-pytorch.log
        spack install py-tensorflow 2>&1 | tee ~/spack/log/py-tensorflow.log

display_total_elapsed_time

# TAU often needs to be built from source for best results
#sub_step "Downloading and installing TAU"
#wget http://tau.uoregon.edu/tau.tgz
#tar xf tau.tgz
#cd tau-2.*
#./configure -papi -pdt=/usr/local/pdtoolkit
#make install
