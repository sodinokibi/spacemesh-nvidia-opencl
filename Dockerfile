# Use the official NVIDIA CUDA image as a base if you need CUDA
FROM nvidia/cuda:12.1.0-devel-ubuntu22.04

# Label the image
LABEL com.nvidia.volumes.needed="nvidia_driver"

# Update and install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        wget \
        ocl-icd-libopencl1 \
        opencl-headers \
        clinfo \
        rsync \
        xxd \
        tmux \
        unzip \
        openssh-server \
        pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Install rclone
RUN curl https://rclone.org/install.sh | bash

# Set up OpenCL ICD for NVIDIA
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# Set up NVIDIA driver libraries
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

# Environment variables for NVIDIA
ENV PATH /usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# Download and install postcli
RUN curl -sSfL https://github.com/spacemeshos/post/releases/download/v0.8.9/postcli-Linux.zip -o postcli.zip && \
    unzip postcli.zip && \
    chmod +x postcli && \
    mv postcli /usr/local/bin/ && \
    # Move libpost.so to a standard library directory and update linker cache
    mv libpost.so /usr/local/lib/ && \
    ldconfig

# Set default environment variables
ENV PROVIDER=0 \
    COMMITMENT_ATX_ID=your_commitment_atx_id \
    ID=your_id \
    LABELS_PER_UNIT=4294967296 \
    MAX_FILE_SIZE=2147483648 \
    NUM_UNITS=420 \
    DATADIR=/your/work/dir \
    RANGE_START=0 \
    RANGE_END=100

# Set the working directory to your DATADIR
WORKDIR /home/user/post

# Accept the public key from an environment variable
ENV avain_ssh

# Create the user directory and authorized_keys file
RUN mkdir -p /root/.ssh && \
    echo "${avain_ssh}" > /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys

# Configure SSH to start on boot and run on port 26177
RUN mkdir /var/run/sshd && \
    echo 'Port 22' >> /etc/ssh/sshd_config && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port 8080 for the rclone serve
EXPOSE 8081

# Set the entrypoint to run the script
ENTRYPOINT ["/entrypoint.sh"]
