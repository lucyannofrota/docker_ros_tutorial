ARG BUILD_BASE_IMAGE=bridge-ros1-config

FROM ${BUILD_BASE_IMAGE} as ros2

ARG ROS2_DISTRO=foxy
ARG ROS2_WORKSPACE=/foxy
ARG ROS2_INSTALL_PATH=/opt/ros/foxy
ARG ROS_DOMAIN_ID=4

ENV ROS2_DISTRO=${ROS2_DISTRO}
ENV ROS2_WORKSPACE=${ROS2_WORKSPACE}
ENV ROS2_INSTALL_PATH=${ROS2_INSTALL_PATH}
ENV ROS_DOMAIN_ID=${ROS_DOMAIN_ID}

# Set Locale
RUN locale && \
    apt update -y && apt install -y locales && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    locale && \
# Setup Sources
    #Enable Ubuntu Universe Repository
    apt install -y software-properties-common && \
    add-apt-repository universe && \
    # Adding ROS2 GPC Key
    apt update -y && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    # Adding the repository to source list
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    # Install ROS2 PKGS
    apt update -y && \
    apt upgrade -y && \
    apt install -y python3-colcon-common-extensions ros-${ROS2_DISTRO}-ros-base ros-${ROS2_DISTRO}-turtlesim ros-${ROS2_DISTRO}-rmw-cyclonedds-cpp ros-${ROS2_DISTRO}-ros1-bridge

ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

FROM ros2 as ros2-config

WORKDIR ${ROS2_WORKSPACE}

RUN apt upgrade -y && \
    mkdir ${ROS2_WORKSPACE}/src && \
    rosdep update && \
    /bin/bash -c "source ${ROS2_INSTALL_PATH}/setup.bash && colcon build" && \
    echo "alias ${ROS2_DISTRO}ws='source ${ROS2_INSTALL_PATH}/setup.bash'" >> ~/.bashrc && \
    echo "alias ros2ws='source ${ROS2_WORKSPACE}/install/setup.bash'" >> ~/.bashrc

# apt install ros-foxy-demo-nodes-cpp

ENV DEBIAN_FRONTEND=dialog

WORKDIR /

CMD ["tail", "-f", "/dev/null"]
