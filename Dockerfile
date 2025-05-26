FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Update package list and install required packages
RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    libgdcm-dev \
    libgdcm-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir \
    pydicom \
    numpy \
    gdcm

# Create working directory
WORKDIR /app

# Copy the dcm-sort-anon script
COPY dcm-sort-anon /usr/local/bin/dcm-sort-anon

# Make the script executable
RUN chmod +x /usr/local/bin/dcm-sort-anon

# Create wrapper script
RUN echo '#!/bin/bash' > /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '# Check if any arguments are provided' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo 'if [ $# -eq 0 ]; then' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '    dcm-sort-anon --help' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '    exit 0' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo 'fi' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '# Set working directory to /data' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo 'cd /data' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '# Create original directory if it does not exist' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo 'mkdir -p original' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '# Process each argument (patient directory)' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo 'for patient_dir in "$@"; do' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '    # Extract patient directory name' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '    patient_name=$(basename "$patient_dir")' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '    ' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '    # Check if the patient directory exists' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '    if [ ! -d "$patient_dir" ]; then' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '        echo "Error: Directory '"'"'$patient_dir'"'"' does not exist"' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '        exit 1' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '    fi' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '    ' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '    # Move patient directory to original if not already there' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '    if [ ! -d "original/$patient_name" ]; then' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '        echo "Moving $patient_dir to original/$patient_name"' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '        mv "$patient_dir" "original/$patient_name"' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '    fi' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo 'done' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '# Change to original directory and run dcm-sort-anon' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo 'cd original' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '# Build the argument list for dcm-sort-anon (just the patient names)' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo 'patient_args=""' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo 'for patient_dir in "$@"; do' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '    patient_name=$(basename "$patient_dir")' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '    patient_args="$patient_args $patient_name"' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo 'done' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo '' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo 'echo "Running dcm-sort-anon in original directory with: $patient_args"' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    echo 'dcm-sort-anon $patient_args' >> /usr/local/bin/dcm-sort-anon-wrapper && \
    chmod +x /usr/local/bin/dcm-sort-anon-wrapper

# Set working directory to /data
WORKDIR /data

# Set the entrypoint to the wrapper script
ENTRYPOINT ["dcm-sort-anon-wrapper"]

# Default command (shows help)
CMD []
