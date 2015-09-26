FROM trenpixster/elixir
MAINTAINER Takuma Yoshida <me@yoavlt.com>

RUN mkdir /ffmpeg
WORKDIR /ffmpeg

RUN apt-get update && apt-get install -y -q mercurial

RUN git clone --depth 1 https://github.com/l-smash/l-smash
RUN git clone --depth 1 https://github.com/yasm/yasm.git
RUN git clone --depth 1 git://git.videolan.org/x264.git
RUN hg clone https://bitbucket.org/multicoreware/x265
RUN git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git
RUN git clone --depth 1 https://chromium.googlesource.com/webm/libvpx
RUN git clone --depth 1 git://source.ffmpeg.org/ffmpeg
RUN git clone --depth 1 https://github.com/xiph/opus.git
RUN git clone --depth 1 https://github.com/mulx/aacgain.git

WORKDIR /ffmpeg/l-smash
RUN ./configure
RUN make -j 8
RUN make install

RUN apt-get install -y -q cmake
RUN apt-get install -y -q yasm

WORKDIR /ffmpeg/x264
RUN ./configure --enable-static --disable-opencl
RUN make -j 8
RUN make install

WORKDIR /ffmpeg/x265/linux/build
RUN cmake ../../source
RUN make -j 8
RUN make install

RUN apt-get install -y -q dh-autoreconf

WORKDIR /ffmpeg/fdk-aac
RUN autoreconf -fiv
RUN ./configure --disable-shared
RUN make -j 8
RUN make install

WORKDIR /ffmpeg/libvpx
RUN ./configure --disable-examples
RUN make -j 8
RUN make install

WORKDIR /ffmpeg/opus
RUN ./autogen.sh
RUN ./configure --disable-shared
RUN make -j 8
RUN make install

RUN apt-get install -y -q libass-dev
RUN apt-get install -y -q libmp3lame-dev
RUN apt-get install -y -q libtheora-dev
RUN apt-get install -y -q libvorbis-dev

WORKDIR /ffmpeg/ffmpeg
RUN ./configure --extra-libs="-ldl" --enable-gpl --enable-libass --enable-libfdk-aac --enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --enable-nonfree
RUN make -j 8
RUN make install

WORKDIR /ffmpeg/aacgain/mp4v2
RUN ./configure && make -k -j 8

WORKDIR /ffmpeg/aacgain/faad2
RUN ./configure && make -k -j 8

WORKDIR /ffmpeg/aacgain
RUN ./configure && make -j 8 && make install

RUN rm -rf /ffmpeg
