FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04
MAINTAINER contact@invasis.com

# Install base tools
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
	pkg-config \
	dh-autoreconf

# Install build & doc tools
RUN apt-get install -y --no-install-recommends \
        cmake \
	doxygen

# Install basic cli tools
RUN apt-get install -y --no-install-recommends \
        unzip \
        git \
        wget

# Install libs
RUN apt-get install -y --no-install-recommends \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libprotobuf-dev \
        libsnappy-dev \
	libavcodec-dev \
	libavformat-dev \
	libswscale-dev \
	libtbb2 \
	libtbb-dev \
	libjpeg-dev \
	libpng-dev \
	libtiff-dev \
	libjasper-dev \
	libdc1394-22-dev \
	libxine2-dev \
	zlib1g-dev \
	libvorbis-dev \
	libxvidcore-dev \
	libgstreamer0.10-dev \
	libgstreamer-plugins-base0.10-dev \
	gstreamer-tools \
	libv4l-dev \
	v4l-utils \
	libgdal-dev \
	libeigen3-dev \
	libcurl3-dev \
	x264 \
	x265 \
        protobuf-compiler \
	swig


# Install Python 2 & 3
RUN apt-get install -y --no-install-recommends \
	python-dev \
	python3-dev \
	python-numpy \
	python3-numpy \
	python-pip \
	python3-pip \
	python-virtualenv \
	python-wheel

# Install Java 8 JDK
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

RUN apt-get update && apt-get install -y --no-install-recommends \
	oracle-java8-installer

RUN apt-get install -y --no-install-recommends \
	oracle-java8-set-default

ENV JAVA_HOME "/usr/lib/jvm/java-8-oracle"


# CLEAN
RUN apt-get clean && rm -rf /var/lib/apt/lists/*


# Install OpenCV 3.1
ENV OPENCV_ROOT /opt/opencv-3.1.0
WORKDIR $OPENCV_ROOT

RUN git clone --branch master https://github.com/opencv/opencv.git .
RUN git checkout de35c59ba4cf863d014e130c9116a0d5dade7c91
WORKDIR $OPENCV_ROOT/build
RUN cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local -D CUDA_FAST_MATH:BOOL="1" -D WITH_NVCUVID:BOOL="1" -D WITH_CUBLAS:BOOL="1" -D BUILD_DOCS:BOOL="1" ..
RUN make -j7
RUN make install && echo "/usr/local/lib" | tee -a /etc/ld.so.conf.d/opencv.conf && ldconfig
RUN cp /opt/opencv-3.1.0/build/lib/cv2.so /usr/lib/python2.7/dist-packages/cv2.so

# Install Bazel
#WORKDIR /opt/bazel
#RUN wget https://github.com/bazelbuild/bazel/releases/download/0.2.2/bazel-0.2.2-jdk7-installer-darwin-x86_64.sh -O bazel-install.sh && bash bazel-install.sh
RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
RUN curl https://bazel.io/bazel-release.pub.gpg | apt-key add -
RUN apt-get update && apt-get install -y bazel

# Install Tensorflow
ENV TENSORFLOW_ROOT /opt/tensorflow
WORKDIR $TENSORFLOW_ROOT

ENV PYTHON_BIN_PATH="/usr/bin/python2.7"
ENV TF_NEED_CUDA=1
ENV TF_NEED_GCP=0
ENV TF_CUDA_VERSION=8.0
ENV TF_CUDA_COMPUTE_CAPABILITIES=3.0,3.5,5.2
ENV TF_CUDNN_VERSION=5
ENV CUDA_TOOLKIT_PATH=/usr/local/cuda
ENV CUDNN_INSTALL_PATH=$CUDA_TOOLKIT_PATH
ENV GCC_HOST_COMPILER_PATH=/usr/bin/gcc
ENV CC="/usr/bin/gcc"
ENV CXX="/usr/bin/g++"
ENV GCC_HOST_COMPILER_PATH=$CC
ENV BUILDFLAGS="--config=cuda --copt=-m64 --linkopt=-m64"
RUN git clone --branch master https://github.com/tensorflow/tensorflow.git .
RUN git checkout v0.11.0rc1

# Add build rule (https://github.com/cjweeks/tensorflow-cmake)
RUN echo "cc_binary(" >> tensorflow/BUILD
RUN echo "name = \"libtensorflow_all.so\"," >> tensorflow/BUILD
RUN echo "linkshared = 1," >> tensorflow/BUILD
RUN echo "linkopts = [\"-Wl,--version-script=tensorflow/tf_version_script.lds\"]," >> tensorflow/BUILD
RUN echo "deps = [" >> tensorflow/BUILD
RUN echo "\"//tensorflow/cc:cc_ops\"," >> tensorflow/BUILD
RUN echo "\"//tensorflow/core:framework_internal\"," >> tensorflow/BUILD
RUN echo "\"//tensorflow/core:tensorflow\"," >> tensorflow/BUILD
RUN echo "],)" >> tensorflow/BUILD

RUN ./configure
RUN bazel build -c opt //tensorflow:libtensorflow_all.so $BUILDFLAGS --spawn_strategy=standalone --genrule_strategy=standalone --verbose_failures
RUN cp bazel-bin/tensorflow/libtensorflow_all.so /usr/local/lib
RUN apt-get install -y rsync python-setuptools python3-setuptools
RUN bazel build -c opt tensorflow/tools/pip_package:build_pip_package $BUILDFLAGS --spawn_strategy=standalone --genrule_strategy=standalone --verbose_failures
RUN bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/pip
RUN pip2 install --upgrade pip
RUN pip2 install /tmp/pip/tensorflow-*.whl

RUN mkdir -p /usr/local/include/google/tensorflow
RUN cp -r tensorflow /usr/local/include/google/tensorflow/
RUN find /usr/local/include/google/tensorflow/tensorflow -type f  ! -name "*.h" -delete

RUN cp bazel-genfiles/tensorflow/core/framework/*.h  /usr/local/include/google/tensorflow/tensorflow/core/framework
RUN cp bazel-genfiles/tensorflow/core/kernels/*.h  /usr/local/include/google/tensorflow/tensorflow/core/kernels
RUN cp bazel-genfiles/tensorflow/core/lib/core/*.h  /usr/local/include/google/tensorflow/tensorflow/core/lib/core
RUN cp bazel-genfiles/tensorflow/core/protobuf/*.h  /usr/local/include/google/tensorflow/tensorflow/core/protobuf
RUN cp bazel-genfiles/tensorflow/core/util/*.h  /usr/local/include/google/tensorflow/tensorflow/core/util
RUN cp bazel-genfiles/tensorflow/cc/ops/*.h  /usr/local/include/google/tensorflow/tensorflow/cc/ops

RUN cp -r third_party /usr/local/include/google/tensorflow/
RUN rm -r /usr/local/include/google/tensorflow/third_party/py
RUN rm -r /usr/local/include/google/tensorflow/third_party/avro
