# Docker Create Image for Deploy [Linux PKG]

This process will be illustrated using the ROS Foxy turtlesim tutorial (https://docs.ros.org/en/foxy/Tutorials/Beginner-CLI-Tools/Introducing-Turtlesim/Introducing-Turtlesim.html).

## Creating the Image

The process of image deployment is really simple and consists in 3 simple steps:

1. Acquire the base image
    ```
    FROM osrf/ros:foxy-desktop
    ```
    Select an image that provides you most of the base requirements to run your application.
2. Install necessary packages
    ```
    RUN apt-get update && \
        apt-get install -y ros-foxy-turtlesim
    ```
    Install the specific packages necessary to run your application.
3. Configure execution (`workdir`, `entrypoint`, `command`)
    ```
    RUN echo "source /opt/ros/foxy/setup.bash" >> ~/.bashrc
    CMD ["tail", "-f", "/dev/null"]
    ```
    Configure the environment to run your application.
    In this case, the command `tail -f /dev/null` was utilized to keep the container running indefinitely.

    Every bash terminal runs the `~/.bashrc` script when initialized; the command `echo "source /opt/ros/foxy/setup.bash" >> ~/.bashrc` adds the command `source /opt/ros/foxy/setup.bash` to `~/.bashrc`. This is done to automatically source ROS foxy when a new bash terminal is launched.

## Running the Turtlesim

Launch the GUI server noVNC:

```
docker compose up -d novnc
```
The service `turtlesim` uses a dockerfile with the instructions mentioned above to build an image called `foxy_turtlesim`. Additionally, it uses the image `foxy_turtlesim` to create a container named `turtlesim`; this container runs the command `ros2 run turtlesim turtlesim_node` when started.

**turtlesim service:**
```
turtlesim:
    image: foxy_turtlesim
    container_name: turtlesim
    networks:
        - ros
    build:
        context: .
        dockerfile: ./dockerfile
    environment:
        - "QT_X11_NO_MITSHM=1" #fix some QT bugs
        - "DISPLAY=novnc:0.0"
    command: >
        bash -c "
            ros2 run turtlesim turtlesim_node
        "
```

The service can be launched with: 

```
docker compose up -d turtlesim
```

**Run turtle_teleop_key node:**

The turtle_teleop_key node can be launched in the same container as the turtlesim_node. This can be achieved by using the command below:
```
docker exec -it turtlesim bash -c "source /opt/ros/foxy/setup.bash && ros2 run turtlesim turtle_teleop_key".
```
This command is attaching a terminal in the host computer to bash terminal inside the container and executing commands `source /opt/ros/foxy/setup.bash` and `ros2 run turtlesim turtle_teleop_key`.

# Helpful Links

https://hub.docker.com/r/osrf/ros2/tags

https://docs.ros.org/en/foxy/Tutorials/Beginner-CLI-Tools/Introducing-Turtlesim/Introducing-Turtlesim.html

https://hub.docker.com/_/ros/
