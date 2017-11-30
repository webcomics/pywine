FROM tobix/wine-staging
MAINTAINER Tobias Gruetzmacher "tobias-docker@23.gs"

ARG BUILD_DATE
ARG VCS_REF
LABEL \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.license="MIT" \
  org.label-schema.name="Docker Wine & Python 3" \
  org.label-schema.url="ttps://www.python.org/" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/webcomics/pywine"

ENV WINEDEBUG -all
ENV WINEARCH win32

COPY wine-init.sh SHA256SUMS.txt /tmp/

# Prepare environment
RUN xvfb-run sh /tmp/wine-init.sh

# Install Python
ENV PYVER 3.6.3

RUN cd && \
  curl -O https://www.python.org/ftp/python/${PYVER}/python-${PYVER}.exe && \
  sha256sum -c /tmp/SHA256SUMS.txt && \
  xvfb-run sh -c "\
    wine python-${PYVER}.exe /quiet TargetDir=C:\\Python36-32 Include_doc=0 InstallAllUsers=1 && \
    wineserver -w" && \
  rm python-${PYVER}.exe

# Install some python software
RUN xvfb-run sh -c "\
  wine py -m pip install -v --upgrade pip setuptools && \
  wine py -m pip install -v pbr pyinstaller && \
  wineserver -w"

