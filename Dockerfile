FROM openjdk:8u171-jre-stretch As sonarscanner

LABEL maintainer="Burak Ince <burak.ince@linux.org.tr>"
LABEL updater="Elio Severo Junior <elioseverojunior@gmail.com>"

ENV SONAR_SCANNER_MSBUILD_VERSION=4.3.1.1372 \
    SONAR_SCANNER_VERSION=3.2.0.1227 \
    DOTNET_SDK_VERSION=2.2 \
    SONAR_SCANNER_MSBUILD_HOME=/opt/sonar-scanner-msbuild \
    DOTNET_HOME=/root/.dotnet \
    DOTNET_PROJECT_DIR=/project \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true \
    DOTNET_CLI_TELEMETRY_OPTOUT=true \
    SONAR_DOTNET_FRAMEWORK="" \
    DOTNET_SOLUTION_DIR="" \
    SONAR_BRANCH_NAME="" \
    SONAR_TARGET_BRANCH_NAME="" \
    DOTNET_TEST_DIR=""

RUN set -x \
  && apt-get update \
  && apt-get install apt-utils apt-transport-https dirmngr gnupg ca-certificates -y \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
  && echo "deb http://download.mono-project.com/repo/debian stable-stretch main" | tee /etc/apt/sources.list.d/mono-official-stable.list \
  && apt-get update \
  && apt-get install \
    curl \
    libunwind8 \
    gettext \
    apt-transport-https \
    mono-devel \
    ca-certificates-mono \
    referenceassemblies-pcl \
    mono-xsp4 \
    wget \
    unzip \
    jq \
    tree \
    -y \
  && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
  && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
  && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/debian/9/prod stretch main" > /etc/apt/sources.list.d/microsoft-prod.list' \
  && apt-get update \
  && apt-get install dotnet-sdk-$DOTNET_SDK_VERSION -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN wget -q https://github.com/SonarSource/sonar-scanner-msbuild/releases/download/$SONAR_SCANNER_MSBUILD_VERSION/sonar-scanner-msbuild-$SONAR_SCANNER_MSBUILD_VERSION-net46.zip -O /opt/sonar-scanner-msbuild.zip \
  && mkdir -p $SONAR_SCANNER_MSBUILD_HOME \
  && mkdir -p $DOTNET_PROJECT_DIR \
  && unzip /opt/sonar-scanner-msbuild.zip -d $SONAR_SCANNER_MSBUILD_HOME \
  && rm /opt/sonar-scanner-msbuild.zip \
  && chmod 775 $SONAR_SCANNER_MSBUILD_HOME/*.exe \
  && chmod 775 $SONAR_SCANNER_MSBUILD_HOME/**/bin/* \
  && chmod 775 $SONAR_SCANNER_MSBUILD_HOME/**/lib/*.jar

ENV PATH="$SONAR_SCANNER_MSBUILD_HOME:$SONAR_SCANNER_MSBUILD_HOME/sonar-scanner-$SONAR_SCANNER_VERSION/bin:${DOTNET_HOME}:${DOTNET_HOME}/tools:${PATH}"

RUN dotnet tool install --global dotnet-sonarscanner
RUN dotnet tool install --global GitVersion.Tool --version 5.0.1

RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY run.sh $SONAR_SCANNER_MSBUILD_HOME/sonar-scanner-$SONAR_SCANNER_VERSION/bin/
RUN chmod 755 $SONAR_SCANNER_MSBUILD_HOME/sonar-scanner-$SONAR_SCANNER_VERSION/bin/run.sh

VOLUME $DOTNET_PROJECT_DIR
WORKDIR $DOTNET_PROJECT_DIR

# ENTRYPOINT [ "run.sh" ]
