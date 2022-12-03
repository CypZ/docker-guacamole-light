FROM arm64v8/tomcat:9-jre11

ENV ARCH=aarch64  \
    GUAC_VER=1.4.0 \
    GUACAMOLE_HOME=/app/guacamole

# Install base dependencies
RUN apt-get update \ 
 && apt-get install -y --allow-unauthenticated \
    # libcairo2-dev libjpeg62-turbo-dev libpng-dev \
    libcairo2-dev libjpeg-turbo8-dev libpng-dev \
    libossp-uuid-dev libavcodec-dev libavutil-dev \
    libswscale-dev freerdp2-dev libfreerdp-client2-2 libpango1.0-dev \
    libssh2-1-dev libtelnet-dev libvncserver-dev \
    libpulse-dev libssl-dev libvorbis-dev libwebp-dev libwebsockets-dev \
    ghostscript build-essential


# Apply the s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.2.1/s6-overlay-${ARCH}.tar.xz /tmp
RUN tar -xf /tmp/s6-overlay-${ARCH}.tar.xz -C / \
 && rm -rf /tmp/s6-overlay-${ARCH}.tar.xz

RUN mkdir -p ${GUACAMOLE_HOME} \
    ${GUACAMOLE_HOME}/lib \
    ${GUACAMOLE_HOME}/extensions


WORKDIR ${GUACAMOLE_HOME}

# Link FreeRDP to where guac expects it to be
RUN [ "$ARCH" = "arm64" ] && ln -s /usr/local/lib/freerdp /usr/lib/arm-linux-gnueabihf/freerdp || exit 0

# Patching SSL (https://github.com/MysticRyuujin/guac-install/issues/224)
RUN curl -SLOk https://www.openssl.org/source/openssl-1.1.1l.tar.gz \
  && tar -xzf openssl-1.1.1l.tar.gz \
  && cd openssl-1.1.1l \
  && ./config \
  && make -j8 \
  && make -j8 install_sw \
  && cp /usr/local/bin/openssl /usr/bin \
  && ldconfig

# Install guacamole-server
RUN curl -SLOk "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VER}/source/guacamole-server-${GUAC_VER}.tar.gz" \
  && tar -xzf guacamole-server-${GUAC_VER}.tar.gz \
  && cd guacamole-server-${GUAC_VER} \
  && ./configure --enable-allow-freerdp-snapshots \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && make install \
  && cd .. \
  && rm -rf guacamole-server-${GUAC_VER}.tar.gz guacamole-server-${GUAC_VER} \
  && ldconfig

# Install guacamole-client
RUN set -x \
 && rm -rf ${CATALINA_HOME}/webapps/ROOT \
 && curl -SLko ${CATALINA_HOME}/webapps/ROOT.war "http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUAC_VER}/binary/guacamole-${GUAC_VER}.war"

# Add optional extensions
RUN set -xe \
 && mkdir ${GUACAMOLE_HOME}/extensions-available
#  && mkdir ${GUACAMOLE_HOME}/extensions-available \
#  && for i in auth-ldap auth-duo auth-header auth-cas auth-openid auth-quickconnect auth-totp; do \
#     echo "https://dlcdn.apache.org/guacamole/${GUAC_VER}/binary/guacamole-${i}-${GUAC_VER}.tar.gz" \
#     && curl -SLOk "https://dlcdn.apache.org/guacamole/${GUAC_VER}/binary/guacamole-${i}-${GUAC_VER}.tar.gz" \
#     && tar -xzf guacamole-${i}-${GUAC_VER}.tar.gz \
#     && cp guacamole-${i}-${GUAC_VER}/guacamole-${i}-${GUAC_VER}.jar ${GUACAMOLE_HOME}/extensions-available/ \
#     && rm -rf guacamole-${i}-${GUAC_VER} guacamole-${i}-${GUAC_VER}.tar.gz \
#   ;done

ENV GUACAMOLE_HOME=/config/guacamole

ADD root/app/guacamole/guacamole-auth-noauth-${GUAC_VER}.jar ${GUACAMOLE_HOME}/extensions/
ADD root/app/guacamole/guacamole-auth-noauth-${GUAC_VER}.jar ${GUACAMOLE_HOME}/extensions-available/
ADD root/app/guacamole/guacamole.properties ${GUACAMOLE_HOME}
ADD root/app/guacamole/noauth-config.xml.template ${GUACAMOLE_HOME}

WORKDIR /config

COPY root /

# ENTRYPOINT [ "/init" ]
