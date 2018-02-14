FROM shadowrobot/build-tools:xenial-kinetic-ide

MAINTAINER "UCU APPS"

LABEL Description="This ROS Kinetic image containes all dependencies for Robert development" Vendor="UCU APPS" Version="1.0"

ENV remote_shell_script="https://raw.githubusercontent.com/shadow-robot/sr-build-tools/$toolset_branch/ansible/deploy.sh"

RUN echo "Upgrading Gazebo 7 to latest release" && \
    apt-get update && \
    echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list && \
    wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add - && \
    apt-get update && \
    apt-get remove -y gazebo7 && \
    apt-get install -y gazebo7 && \

    echo "Loading gazebo models" && \
    /home/$MY_USERNAME/sr-build-tools/docker/utils/load_gazebo_models.sh && \
    mv /root/.gazebo /home/$MY_USERNAME && \
    chown -R $MY_USERNAME:$MY_USERNAME /home/$MY_USERNAME/.gazebo && \

    echo "Removing workspace folder" && \
    rm -rf /home/$MY_USERNAME/workspace && \

    echo "Running one-liner" && \
    wget -O /tmp/oneliner "$( echo "$remote_shell_script" | sed 's/#/%23/g' )" && \
    chmod 755 /tmp/oneliner && \
    gosu $MY_USERNAME /tmp/oneliner -o ucuapps -r robert -b kinetic-devel -v kinetic && \

    echo "Sourcing workspace in .bashrc" && \
    echo 'source /home/$MY_USERNAME/workspace/robert/base/devel/setup.bash' >> /home/$MY_USERNAME/.bashrc && \

    echo "Removing cache" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /home/$MY_USERNAME/.ansible /home/$MY_USERNAME/.gitconfig

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/usr/bin/terminator"]