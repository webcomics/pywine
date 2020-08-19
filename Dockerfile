FROM tobix/wine-staging
MAINTAINER Tobias Gruetzmacher "tobias-docker@23.gs"

ARG BUILD_DATE
ARG VCS_REF
LABEL \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.license="MIT" \
  org.label-schema.name="Docker Wine & Python 3" \
  org.label-schema.url="https://www.python.org/" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/webcomics/pywine"

ENV WINEDEBUG -all
ENV WINEARCH win32
ENV WINEPREFIX /opt/wineprefix

COPY wine-init.sh SHA256SUMS.txt /tmp/helper/
COPY mkuserwineprefix /opt/

# Prepare environment
RUN xvfb-run sh /tmp/helper/wine-init.sh

# Install Python
ENV PYVER 3.7.9

RUN umask 0 && cd /tmp/helper && \
  curl -LOO \
    https://www.python.org/ftp/python/${PYVER}/python-${PYVER}.exe \
    https://github.com/upx/upx/releases/download/v3.96/upx-3.96-win32.zip \
  && \
  sha256sum -c SHA256SUMS.txt && \
  xvfb-run sh -c "\
    wine python-${PYVER}.exe /quiet TargetDir=C:\\Python37-32 \
      Include_doc=0 InstallAllUsers=1 PrependPath=1; \
    wineserver -w" && \
  unzip upx*.zip && \
  mv -v upx*/upx.exe ${WINEPREFIX}/drive_c/windows/ && \
  cd .. && rm -Rf helper

# Install some python software
RUN umask 0 && xvfb-run sh -c "\
  wine pip install --no-warn-script-location pyinstaller; \
  wineserver -w"

