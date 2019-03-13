#!/usr/bin/env bash
# Make changes to files based on Environment Variables.

VERSION=1.0.0

# Debugging. Values: 0 for no debugging; 1 for debugging.

DEBUG=${SENZING_DEBUG:-0}

# A file used to determine if/when this program has previously run.

SENTINEL_FILE=${SENZING_ROOT}/docker-runs.sentinel

# Return codes.

OK=0
NOT_OK=1

# Construct the FINAL_COMMAND.

FINAL_COMMAND="$@"

if [ ${DEBUG} -gt 0 ]; then
  echo "FINAL_COMMAND: ${FINAL_COMMAND}"
fi

# Short-circuit for certain commandline options.

if [ "$1" == "--version" ]; then
  echo "docker-entrypoint.sh version ${VERSION}"
  exit ${OK}
fi

if [ "$1" == "--sleep" ]; then
  echo "Sleeping"
  sleep 1d
  exit ${OK}
fi

# Short-circuit if SENZING_DATABASE_URL not specified.

if [ -z "${SENZING_DATABASE_URL}" ]; then
  if [ ${DEBUG} -gt 0 ]; then
    echo "Using internal SQLite database"
  fi
  echo "$(date)" >> ${SENTINEL_FILE}
  exec ${FINAL_COMMAND}
  exit ${OK}
fi

# Verify environment variables.

if [ -z "${SENZING_ROOT}" ]; then
  echo "ERROR: Environment variable SENZING_ROOT not set."
  exit ${NOT_OK}
fi

# Parse the SENZING_DATABASE_URL.

PROTOCOL="$(echo ${SENZING_DATABASE_URL} | sed -e's,^\(.*\)://.*,\1,g')"
DRIVER="$(echo ${SENZING_DATABASE_URL} | cut -d ':' -f1)"
UPPERCASE_DRIVER=$(echo "${DRIVER}" | tr '[:lower:]' '[:upper:]')
USERNAME="$(echo ${SENZING_DATABASE_URL} | cut -d '/' -f3 | cut -d ':' -f1)"
PASSWORD="$(echo ${SENZING_DATABASE_URL} | cut -d ':' -f3 | cut -d '@' -f1)"
HOST="$(echo ${SENZING_DATABASE_URL} | cut -d '@' -f2 | cut -d ':' -f1)"
PORT="$(echo ${SENZING_DATABASE_URL} | cut -d ':' -f4 | cut -d '/' -f1)"
SCHEMA="$(echo ${SENZING_DATABASE_URL} | cut -d '/' -f4)"

if [ ${DEBUG} -gt 0 ]; then
  echo "PROTOCOL: ${PROTOCOL}"
  echo "  DRIVER: ${DRIVER}"
  echo "U_Driver: ${UPPERCASE_DRIVER}"
  echo "USERNAME: ${USERNAME}"
  echo "PASSWORD: ${PASSWORD}"
  echo "    HOST: ${HOST}"
  echo "    PORT: ${PORT}"
  echo "  SCHEMA: ${SCHEMA}"
fi

# Set NEW_SENZING_DATABASE_URL.

NEW_SENZING_DATABASE_URL=""
if [ "${PROTOCOL}" == "mysql" ]; then
  NEW_SENZING_DATABASE_URL="${PROTOCOL}://${USERNAME}:${PASSWORD}@${HOST}:${PORT}/?schema=${SCHEMA}"
elif [ "${PROTOCOL}" == "postgresql" ]; then
  NEW_SENZING_DATABASE_URL="${PROTOCOL}://${USERNAME}:${PASSWORD}@${HOST}:${PORT}:${SCHEMA}/"
elif [ "${PROTOCOL}" == "db2" ]; then
  NEW_SENZING_DATABASE_URL="${PROTOCOL}://${USERNAME}:${PASSWORD}@${SCHEMA}"
else
  echo "ERROR: Unknown protocol: ${PROTOCOL}"
  exit ${NOT_OK}
fi

if [ ${DEBUG} -gt 0 ]; then
  echo "NEW_SENZING_DATABASE_URL: ${NEW_SENZING_DATABASE_URL}"
fi

# =============================================================================
# Initialization that is required every time.
# =============================================================================

# -----------------------------------------------------------------------------
# Handle "mysql" protocol.
# -----------------------------------------------------------------------------

if [ "${PROTOCOL}" == "mysql" ]; then

  cp /etc/odbc.ini.mysql-template /etc/odbc.ini
  sed -i.$(date +%s) \
    -e "s/{SCHEMA}/${SCHEMA}/" \
    -e "s/{DRIVER}/${UPPERCASE_DRIVER}/" \
    -e "s/{HOST}/${HOST}/" \
    -e "s/{PORT}/${PORT}/" \
    -e "s/{USERNAME}/${USERNAME}/" \
    -e "s/{PASSWORD}/${PASSWORD}/" \
    -e "s/{SCHEMA}/${SCHEMA}/" \
    /etc/odbc.ini

  if [ ${DEBUG} -gt 0 ]; then
    echo "---------- /etc/odbc.ini ------------------------------------------------------"
    cat /etc/odbc.ini
    echo "-------------------------------------------------------------------------------"
  fi

# -----------------------------------------------------------------------------
# Handle "postgresql" protocol.
# -----------------------------------------------------------------------------

