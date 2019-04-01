#!/usr/bin/env bash
set -e

# change into app directory (start.sh can not be there because of volume)
cd app

# set internal field separator to split commands
IFS=';'
DJANGO_MANAGEMENT_JOB_ARRAY=(${DJANGO_MANAGEMENT_JOB})
DJANGO_MANAGEMENT_ON_START_ARRAY=(${DJANGO_MANAGEMENT_ON_START})
unset IFS

executeManagementCommands() {
    COMMAND_ARRAY=("$@")
    for COMMAND in "${COMMAND_ARRAY[@]}"; do
        echo "executing python manage.py ${COMMAND}"
        python manage.py ${COMMAND}
    done
}

# run django management commands without starting gunicorn afterwards
if [ ${#DJANGO_MANAGEMENT_JOB_ARRAY[@]} -ne 0 ]; then
    executeManagementCommands "${DJANGO_MANAGEMENT_JOB_ARRAY[@]}"
    exit 0
fi

# run django management commands before starting gunicorn
if [ ${#DJANGO_MANAGEMENT_ON_START_ARRAY[@]} -ne 0 ]; then
    executeManagementCommands "${DJANGO_MANAGEMENT_ON_START_ARRAY[@]}"
fi

# support for deprecated management command variables
if [ "$DJANGO_MIGRATE" == "true" ]; then
    echo "WARNING: usage of deprecated variable DJANGO_MIGRATE, please migrate to DJANGO_MANAGEMENT_ON_START"
    python manage.py migrate --noinput
fi
if [ "$DJANGO_COLLECTSTATIC" == "true" ]; then
    echo "WARNING: usage of deprecated variable DJANGO_COLLECTSTATIC, please migrate to DJANGO_MANAGEMENT_ON_START"
    python manage.py collectstatic --noinput
fi
if [ "$DJANGO_COMPRESS" == "true" ]; then
    echo "WARNING: usage of deprecated variable DJANGO_COMPRESS, please migrate to DJANGO_MANAGEMENT_ON_START"
    python manage.py compress
fi

# start gunicorn
echo "starting gunicorn (PORT=${PORT}, RELOAD=${GUNICORN_RELOAD:-false}, APP=${DJANGO_APP})"
if [ "$GUNICORN_RELOAD" == "true" ]; then
    gunicorn -c /etc/gunicorn/gunicorn.conf --bind 0.0.0.0:${PORT} --reload ${DJANGO_APP}.wsgi
else
    gunicorn -c /etc/gunicorn/gunicorn.conf --bind 0.0.0.0:${PORT} ${DJANGO_APP}.wsgi
fi
