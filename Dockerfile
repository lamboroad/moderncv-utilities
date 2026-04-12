# FROM debian:stable-slim

# TEXLIVE
# RUN apt update
# RUN apt install -y latexmk texlive-latex-extra texlive-fonts-extra git

# RUN git clone https://github.com/moderncv/moderncv

# WORKDIR /moderncv
# RUN git checkout `git describe --tags --abbrev=0`
# RUN latexmk -pdf ./template.tex  # Build the template

# MIKTEX
FROM rockylinux:9

ENV WORKDIR_PATH=/miktex/work
ENV TEXMF_ROOT_PATH=/usr/local/share/miktex-texmf/tex/latex

# Script to generate CV
COPY generate_cvs.sh ${WORKDIR_PATH}/

# RUN dnf update -y && dnf install -y curl perl ghostscript fontconfig ca-certificates && \
RUN rpm --import https://miktex.org/download/key
RUN dnf update -y && dnf install -y git perl ghostscript fontconfig ca-certificates
# rpm --import "https://ubuntu.com"

RUN curl -L -o /etc/yum.repos.d/miktex.repo https://miktex.org/download/rockylinux/9/miktex.repo && \
  dnf update --assumeyes && \
  dnf install -y miktex git --nobest && \
  # Setup MiKTeX and install fontawesome5
  miktexsetup --shared=yes finish

RUN initexmf --admin --set-config-value [MPM]AutoInstall=1 && \
  mpm --admin --update-db && \
  mpm --admin --install fontawesome5 && \
  mpm --admin --install simpleicons && \
  initexmf --admin --update-fndb && \
  miktex packages upgrade complete

# RUN initexmf --admin --set-config-value=[MPM]AutoInstall=1 && \
#   mpm --admin --update-db && \
#   mpm --admin --install fontawesome5 && \
#   mpm --admin --install simpleicons && \
#   initexmf --admin --update-fndb

# ALTACV latex class
RUN git clone https://github.com/liantze/AltaCV.git ${TEXMF_ROOT_PATH}/altacv

# MODERNCV latex class
RUN curl -L -o moderncv_v2.4.1.tar.gz https://github.com/moderncv/moderncv/archive/refs/tags/v2.4.1.tar.gz
RUN mkdir -p ${TEXMF_ROOT_PATH}/moderncv && tar -xvzf moderncv_v2.4.1.tar.gz -C ${TEXMF_ROOT_PATH}/moderncv --strip-components=1

WORKDIR ${WORKDIR_PATH}

# CMD ["bash"]
# ENTRYPOINT ${WORKDIR_PATH}/generate_cvs.sh
# CMD ["./generate_cvs.sh"]
ENTRYPOINT ["/miktex/work/generate_cvs.sh"]
