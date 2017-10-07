FROM gcc:latest

ENV HOME /home/aruns

COPY start.sh /start.sh
RUN chmod 755 /start.sh
COPY end.sh /end.sh
RUN chmod 755 /end.sh
COPY getpwd.sh /getpwd.sh
RUN chmod 755 /getpwd.sh

RUN apt-get update && \
    apt-get -y install sudo openssl vim vim-gnome man
RUN useradd -ms /bin/sh aruns -p $(openssl passwd -crypt `./getpwd.sh`) && adduser aruns sudo
COPY vimrc $HOME/.vimrc

RUN echo "aruns ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN ./getpwd.sh

USER aruns
COPY . /home/aruns/talkbot
WORKDIR /home/aruns/talkbot
RUN sudo chown -R aruns:aruns $HOME
RUN /end.sh
VOLUME ["/home/aruns/talkbot", "~/docker-containers/talkbot"]
