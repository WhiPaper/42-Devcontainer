#################
# 42 Devcontainer
#

# Debian Base Image
FROM debian:buster

# Suppress an apt-key warning about standard out not being a terminal. Use in this script is safe.
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ENV DEBIAN_FRONTEND=noninteractive

# Standard Linux Packages
RUN apt-get update --no-install-recommends -y
RUN apt-get install --no-install-recommends \
    # Standard Build Environment
    'man-db' \
    'less' \
    'build-essential' \
    'libtool-bin' \
    'valgrind' \
    'gdb' \
    'automake' \
    'make' \
    'ca-certificates' \
    'g++' \
    'libtool' \
    'pkg-config' \
    'manpages-dev' \
    'zip' \
    'unzip' \
    'python3' \
    'python3-pip' \
    'git' \
    'openssh-server' \
    'dialog' \
    'llvm' \
    'clang' \
    'curl' \
    'wget' \
    'zsh' \
    'nano' \
    'vim' \
    'moreutils' \
    # Push Swap Projects
    'python3-tk' \
    'ruby' \
    'bc' \
    'htop' \
    # Minishell Projects
    'libreadline-dev' \
    # Minilibx Projects
    'libbsd-dev' \
    'libxext-dev' \
    'libx11-dev' \
    # IRC Project Test Example
    'irssi' \
    'netcat' \
    'tcpdump' \
    'net-tools' \
    #"wireshark" \
    -y \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# 42 Norminette
RUN python3 -m pip install --upgrade pip setuptools && python3 -m pip install norminette

# OhMyZsh Install, set prompt to DEVCONTAINER
RUN sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"  \
    && echo 'PROMPT=%B%F{blue}[DEVCONTAINER]%f%b$PROMPT' >> /root/.zshrc

# Add Return Code in prompt for bash
ENV PROMPT_COMMAND='RET=$?; echo -n "[$RET] "'

# Add clangd
RUN wget https://github.com/clangd/clangd/releases/download/15.0.6/clangd-linux-15.0.6.zip && unzip clangd-linux-15.0.6.zip && cp ./clangd_15.0.6/bin/clangd /usr/local/bin && cp -rd ./clangd_15.0.6/lib/clang/ /usr/local/lib/ && rm -rf ./clangd_15.0.6 && rm clangd-linux-15.0.6.zip
COPY ./settings.json /root/.vscode-server/data/Machine/settings.json

# minilibx-linux source and install
RUN git clone https://github.com/42Paris/minilibx-linux.git /usr/local/minilibx-linux
RUN cd /usr/local/minilibx-linux/ && ./configure \
    && cp /usr/local/minilibx-linux/*.a /usr/local/lib \
    && cp /usr/local/minilibx-linux/*.h /usr/local/include \
    && cp -R /usr/local/minilibx-linux/man/* /usr/local/man/ \
    && /sbin/ldconfig

# SSH Keys
RUN mkdir -p /home/vscode/src && mkdir -p /root/.ssh
COPY ./.ssh/ /root/.ssh/

# Remove c++ Symlink and replace with link to g++
RUN rm /usr/bin/c++ && ln -s /usr/bin/g++ /usr/bin/c++

# set working directory to /home/vscode/src
WORKDIR /home/vscode
COPY ./src/ ./src/
WORKDIR /home/vscode/src

# Export Display for XServer Forwarding
RUN echo "export DISPLAY=host.docker.internal:0.0" >> /root/.bashrc && echo "export DISPLAY=host.docker.internal:0.0" >> /root/.zshrc

# Reset dialog frontend
ENV DEBIAN_FRONTEND=dialog


LABEL maintainer="Dale Furneaux <opinfosec>" \
    version="3.0.2"