elif [ "${PROTOCOL}" == "postgresql" ]; then

  cp /etc/odbc.ini.postgresql-template /etc/odbc.ini
  sed -i.$(date +%s) \
    -e "s/{SCHEMA}/${SCHEMA}/" \
    -e "s/{DRIVER}/${UPPERCASE_DRIVER}/" \
    -e "s/{HOST}/${HOST}/" \
    -e "s/{PORT}/${PORT}/" \
    -e "s/{USERNAME}/${USERNAME}/" \
    -e "s/{PASSWORD}/${PASSWORD}/" \
    -e "s/{SCHEMA}/${SCHEMA}/" \
    /etc/odbc.ini

  cp /etc/odbcinst.ini.postgresql-template /etc/odbcinst.ini

  if [ ${DEBUG} -gt 0 ]; then
    echo "---------- /etc/odbc.ini ------------------------------------------------------"
    cat /etc/odbc.ini
    echo "---------- /etc/odbcinst.ini --------------------------------------------------"
    cat /etc/odbcinst.ini
    echo "-------------------------------------------------------------------------------"
  fi

# -----------------------------------------------------------------------------
# Handle "db2" protocol.
# -----------------------------------------------------------------------------

elif [ "${PROTOCOL}" == "db2" ]; then

  echo "" >> /etc/odbcinst.ini  # Create a file if it is not there.
  sed -i.$(date +%s) \
    -e "\$a[${UPPERCASE_DRIVER}]\nDescription = Db2 ODBC Driver\nDriver = /opt/IBM/db2/clidriver/lib/libdb2o.so\nFileUsage = 1\ndontdlclose = 1\n" \
    /etc/odbcinst.ini

  cp /etc/odbc.ini.db2-template /etc/odbc.ini
  sed -i.$(date +%s) \
    -e "s/{HOST}/${HOST}/" \
    -e "s/{PORT}/${PORT}/" \
    -e "s/{SCHEMA}/${SCHEMA}/" \
    /etc/odbc.ini

  cp /opt/IBM/db2/clidriver/cfg/db2dsdriver.cfg.db2-template /opt/IBM/db2/clidriver/cfg/db2dsdriver.cfg
  sed -i.$(date +%s) \
    -e "s/{HOST}/${HOST}/" \
    -e "s/{PORT}/${PORT}/" \
    -e "s/{SCHEMA}/${SCHEMA}/" \
    /opt/IBM/db2/clidriver/cfg/db2dsdriver.cfg

  if [ ${DEBUG} -gt 0 ]; then
    echo "---------- /etc/odbc.ini ------------------------------------------------------"
    cat /etc/odbc.ini
    echo "---------- /etc/odbcinst.ini --------------------------------------------------"
    cat /etc/odbcinst.ini
    echo "---------- /opt/IBM/db2/clidriver/cfg/db2dsdriver.cfg -------------------------"
    cat /opt/IBM/db2/clidriver/cfg/db2dsdriver.cfg
    echo "-------------------------------------------------------------------------------"
  fi

fi

# Exit if one-time initialization has been previously performed.

if [ -f ${SENTINEL_FILE} ]; then
  if [ ${DEBUG} -gt 0 ]; then
    echo "Sentinel file ${SENTINEL_FILE} exist. Initialization has already been done."
  fi
  exec ${FINAL_COMMAND}
  exit ${OK}
fi

# =============================================================================
# Initialization that is required only once.
# Usually because attached volume has already been initialized.
# =============================================================================

# -----------------------------------------------------------------------------
# Handle "mysql" protocol.
# -----------------------------------------------------------------------------

if [ "${PROTOCOL}" == "mysql" ]; then

  # Work-around https://senzing.zendesk.com/hc/en-us/articles/360009212393-MySQL-V8-0-ODBC-client-alongside-V5-x-Server

  if [ ! -f ${SENZING_ROOT}/g2/lib/centos/libmysqlclient.so.21 ]; then
    mkdir -p ${SENZING_ROOT}/g2/lib/centos
    cp /usr/lib64/mysql/libmysqlclient.so.21 ${SENZING_ROOT}/g2/lib/centos
  fi

# -----------------------------------------------------------------------------
# Handle "postgresql" protocol.
# -----------------------------------------------------------------------------

elif [ "${PROTOCOL}" == "postgresql" ]; then

  true  # Need a statement in bash if/else

# -----------------------------------------------------------------------------
# Handle "db2" protocol.
# -----------------------------------------------------------------------------

elif [ "${PROTOCOL}" == "db2" ]; then

  true  # Need a statement in bash if/else

fi

# -----------------------------------------------------------------------------
# Handle common changes.
# -----------------------------------------------------------------------------

sed -i.$(date +%s) \
  -e "s|G2Connection=sqlite3://na:na@${SENZING_ROOT}/g2/sqldb/G2C.db|G2Connection=${NEW_SENZING_DATABASE_URL}|" \
  ${SENZING_ROOT}/g2/python/G2Project.ini

sed -i.$(date +%s) \
  -e "s|CONNECTION=sqlite3://na:na@${SENZING_ROOT}/g2/sqldb/G2C.db|CONNECTION=${NEW_SENZING_DATABASE_URL}|" \
  ${SENZING_ROOT}/g2/python/G2Module.ini

if [ ${DEBUG} -gt 0 ]; then
  echo "---------- g2/python/G2Project.ini --------------------------------------------"
  cat ${SENZING_ROOT}/g2/python/G2Project.ini
  echo "---------- g2/python/G2Module.ini ---------------------------------------------"
  cat ${SENZING_ROOT}/g2/python/G2Module.ini
  echo "-------------------------------------------------------------------------------"
fi

# -----------------------------------------------------------------------------
# Epilog
# -----------------------------------------------------------------------------

# Append to a "sentinel file" to indicate when this script has been run.
# The sentinel file is used to identify the first run from subsequent runs for "first-time" processing.

echo "$(date)" >> ${SENTINEL_FILE}

# Run the command specified by the parameters.

exec ${FINAL_COMMAND}
