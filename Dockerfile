ARG OS_VERSION=bionic-20220128
FROM ubuntu:${OS_VERSION}

RUN apt-get update \
    && apt-get install --assume-yes --no-install-recommends \
        # Graphical environment and multi-process management
        fluxbox \
        supervisor \
        x11vnc \
        xbase-clients \
        xterm \
        xvfb \
        \
        # Build time dependencies
        curl \
        ca-certificates \
        \
        # Dependencies for simulator robot power on script
        python3 \
        \
        # Simulator dependencies
        openjdk-8-jre \
        psmisc \
    # Cleanup to keep image layer small
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/apt/lists.d/* \
    && apt-get autoremove \
    && apt-get clean \
    && apt-get autoclean

############### noVNC remote desktop in a browser

# Setup noVNC
ARG NOVNC_VERSION=1.3.0
RUN curl --location \
        --output novnc.tar.gz \
        https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.tar.gz \
    && mkdir --parents /novnc \
    && tar xvzf novnc.tar.gz \
        --strip-components=1 \
        --directory /novnc \
    && rm novnc.tar.gz

# Setup websockify
ARG WEBSOCKIFY_VERSION=0.10.0
RUN curl --location \
        --output websockify.tar.gz \
        https://github.com/novnc/websockify/archive/refs/tags/v${WEBSOCKIFY_VERSION}.tar.gz \
    && mkdir --parents /novnc/utils/websockify \
    && tar xvzf websockify.tar.gz \
        --strip-components=1 \
        --directory /novnc/utils/websockify \
    && rm websockify.tar.gz

RUN ln -s /novnc/vnc.html /novnc/index.html

############### Multi-process startup configuration
COPY ./system/services/ /services/
ADD ./system/supervisord.conf /etc/supervisord.conf

############### Graphical environment configuration
ENV DISPLAY :0
ENV RESOLUTION=1280x800
ENV NOVNC_PORT=8080

# Fluxbox
COPY ./system/.fluxbox/ /root/.fluxbox/

############### Simulator
# Overwrite on container startup to change model.
# Supported models: UR3, UR5, UR10 (will be used by default), UR16.
ENV ROBOT_MODEL=UR10

WORKDIR /
ARG DOWNLOAD_URL=https://s3-eu-west-1.amazonaws.com/ur-support-site/71480/URSim_Linux-5.8.2.10297.tar.gz
RUN echo "**** Downloading URSim ****" && \
    curl ${DOWNLOAD_URL} -o URSim-Linux.tar.gz && \
    tar xvzf URSim-Linux.tar.gz && \
    # Remove the tarball
    rm URSim-Linux.tar.gz && \
    # Rename the URSim folder to just simulator
    mv /ursim* /simulator

WORKDIR /simulator
RUN echo "**** Installing URSim ****" && \
    # Make URControl and all sh files executable
    chmod +x ./*.sh ./URControl && \
    apt-get update && \
    # Stop install of unnecessary packages and install required ones quietly
    sed -i 's|apt-get -y install|apt-get -qy install --no-install-recommends|g' ./install.sh && \
    # Skip xterm command. We dont have a desktop
    sed -i 's|tty -s|(exit 0)|g' install.sh && \
    # Skip Check of Java Version as we have the correct installed and the command will fail
    sed -i 's|needToInstallJava$|(exit 0)|g' install.sh && \
    # Skip install of desktop shortcuts - we dont have a desktop
    sed -i '/for TYPE in UR3 UR5 UR10/,$ d' ./install.sh  && \
    # Remove commands that are not relevant on docker as we are root user
    sed -i 's|pkexec ||g' ./install.sh && \
    sed -i 's|sudo ||g' ./install.sh && \
    sed -i 's|sudo ||g' ./ursim-certificate-check.sh && \
    #
    ./install.sh \
    \
    # Cleanup to keep image layer small
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/apt/lists.d/* \
    && apt-get autoremove \
    && apt-get clean \
    && apt-get autoclean \
    && echo "**** Installed URSim ****"

# Pre-configure simulator for remote mode:
# * Enable remote-control via...
#   `.polyscope/remotecontrol.properties`
# * Make sure that confirmation safety dialog does not pop up via...
#   `programs.${ROBOT_MODEL}/default.installation`
COPY ./simulator/ /simulator/

############### Expose ports

#### Web UI (noVNC)
EXPOSE 8080

#### Universal Robots simulator
# Modbus Port
EXPOSE 502
# Interface Ports
EXPOSE 29999
EXPOSE 30001-30004

ENTRYPOINT ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]
