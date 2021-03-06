# Specify Ubuntu Saucy as base image
FROM ubuntu:xenial
LABEL maintainer="jsbjair"

# Arguments
ARG user
ARG UID=1001
ARG GID=1001
# Set Environment Variables & Language Environment
ENV LC_ALL en_US.UTF-8
ENV user ${user:-admin}
ENV HOME /home/$user

# Update Base System
RUN apt-get update && apt-get -y upgrade \
    && apt-get install -y language-pack-en software-properties-common \
    apt-transport-https \
    && locale-gen en_US.UTF-8 \
    && dpkg-reconfigure locales

#Configure ppa
RUN add-apt-repository -y ppa:jonathonf/vim \
    && add-apt-repository -y ppa:ondrej/php \
    && add-apt-repository -y ppa:zeal-developers/ppa \
    && apt-get update

# Install Basic Packages
RUN apt-get install -y wget curl git man unzip \
    tmux zsh php vim-gtk3 lynx htop openssl openssh-server mosh sudo php-pear

# Install packages needed to compile binaries
RUN apt-get install -y build-essential autotools-dev automake pkg-config

# Install peco
RUN cd /opt \
      && wget https://github.com/peco/peco/releases/download/v0.5.3/peco_linux_amd64.tar.gz \
      && tar xvf peco_linux_amd64.tar.gz \
      && ln -s /opt/peco_linux_amd64/peco /usr/local/bin

# Install jq
RUN cd /opt \
      && mkdir jq \
      && wget -O ./jq/jq http://stedolan.github.io/jq/download/linux64/jq \
      && chmod +x ./jq/jq \
      && ln -s /opt/jq/jq /usr/local/bin

# Install ctags
RUN cd /opt \
    && git clone https://github.com/universal-ctags/ctags.git \
    && cd ctags \
    && ./autogen.sh \
    && ./configure && make && make install

# Install composer.phar
RUN cd /opt \
    && curl -sS https://getcomposer.org/installer | php \
    && chmod +x composer.phar && mv composer.phar /usr/local/bin/composer

# Install pear
RUN pear channel-update doc.php.net && pear install doc.php.net/pman

RUN groupadd -g $GID -o $user
# Add user with name "${user}"
RUN useradd -d /home/$user -u $UID -g $GID -m -s /bin/zsh $user \
    && chsh -s /bin/zsh ${user}
# Allow sudo
RUN echo "$user ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user \
    && chmod 0440 /etc/sudoers.d/user

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    docker-compose --version

WORKDIR /home/$user

# Add configuration files
ADD ./config/.tmux.conf ./.tmux.conf
ADD ./config/.zshrc ./.zshrc
ADD ./config/.bash_aliases ./.bash_aliases
ADD ./bin/man.sh /opt/man.sh

# Change current user
RUN chown -R ${user}:${user} /home/$user
USER $user

# Clone oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ./.oh-my-zsh

#Configure vim
RUN git clone https://github.com/jsbjair/customvim.git ./.vim \
    && ln -s ./.vim/.vimrc ./.vimrc \
    && cd ./.vim \
    && git submodule update --init --recursive

# Put peco script
RUN mkdir -p ./.zsh \
    && git clone https://gist.github.com/ad77e50ae4646ae1f46f45a555585974.git ./.zsh/ \
    && echo "source ./.zsh/peco-select-history.zsh" >> ./.zshrc

CMD ["tmux"]
# Expose ssh port and mosh port
EXPOSE 22 6000
