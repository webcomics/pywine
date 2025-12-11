FROM tobix/wine:stable
LABEL org.opencontainers.image.authors="Tobias Gruetzmacher <tobias-docker@23.gs>"

ENV WINEDEBUG=-all
ENV WINEPREFIX=/opt/wineprefix

COPY wine-init.sh SHA256SUMS.txt /tmp/helper/
COPY mkuserwineprefix entrypoint.sh /opt/

# Prepare environment
RUN xvfb-run sh /tmp/helper/wine-init.sh

# renovate: datasource=github-tags depName=python/cpython versioning=pep440
ARG PYTHON_VERSION=3.14.2
# renovate: datasource=github-releases depName=upx/upx versioning=loose
ARG UPX_VERSION=5.0.2

RUN --mount=from=ghcr.io/sigstore/cosign/cosign:v3.0.3@sha256:774391ac9f0c137ee419ce56522df5fd3b1f52be90c5b77e97f7c053bdd67a67,source=/ko-app/cosign,target=/usr/bin/cosign \
  umask 0 && cd /tmp/helper && \
  curl --fail-with-body -LOO \
    "https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe{,.sigstore}" \
    https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-win64.zip \
  && \
  cosign verify-blob --certificate-oidc-issuer https://github.com/login/oauth --certificate-identity-regexp='@python.org$' \
    --bundle python-${PYTHON_VERSION}-amd64.exe.sigstore python-${PYTHON_VERSION}-amd64.exe && \
  sha256sum -c SHA256SUMS.txt && \
  xvfb-run sh -c "\
    wine python-${PYTHON_VERSION}-amd64.exe /quiet TargetDir=C:\\Python \
      Include_doc=0 InstallAllUsers=1 PrependPath=1; \
    wineserver -w" && \
  unzip upx*.zip && \
  mv -v upx*/upx.exe ${WINEPREFIX}/drive_c/windows/ && \
  cd .. && rm -Rf helper

# Install some python software
RUN umask 0 && xvfb-run sh -c "\
  wine pip install --no-warn-script-location pyinstaller; \
  wineserver -w"

ENTRYPOINT ["/opt/entrypoint.sh"]
