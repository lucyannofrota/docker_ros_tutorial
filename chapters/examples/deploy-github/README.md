# Docker Create Image for Deploy [Github Repo]

This process will be illustrated using a simple ROS2 demo package that shows a real-time floor detection algorithm in action using a ROS bag recorded in the DEEC garage.

## Creating the Image

The process of image deployment is really simple and consists of 3 simple steps:

1. Acquire the base image
    ```
    FROM osrf/ros:galactic-desktop
    ```
    Select an image that provides you with most of the base requirements to run your application.
2. Install necessary packages
    ```
    WORKDIR /workspace
    RUN apt-get update && \
        apt-get install -y unzip && \
        /bin/bash -c "git clone https://github.com/lucyannofrota/real-time-floor-demo.git ./src/floor_demo && \
                      source /opt/ros/galactic/setup.bash && \
                      colcon build"
    ```
    Create the directory `/workspace` and set the current path to it. Then clone the Github repo to the folder `./src/floor_demo`, source ROS Galactic, and finally build the package.
    
    The `unzip` pkg is necessary to unzip the dataset utilized by the demo.
3. Configure execution (`workdir`, `entrypoint`, `command`)
    ```
    RUN echo "source /opt/ros/galactic/setup.bash" >> ~/.bashrc
    CMD ["/bin/bash", "-c", ". install/setup.bash && ros2 launch floor_demo floor_demo_launch.py"]
    ```
    Configure the environment to run your application.
    In this case, the command `"/bin/bash", "-c", ". install/setup.bash && ros2 launch floor_demo floor_demo_launch.py"` was utilized to use the bash terminal to run the command `". install/setup.bash && ros2 launch floor_demo floor_demo_launch.py"`.

    Every bash terminal runs the `~/.bashrc` script when initialized; the command `echo "source /opt/ros/galactic/setup.bash" >> ~/.bashrc` adds the command `source /opt/ros/galactic/setup.bash` to `~/.bashrc`. This is done to automatically source ROS galactic when a new bash terminal is launched.

## Running the floor_demo

Launch the GUI server noVNC:

```
docker compose up -d novnc
```

The noVNC interface can be visualized at:
```
http://localhost:1348/vnc.html
```

The service `floor_demo` uses a dockerfile with the instructions mentioned above to build an image called `galactic_floor_demo`. Additionally, it uses the image `galactic_floor_demo` to create a container named `floor_demo`; this container runs the command `". install/setup.bash && ros2 launch floor_demo floor_demo_launch.py"` when started.

**floor_demo service:**
```
floor_demo:
    image: galactic_floor_demo
    container_name: floor_demo
    networks:
        - ros
    build:
        context: .
        dockerfile: ./dockerfile
    environment:
        - "DISPLAY=novnc:0.0"
```

The service can be launched with: 

```
docker compose up -d floor_demo
```


## Challenge

Make the changes necessary to overwrite the command `"/bin/bash -c . install/setup.bash && ros2 launch floor_demo floor_demo_launch.py"` with any command and prevent the container from shutting down after the command response.

# Helpful Links

https://github.com/lucyannofrota/real-time-floor-demo
