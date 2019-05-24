FROM debian:9

MAINTAINER Maksim Rakitin <mrakitin@bnl.gov>

RUN apt-get update && \
    apt-get install -y  \
      autoconf \
      build-essential \
      bzip2 \
      gcc \
      g++ \
      git \
      make \
      patch \
      tar \
      # downloaders
      wget curl \
      zlib1g-dev \
      sed \
      libreadline6-dev \
      libglib2.0-0 \
      libxext6 libxext-dev \
      libxrender1 libxrender-dev \
      libsm6 libsm-dev \
      libsmbclient-dev \
      tk-dev \
      libx11-6 libx11-dev libgtk2.0-0 \
      # gobject-introspection
      flex \
      # install extra packages for gobject-introspection package
      libffi-dev \
      libssl-dev \
      bison \
      # install packages for hkl
      gtk-doc-tools \
      # need an editor...
      vim \
      # and one for tom...
      emacs \
      # X11 support for some graphical packages
      xvfb \
      # killall and friends
      psmisc procps htop

# Set the Locale so conda doesn't freak out
# It is roughly this problem: http://stackoverflow.com/questions/14547631/python-locale-error-unsupported-locale-setting
# I don't remember exactly where I found this solution, but it took about 2 days of
# intense googling and trial-and-error
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && \
    apt-get install -y locales -qq && \
    locale-gen en_US.UTF-8 en_us && \
    dpkg-reconfigure locales && \
    dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

# bash-git-prompt:
RUN git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1

# Dot files:
RUN cd && git clone https://github.com/mrakitin/dotfiles && \
    cp -v dotfiles/bashrc /root/.bashrc && \
    cp -v dotfiles/vimrc /root/.vimrc && \
    cp -v dotfiles/bash_history /root/.bash_history && \
    rm -rfv dotfiles/

ENV HISTFILE=/root/.bash_history

# Add the conda binary folder to the path
ENV PATH /conda/bin:$PATH

# Actually install miniconda
# Miniconda 4.5.11 already has Python 3.7 as a default interpreter, so
# we use version 4.5.4 which still uses Python 3.6
RUN cd && \
    wget https://repo.continuum.io/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh --no-verbose && \
    bash Miniconda3-4.5.4-Linux-x86_64.sh -b -p /conda && \
    rm Miniconda*.sh

ENV CONDARC_PATH /root/.condarc
ENV CONDARC $CONDARC_PATH
ENV PYTHONUNBUFFERED 1

RUN echo "binstar_upload: false\n\
always_yes: true\n\
show_channel_urls: true\n\
channels:\n\
- lightsource2-tag\n\
- defaults" > $CONDARC_PATH

# And set the correct environmental variable that lets us use it

RUN conda info
RUN conda config --show-sources
RUN conda list --show-channel-urls
RUN cat $CONDARC_PATH
RUN conda install collection=2019C2.0 -y
RUN conda info
RUN conda config --show-sources
RUN conda list --show-channel-urls
