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
RUN curl -sSfL https://github.com/spacemeshos/post/releases/download/v0.10.1/postcli-Linux.zip -o postcli.zip && \
    unzip postcli.zip && \
    chmod +x postcli && \
    mv postcli /usr/local/bin/

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

# Your entry point or command to run postcli
ENTRYPOINT ["./entrypoint.sh"]

# Set the default command
CMD ["bash"]
