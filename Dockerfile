FROM openjdk:8-jre-slim

ENV GITBLIT_VERSION 1.9.0
ENV GITBLIT_DOWNLOAD_SHA 349302ded75edfed98f498576861210c0fe205a8721a254be65cdc3d8cdd76f1

LABEL maintainer="James Moger <james.moger@gitblit.com>, Florian Zschocke <f.zschocke+gitblit@gmail.com>" \
      author="Bala Raman <srbala [at] gmail.com>" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.version="${GITBLIT_VERSION}"


ENV GITBLIT_DOWNLOAD_URL https://github.com/gitblit/gitblit/releases/download/v${GITBLIT_VERSION}/gitblit-${GITBLIT_VERSION}.tar.gz

# Download and  Install Gitblit & Move the data files to a separate directory
RUN set -eux ; \
    apt-get update && apt-get install -y --no-install-recommends \
        wget \
        ; \
    rm -rf /var/lib/apt/lists/* ; \
    wget --progress=bar:force:noscroll -O gitblit.tar.gz ${GITBLIT_DOWNLOAD_URL} ; \
    echo "${GITBLIT_DOWNLOAD_SHA} *gitblit.tar.gz" | sha256sum -c - ; \
    mkdir -p /opt/gitblit ; \
    tar xzf gitblit.tar.gz -C /opt/gitblit --strip-components 1 ; \
    rm -f gitblit.tar.gz ; \
    mv /opt/gitblit/data /opt/gitblit-data ; \
    ln -s /opt/gitblit-data /opt/gitblit/data ; \
    echo "server.httpPort=8080" >> /opt/gitblit-data/gitblit.properties ; \
    echo "server.httpsPort=8443" >> /opt/gitblit-data/gitblit.properties ; \
    echo "server.redirectToHttpsPort=true" >> /opt/gitblit-data/gitblit.properties ; \
    echo "web.enableRpcManagement=true" >> /opt/gitblit-data/gitblit.properties ; \
    echo "web.enableRpcAdministration=true" >> /opt/gitblit-data/gitblit.properties

# Setup the Docker container environment
WORKDIR /opt/gitblit

EXPOSE 8080 8443 9418 29418

# run application
CMD ["java", "-server", "-Xmx1024M", "-Djava.awt.headless=true", "-cp", "gitblit.jar:ext/*", "com.gitblit.GitBlitServer", "--baseFolder", "/opt/gitblit-data"]
