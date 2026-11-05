
FROM apache/doris:all-in-one-4.1.3

USER root

# Install kebutuhan Miniforge
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        bzip2 && \
    rm -rf /var/lib/apt/lists/*

# Install Miniforge
RUN wget -q \
    https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh \
    -O /tmp/miniforge.sh && \
    bash /tmp/miniforge.sh -b -p /opt/miniforge3 && \
    rm -f /tmp/miniforge.sh

# Membuat environment Python 3.12.11
# Memasang dependency wajib Python UDF Doris
RUN /opt/miniforge3/bin/conda create -y \
    -n py312 \
    python=3.12.11 \
    pandas \
    pyarrow \
    libarrow-flight && \
    /opt/miniforge3/bin/conda clean -afy

# Memastikan direktori bisa diakses Doris
RUN chmod -R a+rX /opt/miniforge3
