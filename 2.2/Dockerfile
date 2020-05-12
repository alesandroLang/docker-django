FROM python:3.8-alpine

# add gunicorn user
# -D = Don't assign a password
# using root group for OpenShift compatibility
ENV GUNICORN_USER_NAME=gunicorn
ENV GUNICORN_USER_UID=1001
ENV GUNICORN_USER_GROUP=root
RUN adduser -D -u $GUNICORN_USER_UID -G $GUNICORN_USER_GROUP $GUNICORN_USER_NAME

# create the directory which can be a place for generated static content
# volume can be used to serve these files with a webserver
ENV STATIC_ROOT=/var/www/static
RUN mkdir -p $STATIC_ROOT && chmod 770 $STATIC_ROOT
VOLUME $STATIC_ROOT

# create the directory which can be a place for user-uploaded files
# volume can be used to serve these files with a webserver
ENV MEDIA_ROOT=/var/www/media
RUN mkdir -p $MEDIA_ROOT && chmod 770 $MEDIA_ROOT
VOLUME $MEDIA_ROOT

# create the directory for application source code
# volume can be used for live-reload during development
ENV SOURCE_ROOT=/usr/django/app
RUN mkdir -p $SOURCE_ROOT && chmod 770 $SOURCE_ROOT
VOLUME $SOURCE_ROOT

# set default port for gunicorn
ENV PORT=8000

# add gunicorn config
RUN mkdir -p /etc/gunicorn
COPY gunicorn.conf.py /etc/gunicorn/

# run start.sh on container start
WORKDIR /usr/django
COPY start.sh /usr/django/
RUN chmod 770 start.sh
CMD ./start.sh

# install gettext and bash (required by start.sh)
RUN apk add --no-cache gettext bash

# install gunicorn, django and pytz
ENV GUNICORN_VERSION=20.0.4
ENV DJANGO_VERSION=2.2.12
ENV PYTZ_VERSION=2020.1
RUN pip install gunicorn==$GUNICORN_VERSION
RUN pip install django==$DJANGO_VERSION
RUN pip install pytz==$PYTZ_VERSION

# switch to non-root user
USER $GUNICORN_USER_UID
