FROM ros:melodic-ros-core-bionic

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/ros_entrypoint.sh"]

RUN apt-get update \
	&& apt-get install -q -y \
	--no-install-recommends \
		build-essential \
		cmake \
		python-catkin-tools \
		python-rosdep \
		python-wstool \
	&& apt-get clean -q -y \
	&& apt-get autoremove -q -y \
	&& rm -rf /var/lib/apt/lists/*

RUN rosdep init

RUN rosdep update

RUN mkdir -p /catkin_ws

WORKDIR /catkin_ws

COPY ./src src


RUN true \
	&& echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections \
	&& sudo apt-get update \
	&& rosdep install \
		--from-paths src \
		--ignore-src \
		--rosdistro=${ROS_DISTRO} \
		-y -r \
	&& sudo apt-get clean -q -y \
	&& sudo apt-get autoremove -q -y \
	&& sudo rm -rf /var/lib/apt/lists/*

RUN true \
	&& . /opt/ros/${ROS_DISTRO}/setup.sh \
	&& catkin build \
	&& true