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

WORKDIR /home
RUN rpm --import https://miktex.org/download/key
RUN curl -L -o /etc/yum.repos.d/miktex.repo https://miktex.org/download/rockylinux/9/miktex.repo
RUN dnf update --assumeyes
RUN dnf install -y miktex git --nobest
# RUN dnf install diffutils
RUN miktexsetup --shared=yes finish
RUN initexmf --admin --set-config-value [MPM]AutoInstall=1
RUN miktex packages upgrade complete

RUN curl -L -o moderncv_v2.4.1.tar.gz https://github.com/moderncv/moderncv/archive/refs/tags/v2.4.1.tar.gz
RUN mkdir moderncv_v2.4.1 | tar -xvzf moderncv_v2.4.1.tar.gz -C moderncv_v2.4.1 --strip-components=1

# COPY moderncv_update/moderncvheadvii.sty /home/moderncv_v2.4.1/
WORKDIR /home/moderncv_v2.4.1
# RUN miktex packages install moderncv  # already intalled
