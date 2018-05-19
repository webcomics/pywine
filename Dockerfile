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
ENV WINEPREFIX /opt/wineprefix

COPY wine-init.sh SHA256SUMS.txt /tmp/

# Prepare environment
RUN xvfb-run sh /tmp/wine-init.sh

# Install Python
ENV PYVER 3.6.4

RUN umask 0 && cd && \
  curl -LOO \
    https://www.python.org/ftp/python/${PYVER}/python-${PYVER}.exe \
    https://github.com/upx/upx/releases/download/v3.94/upx394w.zip \
  && \
  sha256sum -c /tmp/SHA256SUMS.txt && \
  xvfb-run sh -c "\
    wine python-${PYVER}.exe /quiet TargetDir=C:\\Python36-32 \
      Include_doc=0 InstallAllUsers=1 PrependPath=1 && \
    wineserver -w" && \
  unzip upx*.zip && \
  mv -v upx*/upx.exe ${WINEPREFIX}/drive_c/windows/ && \
  rm -Rf upx* python-${PYVER}.exe

# Install some python software
RUN umask 0 && xvfb-run sh -c "\
  wine py -m pip install --upgrade pip setuptools && \
  wine pip install pbr pyinstaller && \
  wineserver -w"

