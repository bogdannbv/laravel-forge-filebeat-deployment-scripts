#!/usr/bin/bash

VERSION="8.9.0"

CONFIG_DIR="/etc/filebeat"
CONFIG_FILE="${CONFIG_DIR}/filebeat.yml"

SERVICE_DIR="/etc/systemd/system/filebeat.service.d"
SERVICE_AUTH_FILE="${SERVICE_DIR}/auth.conf"

APP_NAME=
LOGS_PATH_PATTERN=

usage() {
  echo "Usage: $0 -i <cloud-id> -a <cloud-auth> -n <app-name> [-v <filebeat-version> (${VERSION})] [-p <logs-path-pattern> (/home/forge/<app-name>/storage/logs/filebeat-*.log)]" 1>&2
  exit 1
}

separator() {
  echo -e "\n----------------------------------------"
}

while getopts ":i:a:n:v:p:" o; do
  case "${o}" in
  i)
    CLOUD_ID=${OPTARG}
    ;;
  a)
    CLOUD_AUTH=${OPTARG}
    ;;
  n)
    APP_NAME=${OPTARG}
    ;;
  v)
    VERSION=${OPTARG}
    ;;
  p)
    LOGS_PATH_PATTERN=${OPTARG}
    ;;
  *)
    usage
    ;;
  esac
done
shift $((OPTIND - 1))

if [ -z "${CLOUD_ID}" ] || [ -z "${CLOUD_AUTH}" ] || [ -z "${VERSION}" ] || [ -z "${APP_NAME}" ]; then
  usage
fi

if [ -z "${LOGS_PATH_PATTERN}" ]; then
  LOGS_PATH_PATTERN="/home/forge/${APP_NAME}/storage/logs/filebeat-*.log"
fi

echo "Installing filebeat..."
curl -L -O "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${VERSION}-amd64.deb"
sudo dpkg -i filebeat-${VERSION}-amd64.deb
rm filebeat-${VERSION}-amd64.deb
separator;

echo "Creating ${SERVICE_DIR} directory..."
sudo mkdir "${SERVICE_DIR}"
separator

echo "Creating ${SERVICE_AUTH_FILE}..."
sed -e "s/<cloud_id>/${CLOUD_ID}/" -e "s/<cloud_auth>/${CLOUD_AUTH}/" ./auth.conf | sudo tee "${SERVICE_AUTH_FILE}" > /dev/null
separator

echo -e "Creating ${CONFIG_FILE}..."
sudo mv "${CONFIG_FILE}" "${CONFIG_FILE}.bak"
sed -e "s/<app_name>/${APP_NAME}/" -e "s#<logs_path_pattern>#${LOGS_PATH_PATTERN}#" ./filebeat.yml | sudo tee "${CONFIG_FILE}" > /dev/null
separator

echo "After verifying the configuration, run the following commands:

systemctl daemon-reload
systemctl enable filebeat.service
systemctl start filebeat.service
journalctl -u filebeat.service
"
