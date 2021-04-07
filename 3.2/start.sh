#!/usr/bin/env bash
set -e

# change into app directory (start.sh cannot be there because this could be inside the volume)
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

# start gunicorn
echo "starting gunicorn (PORT=${PORT}, RELOAD=${GUNICORN_RELOAD:-false}, APP=${DJANGO_APP})"
if [ "$GUNICORN_RELOAD" == "true" ]; then
    gunicorn -c /etc/gunicorn/gunicorn.conf.py --bind 0.0.0.0:${PORT} --reload ${DJANGO_APP}.wsgi
else
    gunicorn -c /etc/gunicorn/gunicorn.conf.py --bind 0.0.0.0:${PORT} --preload ${DJANGO_APP}.wsgi
fi
