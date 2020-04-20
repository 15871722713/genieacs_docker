# GenieACS Dockerfile #
############################

FROM node:10-buster
LABEL maintainer="JinHua"

#COPY sources.list /etc/apt/sources.list
#RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 40976EAF437D05B5
#RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 3B4FE6ACC0B21F32
RUN apt-get update && apt-get install -y sudo supervisor
RUN mkdir -p /var/log/supervisor

WORKDIR /opt
COPY genieacs /opt/genieacs/
#RUN git clone https://github.com/15871722713/genieacs.git -b master
WORKDIR /opt/genieacs
RUN npm install
RUN npm run build

RUN useradd --system --no-create-home --user-group genieacs

RUN mkdir /opt/genieacs/ext
RUN chown genieacs:genieacs /opt/genieacs/ext

RUN mkdir /var/log/genieacs
RUN chown genieacs:genieacs /var/log/genieacs

WORKDIR /opt
ADD genieacs.logrotate /etc/logrotate.d/genieacs

RUN mkdir /opt/genieacs/genieacs-service
COPY service/genieacs-cwmp.service /opt/genieacs/genieacs-service/genieacs-cwmp.service
COPY service/genieacs-fs.service /opt/genieacs/genieacs-service/genieacs-fs.service
COPY service/genieacs-nbi.service /opt/genieacs/genieacs-service/genieacs-nbi.service
COPY service/genieacs-ui.service /opt/genieacs/genieacs-service/genieacs-ui.service
COPY service/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY service/run_with_env.sh /usr/bin/run_with_env.sh
RUN chmod +x /usr/bin/run_with_env.sh

WORKDIR /var/log/genieacs

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]