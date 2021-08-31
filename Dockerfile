FROM tobix/wine:stable
MAINTAINER Tobias Gruetzmacher "tobias-docker@23.gs"

ENV WINEDEBUG -all
ENV WINEPREFIX /opt/wineprefix

COPY wine-init.sh SHA256SUMS.txt /tmp/helper/
COPY mkuserwineprefix /opt/

# Prepare environment
RUN xvfb-run sh /tmp/helper/wine-init.sh

# renovate: datasource=github-tags depName=python/cpython
ARG PYTHON_VERSION=v3.9.7
# renovate: datasource=github-releases depName=upx/upx
ARG UPX_VERSION=3.96

RUN umask 0 && cd /tmp/helper && \
  curl -LOO \
    https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe \
    https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-win64.zip \
  && \
  sha256sum -c SHA256SUMS.txt && \
  xvfb-run sh -c "\
    wine python-${PYTHON_VERSION}-amd64.exe /quiet TargetDir=C:\\Python39 \
      Include_doc=0 InstallAllUsers=1 PrependPath=1; \
    wineserver -w" && \
  unzip upx*.zip && \
  mv -v upx*/upx.exe ${WINEPREFIX}/drive_c/windows/ && \
  cd .. && rm -Rf helper

# Install some python software
RUN umask 0 && xvfb-run sh -c "\
  wine pip install --no-warn-script-location pyinstaller; \
  wineserver -w"

