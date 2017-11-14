FROM ubuntu:14.04
MAINTAINER caffe-maint@googlegroups.com

ADD sources.list /etc/apt/
#ENV http_proxy proxy:port
#ENV https_proxy proxy:port

RUN apt-get update && apt-get install -y --no-install-recommends \
        rsync \
        build-essential \
        cmake \
        git \
        wget \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-dev \
        python-numpy \
        python-pip \
        python-scipy && \
    rm -rf /var/lib/apt/lists/*

ENV CAFFE_ROOT=/opt/caffe
WORKDIR $CAFFE_ROOT

# FIXME: clone a specific git tag and use ARG instead of ENV once DockerHub supports this.
ENV CLONE_TAG=1.0.4

RUN git clone -b ${CLONE_TAG} https://github.com/intel/caffe.git . && \
    for req in $(cat python/requirements.txt) pydot; do pip install $req; done && \
    cp Makefile.config.example  Makefile.config && \
    # open notes
    sed -i 's/^# \(USE_MLSL\)/\1/' Makefile.config 

ENV LD_LIBRARY_PATH $CAFFE_ROOT/external/mlsl/l_mlsl_2017.1.016/intel64/lib

RUN make all -j"$(nproc)" && \
    # add classification validation
    ln -s $CAFFE_ROOT/build/examples/cpp_classification/classification.bin $CAFFE_ROOT/build/tools/classification.bin

ENV MLSL_NUM_SERVERS 0
ENV MLSL_ROOT $CAFFE_ROOT/external/mlsl/l_mlsl_2017.1.016
ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

WORKDIR /workspace
