# based on https://github.com/kivy/python-for-android/blob/master/Dockerfile

FROM ubuntu:20.04@sha256:86ac87f73641c920fb42cc9612d4fb57b5626b56ea2a19b894d0673fd5b4f2e9

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME="/opt"

ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"

# install system/build dependencies
# https://github.com/kivy/buildozer/blob/master/docs/source/installation.rst#android-on-ubuntu-2004-64bit
# TODO probably need to pin versions of at least some of these for over-time reproducibility?
RUN apt-get update -y -qq > /dev/null \
    && apt-get install -qq --yes --no-install-recommends locales \
    && locale-gen en_US.UTF-8 \
    && apt-get -y install -qq --no-install-recommends \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        wget \
        lbzip2 \
        patch \
        sudo \
        software-properties-common \
        git \
        zip \
        unzip \
        build-essential \
        ccache \
        openjdk-11-jdk-headless \
        autoconf \
        libtool \
        pkg-config \
        zlib1g-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libtinfo5 \
        cmake \
        libffi-dev \
        libssl-dev \
        automake \
        gettext \
        libltdl-dev \
        libgmp-dev \
        curl \
        ca-certificates \
        vim \
    && apt-get -y autoremove \
    && apt-get -y clean

# prepare non root env
ENV ANDROID_SDK_HOME="${ANDROID_HOME}/android-sdk"
ENV USER="buildozer"
ENV HOME_DIR="/home/${USER}"
ENV WORK_DIR="${HOME_DIR}/build" \
    PATH="${HOME_DIR}/.local/bin:${PATH}"
RUN useradd --create-home --shell /bin/bash ${USER} \
    && usermod -append --groups sudo ${USER} \
    && echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && mkdir -p ${WORK_DIR} \
    && chown -R ${USER}:${USER} ${WORK_DIR} ${ANDROID_HOME}

USER ${USER}
WORKDIR ${WORK_DIR}

ENV ANDROID_NDK_HOME="${ANDROID_HOME}/android-ndk"
ENV ANDROID_NDK_VERSION="22b"
ENV ANDROID_NDK_HASH="ac3a0421e76f71dd330d0cd55f9d99b9ac864c4c034fc67e0d671d022d4e806b"
ENV ANDROID_NDK_HOME_V="${ANDROID_NDK_HOME}-r${ANDROID_NDK_VERSION}"

# get the latest version from https://developer.android.com/ndk/downloads/index.html
ENV ANDROID_NDK_ARCHIVE="android-ndk-r${ANDROID_NDK_VERSION}-linux-x86_64.zip"
ENV ANDROID_NDK_DL_URL="https://dl.google.com/android/repository/${ANDROID_NDK_ARCHIVE}"


# download and install Android NDK
RUN curl --location --progress-bar \
        "${ANDROID_NDK_DL_URL}" \
        --output "${ANDROID_NDK_ARCHIVE}" \
    && echo "${ANDROID_NDK_HASH} ${ANDROID_NDK_ARCHIVE}" | sha256sum -c - \
    && mkdir --parents "${ANDROID_NDK_HOME_V}" \
    && unzip -q "${ANDROID_NDK_ARCHIVE}" -d "${ANDROID_HOME}" \
    && ln -sfn "${ANDROID_NDK_HOME_V}" "${ANDROID_NDK_HOME}" \
    && rm -rf "${ANDROID_NDK_ARCHIVE}"


# get the latest version from https://developer.android.com/studio/index.html
ENV ANDROID_SDK_TOOLS_VERSION="6514223"
ENV ANDROID_SDK_BUILD_TOOLS_VERSION="30.0.2"
ENV ANDROID_SDK_HASH="ef319a5afdb41822cb1c88d93bc7c23b0af4fc670abca89ff0346ee6688da797"
ENV ANDROID_SDK_TOOLS_ARCHIVE="commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip"
ENV ANDROID_SDK_TOOLS_DL_URL="https://dl.google.com/android/repository/${ANDROID_SDK_TOOLS_ARCHIVE}"
ENV ANDROID_SDK_MANAGER="${ANDROID_SDK_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_HOME}"

