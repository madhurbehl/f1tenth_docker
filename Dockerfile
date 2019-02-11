# Kudos to DOROWU for his amazing VNC 16.04 KDE image
FROM dorowu/ubuntu-desktop-lxde-vnc
LABEL maintainer "bpinaya@wpi.edu"

# Adding keys for ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116

# Installing ROS
RUN apt-get update && apt-get install -y ros-kinetic-desktop-full \
		wget git nano
RUN rosdep init && rosdep update

# Update Gazebo 7
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
RUN apt-get update && apt-get install -y gazebo7 libignition-math2-dev


RUN /bin/bash -c "echo 'export HOME=/home/ubuntu' >> /root/.bashrc && source /root/.bashrc"

RUN apt install python-rosinstall python-rosinstall-generator python-wstool build-essential
RUN apt-get -y install ros-kinetic-ros-control
RUN apt-get -y install ros-kinetic-gazebo-ros-control
RUN apt-get -y install ros-kinetic-ros-controllers
RUN apt-get -y install ros-kinetic-navigation qt4-default
RUN apt-get -y install ros-kinetic-ackermann-msgs
RUN apt-get -y install ros-kinetic-serial
RUN apt-get -y install ros-kinetic-teb-local-planner*

# Creating ROS_WS
RUN mkdir -p catkin_ws/src/
RUN cd catkin_ws/src/
RUN catkin_init_workspace
RUN cd ~/catkin_ws
RUN catkin_make
RUN echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc

# Set up the workspace
# RUN /bin/bash -c "source /opt/ros/kinetic/setup.bash && \
#                  cd ~/ros_ws/ && \
#                  catkin_make && \
#                  echo 'export GAZEBO_MODEL_PATH=~/ros_ws/src/kinematics_project/kuka_arm/models' >> ~/.bashrc && \
#                  echo 'source ~/ros_ws/devel/setup.bash' >> ~/.bashrc"

# Installing f1tenth tutorial repo
RUN git clone https://github.com/linklab-uva/f1tenth_gtc_tutorial
RUN	ln -s ~/f1tenth_gtc_tutorial/src/ ~/catkin_ws/src/
RUN cd ~/catkin_ws
RUN catkin_make install


# Installing repo required for homework
# RUN cd ~/ros_ws/src && git clone https://github.com/udacity/test_repo_robond_robotic_arm_pick_and_place.git && \
#		mv test_repo_robond_robotic_arm_pick_and_place/kinematics_project/ . && \
#		rm -r test_repo_robond_robotic_arm_pick_and_place/

# Updating ROSDEP and installing dependencies
RUN cd ~/catkin_ws && rosdep update && rosdep install --from-paths src --ignore-src --rosdistro=kinetic -y

# Adding scripts and adding permissions
RUN cd ~/catkin_ws/src/ && \
		find . -name “*.py” -exec chmod +x {} \;

# Sourcing
RUN cd ~/catkin_ws/
RUN catkin_make"

# Dunno about this one tbh
RUN echo 'source ~/catkin_ws/devel/setup.bash' >> /root/.bashrc"
