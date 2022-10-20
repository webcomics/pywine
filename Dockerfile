FROM tobix/wine:stable
MAINTAINER Tobias Gruetzmacher "tobias-docker@23.gs"

ENV WINEDEBUG -all
ENV WINEPREFIX /opt/wineprefix

COPY wine-init.sh SHA256SUMS.txt keys.gpg /tmp/helper/
COPY mkuserwineprefix /opt/

# Prepare environment
RUN xvfb-run sh /tmp/helper/wine-init.sh

# renovate: datasource=github-tags depName=python/cpython versioning=pep440
ARG PYTHON_VERSION=3.10.7
# renovate: datasource=github-releases depName=upx/upx versioning=loose
ARG UPX_VERSION=3.96

# Install Python and UPX for Windows
RUN umask 0 && cd /tmp/helper && \
  curl -LOOO \
    https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe{,.asc} \
    https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-win64.zip \
  && \
  gpgv --keyring ./keys.gpg python-${PYTHON_VERSION}-amd64.exe.asc python-${PYTHON_VERSION}-amd64.exe && \
  sha256sum -c SHA256SUMS.txt && \
  xvfb-run sh -c "\
    wine python-${PYTHON_VERSION}-amd64.exe /quiet TargetDir=C:\\Python310 \
      Include_doc=0 InstallAllUsers=1 PrependPath=1; \
    wineserver -w" && \
  unzip upx*.zip && \
  mv -v upx*/upx.exe ${WINEPREFIX}/drive_c/windows/ && \
  cd .. && rm -Rf helper

# Install PyInstaller for Windows
RUN umask 0 && xvfb-run sh -c "\
  wine pip install --no-warn-script-location pyinstaller; \
  wineserver -w"

# Install Python for Linux
RUN apt update && apt install -y build-essential gdb lcov pkg-config \
      libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
      libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
      lzma lzma-dev tk-dev uuid-dev zlib1g-dev
RUN cd /usr/src && \
  curl -LOOO \
    https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz{,.asc} && \
  gpgv --keyring ./keys.gpg python-${PYTHON_VERSION}.tgz.asc python-${PYTHON_VERSION}.tgz.asc && \
  sha256sum -c SHA256SUMS.txt
RUN tar xzf Python-${PYTHON_VERSION}.tgz && cd Python-${PYTHON_VERSION}
RUN ./configure --enable-optimizations && make && make install

# Install PyInstaller for Linux
RUN pip3 install pyinstaller

# Install UPX for Linux
RUN curl -LOOO \
      https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-amd64_linux.tar.xz
RUN tar xvf upx*.tar.xz && \
    mv -v upx*/upx /opt/

# Clean up Linux builds
RUN cd / && rm -rf /usr/src/*

