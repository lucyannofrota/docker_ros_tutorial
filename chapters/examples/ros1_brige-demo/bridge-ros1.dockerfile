ARG BUILD_BASE_IMAGE=ubuntu:20.04

FROM ${BUILD_BASE_IMAGE} as ros1

# Defining variables

ARG ROS1_DISTRO=noetic
ARG ROS1_WORKSPACE=/noetic
ARG ROS1_INSTALL_PATH=/opt/ros/noetic
ARG ROS_MASTER_URI=http://localhost:11311

ENV ROS1_DISTRO=${ROS1_DISTRO}
ENV ROS1_WORKSPACE=${ROS1_WORKSPACE}
ENV ROS1_INSTALL_PATH=${ROS1_INSTALL_PATH}
ENV ROS_MASTER_URI=${ROS_MASTER_URI}

CMD ["tail", "-f", "/dev/null"]

# Installing ROS1 Distro + turtlesim
# http://wiki.ros.org/noetic/Installation/Ubuntu

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update -y && \
    apt upgrade -y && \
    apt install -y lsb-core curl && \
    sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    apt update -y && \
    apt install -y ros-${ROS1_DISTRO}-ros-base python3-rosdep ros-${ROS1_DISTRO}-turtlesim

FROM ros1 as ros1-config

WORKDIR ${ROS1_WORKSPACE}

RUN mkdir ${ROS1_WORKSPACE}/src && \
    rosdep init && \
    rosdep update && \
    /bin/bash -c "source ${ROS1_INSTALL_PATH}/setup.bash && catkin_make" && \
    echo "alias ${ROS1_DISTRO}ws='source ${ROS1_INSTALL_PATH}/setup.bash'" >> ~/.bashrc && \
    echo "alias ros1ws='source ${ROS1_WORKSPACE}/devel/setup.bash'" >> ~/.bashrc

