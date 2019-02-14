FROM ubuntu:16.04
MAINTAINER Madhur Behl <madhur.behl@virginia.edu>

#

ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's#http://archive.ubuntu.com/#http://tw.archive.ubuntu.com/#' /etc/apt/sources.list

# built-in packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common curl \
    && sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list" \
    && curl -SL http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key | apt-key add - \
    && add-apt-repository ppa:fcwu-tw/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        supervisor \
        openssh-server pwgen sudo vim-tiny \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        libreoffice firefox \
        fonts-wqy-microhei \
        language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant libreoffice-l10n-zh-tw \
        nginx \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine pinta arc-theme \
        dbus-x11 x11-utils \
        vlc flvstreamer ffmpeg \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Ergänzung für vlc unter root
RUN cp /usr/bin/vlc /usr/bin/vlc_backup
RUN sed -i 's/geteuid/getppid/' /usr/bin/vlc

# tini
ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

ADD image /
RUN pip install setuptools wheel && pip install -r /usr/lib/web/requirements.txt

# Install useful tools
RUN apt-get update && apt-get install -q -y \
	    tmux \
	    zsh \
	    curl \
	    wget \
	    emacs24 \
	    libgl1-mesa-glx \
	    unzip \
      dirmngr \
      gnupg2 \
      lsb-release \
	    && rm -rf /var/likb/apt/lists/*

# ===== xenial/ros-core/ install

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    && rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

# install ros packages
ENV ROS_DISTRO kinetic
RUN apt-get update && apt-get install -y \
    ros-kinetic-ros-core=1.3.2-0* \
    && rm -rf /var/lib/apt/lists/*

# ===== ros-base desktop percept robot and desktop full install

# install ros packages
RUN apt-get update && apt-get install -y \
    ros-kinetic-ros-base=1.3.2-0* \
    ros-kinetic-robot=1.3.2-0* \
    ros-kinetic-desktop=1.3.2-0* \
    #ros-kinetic-perception=1.3.2-0* \
    ros-kinetic-desktop-full=1.3.2-0* \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep update

# Install dependencies for the F1/10 Tutorials
RUN apt-get update && apt-get install -y \
    python-rosinstall-generator \
    ros-kinetic-ros-control \
    ros-kinetic-gazebo-ros-control \
    ros-kinetic-ros-controllers \
    ros-kinetic-navigation qt4-default \
    ros-kinetic-ackermann-msgs \
    ros-kinetic-serial \
    ros-kinetic-teb-local-planner*

# Update Gazebo 7
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
RUN apt-get update && apt-get --yes install -y gazebo7 libignition-math2-dev

# setup ROS workspace
RUN mkdir -p /home/catkin_ws/src
RUN /bin/bash -c '. /opt/ros/kinetic/setup.bash; cd /home/catkin_ws/src; catkin_init_workspace'
RUN /bin/bash -c '. /opt/ros/kinetic/setup.bash; cd /home/catkin_ws; catkin_make'

# Clone and build the F1/10 tutorials repository
RUN mkdir -p /home/github/f1tenth_gtc_tutorial
RUN git clone https://github.com/linklab-uva/f1tenth_gtc_tutorial /home/github/f1tenth_gtc_tutorial
RUN cp -r /home/github/f1tenth_gtc_tutorial/src/ /home/catkin_ws/
RUN /bin/bash -c '. /opt/ros/kinetic/setup.bash; cd /home/catkin_ws; catkin_make install'


EXPOSE 80
WORKDIR /home/
ENV HOME=/home/ubuntu \
    SHELL=/bin/bash
ENTRYPOINT ["/startup.sh"]
