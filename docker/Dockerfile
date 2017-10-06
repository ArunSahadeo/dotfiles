FROM gcc:latest

ENV HOME /home/aruns

COPY start.sh /start.sh

RUN chmod 755 /start.sh

ENTRYPOINT "/start.sh"

RUN apt-get update && \
    apt-get -y install sudo openssl vim
RUN useradd -ms /bin/bash aruns -p $(openssl passwd -crypt USER_1_PASSWORD) && adduser aruns sudo
RUN echo "aruns ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER aruns
COPY . /home/aruns/talkbot
WORKDIR /home/aruns/talkbot
RUN sudo chown -R aruns:aruns $HOME
VOLUME ["/home/aruns/talkbot", "~/docker-containers/talkbot"]