# download and install Android SDK
RUN curl --location --progress-bar \
        "${ANDROID_SDK_TOOLS_DL_URL}" \
        --output "${ANDROID_SDK_TOOLS_ARCHIVE}" \
    && echo "${ANDROID_SDK_HASH} ${ANDROID_SDK_TOOLS_ARCHIVE}" | sha256sum -c - \
    && mkdir --parents "${ANDROID_SDK_HOME}" \
    && unzip -q "${ANDROID_SDK_TOOLS_ARCHIVE}" -d "${ANDROID_SDK_HOME}" \
    && rm -rf "${ANDROID_SDK_TOOLS_ARCHIVE}"

# update Android SDK, install Android API, Build Tools...
RUN mkdir --parents "${ANDROID_SDK_HOME}/.android/" \
    && echo '### User Sources for Android SDK Manager' \
        > "${ANDROID_SDK_HOME}/.android/repositories.cfg"

# accept Android licenses (JDK necessary!)
RUN yes | ${ANDROID_SDK_MANAGER} --licenses > /dev/null

# download platforms, API, build tools
RUN ${ANDROID_SDK_MANAGER} "platforms;android-29" > /dev/null && \
    ${ANDROID_SDK_MANAGER} "build-tools;${ANDROID_SDK_BUILD_TOOLS_VERSION}" > /dev/null && \
    ${ANDROID_SDK_MANAGER} "extras;android;m2repository" > /dev/null && \
    chmod +x "${ANDROID_SDK_HOME}/tools/bin/avdmanager"

# download ANT
ENV APACHE_ANT_VERSION="1.9.4"
ENV APACHE_ANT_HASH="66d3edcbb0eba11387705cd89178ffb65e55cd53f13ca35c1bb983c0f9992540"
ENV APACHE_ANT_ARCHIVE="apache-ant-${APACHE_ANT_VERSION}-bin.tar.gz"
ENV APACHE_ANT_DL_URL="https://archive.apache.org/dist/ant/binaries/${APACHE_ANT_ARCHIVE}"
ENV APACHE_ANT_HOME="${ANDROID_HOME}/apache-ant"
ENV APACHE_ANT_HOME_V="${APACHE_ANT_HOME}-${APACHE_ANT_VERSION}"

RUN curl --location --progress-bar \
        "${APACHE_ANT_DL_URL}" \
        --output "${APACHE_ANT_ARCHIVE}" \
    && echo "${APACHE_ANT_HASH} ${APACHE_ANT_ARCHIVE}" | sha256sum -c - \
    && tar -xf "${APACHE_ANT_ARCHIVE}" -C "${ANDROID_HOME}" \
    && ln -sfn "${APACHE_ANT_HOME_V}" "${APACHE_ANT_HOME}" \
    && rm -rf "${APACHE_ANT_ARCHIVE}"

# prepare git
RUN git config --global user.name "John Doe" \
    && git config --global user.email johndoe@example.com

# install buildozer
RUN cd /opt \
    && git clone https://github.com/kivy/buildozer \
    && cd buildozer \
    && git remote add sombernight https://github.com/SomberNight/buildozer \
    && git fetch --all \
    # commit: from branch sombernight/electrum_20210421
    && git checkout "d570116e88184b0eca0c6b59a25edd49d977da23^{commit}" \
    && python3 -m pip install --no-dependencies --user -e .

# install python-for-android
RUN cd /opt \
    && git clone https://github.com/kivy/python-for-android \
    && cd python-for-android \
    && git remote add sombernight https://github.com/SomberNight/python-for-android \
    && git fetch --all \
    # commit: from branch sombernight/electrum_20210421b
    && git checkout "cdee188f0ef28ff8452207da409912da19e917ca^{commit}" \
    # revert: gradle: persist debug keystore
    && git revert --no-edit be4fa2ff63e70b64189a18f2edad92f87a8d8593 \
    && python3 -m pip install --no-dependencies --user -e .

# build env vars
ENV USE_SDK_WRAPPER=1
ENV GRADLE_OPTS="-Xmx1536M -Dorg.gradle.jvmargs='-Xmx1536M'"
