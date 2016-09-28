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
ENV WINEDLLOVERRIDES winemenubuilder.exe,mscoree,mshtml=

# Prepare environment:
# - Set Windows version to Windows 7
# - Disable menu updates
# - Disable Mono
# - Disable Gecko
RUN xvfb-run sh -c "\
  wine reg add 'HKLM\Software\Microsoft\Windows NT\CurrentVersion' /v CurrentVersion /d 6.1 /f && \
  wine reg add 'HKCU\Software\Wine\DllOverrides' /v winemenubuilder.exe /t REG_SZ /d '' /f && \
  wine reg add 'HKCU\Software\Wine\DllOverrides' /v mscoree /t REG_SZ /d '' /f && \
  wine reg add 'HKCU\Software\Wine\DllOverrides' /v mshtml /t REG_SZ /d '' /f && \
  wineserver -w"

# Install Python
ENV PYVER 3.5.2
COPY SHA256SUMS.txt /tmp
RUN cd && \
  curl -O https://www.python.org/ftp/python/${PYVER}/python-${PYVER}.exe && \
  sha256sum -c /tmp/SHA256SUMS.txt && \
  xvfb-run sh -c "\
    wine python-${PYVER}.exe /quiet TargetDir=C:\\Python35-32 Include_doc=0 InstallAllUsers=1 && \
    wineserver -w" && \
  rm python-${PYVER}.exe

# Install some python software
COPY *.whl /tmp
RUN xvfb-run sh -c "\
  wine py -m pip install -v --upgrade pip setuptools && \
  wine py -m pip install -v pbr pyinstaller && \
  wine py -m pip install -v /tmp/*.whl && \
  wineserver -w"

