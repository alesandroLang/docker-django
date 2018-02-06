#!/bin/sh
set -e

# change into app directory (start.sh can not be there because of volume)
cd app

# run django setup commands if enabled
if [ "$DJANGO_MIGRATE" == "true" ]; then
    python manage.py migrate --noinput
fi
if [ "$DJANGO_COLLECTSTATIC" == "true" ]; then
    python manage.py collectstatic --noinput
fi
if [ "$DJANGO_COMPRESS" == "true" ]; then
    python manage.py compress
fi

# start gunicorn
if [ "$GUNICORN_RELOAD" == "true" ]; then
    gunicorn -c /etc/gunicorn/gunicorn.conf --reload ${DJANGO_APP}.wsgi
else
    gunicorn -c /etc/gunicorn/gunicorn.conf ${DJANGO_APP}.wsgi
fi
