FROM ubuntu:14.04

# Multiverse
RUN echo "deb http://us.archive.ubuntu.com/ubuntu trusty main multiverse" >> /etc/apt/sources.list

# Use this to avoid prompts when installing and updating stuff
ENV DEBIAN_FRONTEND=noninteractive

MAINTAINER "Javier Sanchez Rois" <jsanchez@gradiant.org>

RUN apt-get update && apt-get install -y build-essential software-properties-common

RUN add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && apt-get install -y gcc-5 g++-5 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5

RUN apt-get update && \
    apt-get install -y libarmadillo-dev libboost-math-dev libgtk2.0-dev libdc1394-22 libdc1394-22-dev \
    libjpeg-dev libpng12-dev libtiff4-dev libjasper-dev libavcodec-dev libavformat-dev libswscale-dev \
    libxine-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libv4l-dev libtbb-dev libmp3lame-dev \
    libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils\
    libtesseract-dev libleptonica-dev tesseract-ocr-eng build-essential pkg-config unzip git cmake gcovr yasm \
    libprotobuf-dev libleveldb-dev libsnappy-dev libeigen3-dev \
    libhdf5-serial-dev protobuf-compiler libboost-all-dev \
    libgflags-dev libgoogle-glog-dev liblmdb-dev libatlas-base-dev && \
    libprotobuf-dev libleveldb-dev libsnappy-dev \
    libhdf5-serial-dev protobuf-compiler libboost-all-dev \
    libgflags-dev libgoogle-glog-dev liblmdb-dev libatlas-base-dev && \
    apt-get autoremove

RUN apt-get update && apt-get install -y wget

RUN \
  mkdir opencv && cd opencv && \
  wget --tries=0 --read-timeout=20 https://github.com/Itseez/opencv/archive/3.1.0.zip && \
  git clone https://github.com/opencv/opencv_contrib -b "3.1.0" && \
  cd /opencv && unzip 3.1.0.zip && cd opencv-3.1.0 && mkdir -p build && \
  cd /opencv/opencv-3.1.0/build && \
  cmake -DWITH_IPP=ON -DINSTALL_CREATE_DISTRIB=ON -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
	-DBUILD_DOCS=off \
        -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF \
	-DBUILD_opencv_apps=OFF \
        -DBUILD_opencv_aruco=OFF \
        -DBUILD_opencv_bgsegm=ON \
        -DBUILD_opencv_bioinspired=OFF \
        -DBUILD_opencv_calib3d=ON \
        -DBUILD_opencv_ccalib=ON \
        -DBUILD_opencv_cnn_3dobj=OFF \
        -DBUILD_opencv_contrib_world=OFF \
        -DBUILD_opencv_core=ON \
        -DBUILD_opencv_cvv=OFF \
        -DBUILD_opencv_datasets=OFF \
        -DBUILD_opencv_dnn=OFF \
        -DBUILD_opencv_dpm=OFF \
        -DBUILD_opencv_face=OFF \
        -DBUILD_opencv_features2d=ON \
        -DBUILD_opencv_flann=ON \
        -DBUILD_opencv_freetype=OFF \
        -DBUILD_opencv_fuzzy=OFF \
        -DBUILD_opencv_hdf=OFF \
        -DBUILD_opencv_highgui=ON \
        -DBUILD_opencv_imgcodecs=ON \
        -DBUILD_opencv_imgproc=ON \
        -DBUILD_opencv_line_descriptor=OFF \
        -DBUILD_opencv_ml=ON \
        -DBUILD_opencv_objdetect=ON \
        -DBUILD_opencv_optflow=OFF \
        -DBUILD_opencv_phase_unwrapping=OFF \
        -DBUILD_opencv_photo=ON \
        -DBUILD_opencv_plot=OFF \
        -DBUILD_opencv_reg=OFF \
        -DBUILD_opencv_rgbd=OFF \
        -DBUILD_opencv_saliency=OFF \
        -DBUILD_opencv_sfm=OFF \
        -DBUILD_opencv_shape=OFF \
        -DBUILD_opencv_stereo=ON \
        -DBUILD_opencv_stitching=ON \
        -DBUILD_opencv_structured_light=OFF \
        -DBUILD_opencv_superres=ON \
        -DBUILD_opencv_surface_matching=OFF \
        -DBUILD_opencv_text=OFF \
        -DBUILD_opencv_tracking=OFF \
        -DBUILD_opencv_ts=OFF \
        -DBUILD_opencv_video=ON \
        -DBUILD_opencv_videoio=ON \
        -DBUILD_opencv_videostab=ON \
        -DBUILD_opencv_viz=OFF \
        -DBUILD_opencv_world=OFF \
        -DBUILD_opencv_xfeatures2d=OFF \
        -DBUILD_opencv_ximgproc=OFF \
        -DBUILD_opencv_xobjdetect=OFF \
        -DBUILD_opencv_xphoto=OFF .. && \
        make -j4 && make install && \
        ldconfig && \
        rm -rf /opencv

RUN git clone https://github.com/BVLC/caffe.git && \
    mkdir caffe/build && cd caffe/build && \
    cmake -D ALLOW_LMDB_NOLOCK:BOOL=ON -D CMAKE_INSTALL_PREFIX:PATH=/usr/local -D BUILD_python=OFF -D CPU_ONLY=ON .. &&\
    make -j4 && make install && ldconfig && rm -rf /caffe

# CONAN 
RUN rm -rf /var/lib/apt/lists/* && \
	apt-get update && \
	apt-get install -y python-dev \
	sudo build-essential wget git vim libc6-dev-i386 \
	g++-multilib libgmp-dev libmpfr-dev libmpc-dev \
	libc6-dev nasm dh-autoreconf valgrind ninja-build libffi-dev libssl-dev

# Install CMake 3
RUN wget https://cmake.org/files/v3.8/cmake-3.8.1-Linux-x86_64.tar.gz --no-check-certificate && tar -xzf cmake-3.8.1-Linux-x86_64.tar.gz && cp -fR cmake-3.8.1-Linux-x86_64/* /usr && rm -rf cmake-3.8.1-Linux-x86_64 && rm cmake-3.8.1-Linux-x86_64.tar.gz

RUN wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate && python get-pip.py && pip install -U pip
RUN pip install conan
RUN groupadd 1001 -g 1001
RUN groupadd 1000 -g 1000
RUN groupadd 2000 -g 2000
RUN groupadd 999 -g 999
RUN useradd -ms /bin/bash conan -g 1001 -G 1000,2000,999 && echo "conan:conan" | chpasswd && adduser conan sudo
RUN echo "conan ALL= NOPASSWD: ALL\n" >> /etc/sudoers
USER conan
WORKDIR /home/conan
RUN mkdir -p /home/conan/.conan

ENTRYPOINT ["/bin/bash"]

