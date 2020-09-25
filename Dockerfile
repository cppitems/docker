FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

ARG GITHUB_TOKEN
ARG NODE_VERSION=12.14.1
ARG LLVM=10
ENV NODE_VERSION $NODE_VERSION
ENV YARN_VERSION 1.13.0

#Common deps
RUN apt-get update && \
    apt-get -y install build-essential \
                       curl \
                       git \
                       gpg \
                       python \
                       wget \
                       pkg-config libx11-dev libxkbfile-dev libsecret-1-dev \                     
                       xz-utils && \
    rm -rf /var/lib/apt/lists/*

# install clangd and clang-tidy from the public LLVM PPA (nightly build / development version)
# and also the GDB debugger from the Ubuntu repos
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic main" > /etc/apt/sources.list.d/llvm.list && \
    apt-get update && \
    apt-get install -y \
                       clang-tools-$LLVM \
                       clangd-$LLVM \
                       clang-tidy-$LLVM \
                       clang-format-$LLVM \
					   libc++-$LLVM-dev \
					   libc++abi-$LLVM-dev \
					   lldb-$LLVM \
                       lld-$LLVM \
                       gcc-multilib \
                       g++-multilib \
                       gdb && \
    ln -s /usr/bin/llvm-nm-$LLVM /usr/bin/llvm-nm && \
	ln -s /usr/bin/llvm-ar-$LLVM /usr/bin/llvm-ar && \
    ln -s /usr/bin/lld-$LLVM /usr/bin/lld && \
    ln -s /usr/bin/clang-$LLVM /usr/bin/clang && \
    ln -s /usr/bin/clang++-$LLVM /usr/bin/clang++ && \
    ln -s /usr/bin/clang-cl-$LLVM /usr/bin/clang-cl && \
    ln -s /usr/bin/clang-check-$LLVM /usr/bin/clang-check && \
    ln -s /usr/bin/clang-format-$LLVM /usr/bin/clang-format && \
    ln -s /usr/bin/clang-cpp-$LLVM /usr/bin/clang-cpp && \
    ln -s /usr/bin/clang-tidy-$LLVM /usr/bin/clang-tidy && \
    ln -s /usr/bin/clangd-$LLVM /usr/bin/clangd

# Install latest stable CMake
ARG CMAKE_VERSION=3.18.1

RUN wget "https://cmake.org/files/v3.18/cmake-$CMAKE_VERSION-Linux-x86_64.sh" && \
    chmod a+x cmake-$CMAKE_VERSION-Linux-x86_64.sh && \
    ./cmake-$CMAKE_VERSION-Linux-x86_64.sh --prefix=/usr/ --skip-license && \
    rm cmake-$CMAKE_VERSION-Linux-x86_64.sh


#Install node and yarn
#From: https://github.com/nodejs/docker-node/blob/6b8d86d6ad59e0d1e7a94cec2e909cad137a028f/8/Dockerfile

# gpg keys listed at https://github.com/nodejs/node#release-keys
RUN set -ex \
    && for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    ; do \
    gpg --batch --keyserver ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --batch --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
    done

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
    esac \
    && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
    && curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs


RUN set -ex \
    && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
    ; do \
    gpg --batch --keyserver ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --batch --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
    done \
    && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
    && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
    && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
    && mkdir -p /opt/yarn \
    && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/yarn --strip-components=1 \
    && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
    && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz

WORKDIR /

## User account
# https://medium.com/@nielssj/docker-volumes-and-file-system-permissions-772c1aee23ca

RUN addgroup --gid 5555 theiaide
RUN adduser --disabled-password --gecos "" --uid 5555 --ingroup theiaide theia  
RUN usermod -a -G theiaide theia
# RUN useradd  -a -G theia theia
RUN cat /etc/group | grep theia
RUN cat /etc/passwd | grep theia

RUN chmod g+rw /home && \
    mkdir -p /home/project && \
    chown -R theia:theiaide /home/theia && \
    mkdir -p /home/theia/theia && \
    chown -R theia:theiaide /home/theia/theia && \
    chown -R theia:theiaide /home/project;

COPY .bashrc.append /home/theia/.bashrc.append
RUN cat /home/theia/.bashrc.append >> /home/theia/.bashrc

## wasi sysroot
# https://github.com/jedisct1/libclang_rt.builtins-wasm32.a
# https://00f.net/2019/04/07/compiling-to-webassembly-with-llvm-and-clang/
RUN mkdir /opt/wasm 
WORKDIR /opt/wasm
RUN wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-10/wasi-sysroot-10.0.tar.gz 
RUN tar -xvf wasi-sysroot-10.0.tar.gz
RUN wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-10/libclang_rt.builtins-wasm32-wasi-10.0.tar.gz
RUN tar -xvf libclang_rt.builtins-wasm32-wasi-10.0.tar.gz



USER theia

WORKDIR /home/theia
# install wasm runtime
RUN curl https://get.wasmer.io -sSfL | sh
RUN ls -la

# clone custom theia
RUN git clone --branch pmans --depth 1 https://github.com/cppitems/theia.git ./theia
WORKDIR /home/theia/theia
RUN ls -la

RUN yarn --cache-folder ./ycache && \
rm -rf ./ycache && yarn theia build --mode production && \
yarn theia download:plugins 

WORKDIR /home/theia/theia
# RUN rm -rf node_modules/

USER root
RUN ln -s /usr/bin/wasm-ld-$LLVM /usr/bin/wasm-ld
RUN tar -xvf /opt/wasm/libclang_rt.builtins-wasm32-wasi-10.0.tar.gz -C /usr/lib/llvm-10/lib/clang/10.0.0/

WORKDIR /opt
RUN git clone --branch llvmorg-10.0.1 --depth 1 https://github.com/llvm/llvm-project
RUN cd llvm-project/ && mkdir build && mkdir install 
WORKDIR /opt/llvm-project/build
RUN cmake -DLIBOMP_TSAN_SUPPORT=1 -DCMAKE_INSTALL_PREFIX=/opt/llvm-project/install ../openmp
RUN make install

USER theia
WORKDIR /home/theia/theia

RUN git config --global user.email "" 
RUN git config --global user.name "theia"
RUN git config --global core.filemode false

COPY .bashrc.wasmer /home/theia/.bashrc.wasmer
RUN cat /home/theia/.bashrc.wasmer >> /home/theia/.bashrc

RUN cat /home/theia/.bashrc

EXPOSE 3000
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/theia/plugins

ENTRYPOINT [ "node", "/home/theia/theia/examples/browser/src-gen/backend/main.js", "/home/project", "--hostname=0.0.0.0" ]
