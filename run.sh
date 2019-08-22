#!/bin/bash

DEBUG="${DEBUG}"

if [[ ! -z "${DEBUG}" ]]
then
  set -x
fi

PROJECT_KEY="${PROJECT_KEY:-ConsoleApplication1}"
PROJECT_NAME="${PROJECT_NAME:-ConsoleApplication1}"
PROJECT_VERSION="${PROJECT_VERSION:-1.0}"
SONAR_HOST="${HOST:-http://localhost:9000}"
SONAR_LOGIN_KEY="${LOGIN_KEY:-admin}"
SONAR_LOGIN_USER="${LOGIN_USER}"
SONAR_LOGIN_PASSWORD="${LOGIN_PASSWORD}"
SONAR_DOTNET_FRAMEWORK="${SONAR_DOTNET_FRAMEWORK}"
DOTNET_SOLUTION_DIR="${DOTNET_SOLUTION_DIR}"
BRANCH_NAME="${SONAR_BRANCH_NAME}"
TARGET_BRANCH_NAME="${SONAR_TARGET_BRANCH_NAME}"
DOTNET_TEST_DIR="${DOTNET_TEST_DIR}"

ls -lha

if [[ -z "$SONAR_DOTNET_FRAMEWORK" ]]; then 
  if [[ ! -z "$LOGIN_KEY" ]]; then
    echo "Using Logging Key"
    if [[ -z "${SONAR_TARGET_BRANCH_NAME}" && -z "${SONAR_BRANCH_NAME}" ]]; then
      echo "Without Target"
      dotnet sonarscanner begin \
        /d:sonar.host.url="$SONAR_HOST" \
        /d:sonar.login="$SONAR_LOGIN_KEY" \
        /k:"$PROJECT_KEY" \
        /n:"$PROJECT_NAME" \
        /v:"$PROJECT_VERSION"
    else
      echo "With Target"
      dotnet sonarscanner begin \
        /d:sonar.host.url="$SONAR_HOST" \
        /d:sonar.login="$SONAR_LOGIN_KEY" \
        /d:sonar.branch.name="$BRANCH_NAME" \
        /d:sonar.branch.target="$TARGET_BRANCH_NAME" \
        /k:"$PROJECT_KEY" \
        /n:"$PROJECT_NAME" \
        /v:"$PROJECT_VERSION"
    fi
  else
    echo "Using User and Password"
    if [[ -z "${SONAR_TARGET_BRANCH_NAME}" && -z "${SONAR_BRANCH_NAME}" ]]; then
      echo "Without Target"
      dotnet sonarscanner begin \
        /d:sonar.host.url="$SONAR_HOST" \
        /d:sonar.login="$SONAR_LOGIN_USER" \
        /d:sonar.password="$SONAR_LOGIN_PASSWORD" \
        /k:"$PROJECT_KEY" \
        /n:"$PROJECT_NAME" \
        /v:"$PROJECT_VERSION"
    else
      echo "With Target"
      dotnet sonarscanner begin \
        /d:sonar.host.url="$SONAR_HOST" \
        /d:sonar.login="$SONAR_LOGIN_USER" \
        /d:sonar.password="$SONAR_LOGIN_PASSWORD" \
        /d:sonar.branch.name="$BRANCH_NAME" \
        /d:sonar.branch.target="$TARGET_BRANCH_NAME" \
        /k:"$PROJECT_KEY" \
        /n:"$PROJECT_NAME" \
        /v:"$PROJECT_VERSION"
    fi
  fi

  if [[ -z "${DEBUG}" ]]; then 
    dotnet restore ${DOTNET_SOLUTION_DIR}
  else
    dotnet restore ${DOTNET_SOLUTION_DIR} -v diagnostic
  fi
  
  if [[ ! -z "$DOTNET_TEST_DIR" ]]; then
    dotnet test ${DOTNET_TEST_DIR} --no-build
  fi

  if [[ -z "${DEBUG}" ]]; then 
    dotnet build ${DOTNET_SOLUTION_DIR}
  else
    dotnet build ${DOTNET_SOLUTION_DIR} -v diagnostic
  fi
  
  if [[ ! -z "$LOGIN_KEY" ]]; then
    dotnet sonarscanner end /d:sonar.login="$SONAR_LOGIN_KEY"
  else
    dotnet sonarscanner end /d:sonar.login="$SONAR_LOGIN_USER" /d:sonar.password="$SONAR_LOGIN_PASSWORD"
  fi
else
  mono /opt/sonar-scanner-msbuild/SonarScanner.MSBuild.exe begin /d:sonar.host.url="$SONAR_HOST" /d:sonar.login=$SONAR_LOGIN_KEY /k:$PROJECT_KEY /n:"$PROJECT_NAME" /v:$PROJECT_VERSION
  nuget restore ${DOTNET_SOLUTION_DIR}
  if [[ ! -z "$DOTNET_TEST_DIR" ]]; then
    dotnet test ${DOTNET_TEST_DIR} --no-build
  fi
  dotnet build ${DOTNET_SOLUTION_DIR}
  mono /opt/sonar-scanner-msbuild/SonarScanner.MSBuild.exe end /d:sonar.login="$SONAR_LOGIN_KEY"
fi
