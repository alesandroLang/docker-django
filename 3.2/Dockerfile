FROM python:3.11-alpine

# add gunicorn user
# -D = Don't assign a password
# using root group for OpenShift compatibility
ENV GUNICORN_USER_NAME=gunicorn
ENV GUNICORN_USER_UID=1001
ENV GUNICORN_USER_GROUP=root
RUN adduser -D -u $GUNICORN_USER_UID -G $GUNICORN_USER_GROUP $GUNICORN_USER_NAME

# set default port for gunicorn
ENV PORT=8000

# add gunicorn config
ENV GUNICORN_CONFIG_ROOT=/etc/gunicorn
RUN mkdir -p $GUNICORN_CONFIG_ROOT
COPY gunicorn.conf.py $GUNICORN_CONFIG_ROOT

# setup working directory
ENV WORKDIR=/usr/django
RUN mkdir -p $WORKDIR
WORKDIR $WORKDIR

# install tini to ensure that gunicorn processes will receive signals
# install gettext and bash (required by start.sh)
RUN apk add --no-cache tini gettext bash

# run start.sh on container start
COPY start.sh $WORKDIR
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["./start.sh"]

# create directories for generated static content, user-uploaded files and application source code
ENV STATIC_ROOT=/var/www/static
ENV MEDIA_ROOT=/var/www/media
ENV SOURCE_ROOT=$WORKDIR/app
RUN mkdir -p $STATIC_ROOT $MEDIA_ROOT $SOURCE_ROOT

# making sure the gunicorn user has access to all these resources
RUN chown -R $GUNICORN_USER_NAME $GUNICORN_CONFIG_ROOT $WORKDIR $STATIC_ROOT $MEDIA_ROOT && \
  chgrp -R $GUNICORN_USER_GROUP $GUNICORN_CONFIG_ROOT $WORKDIR $STATIC_ROOT $MEDIA_ROOT && \
  chmod -R 770 $GUNICORN_CONFIG_ROOT $WORKDIR $STATIC_ROOT $MEDIA_ROOT

# install gunicorn & django
ENV GUNICORN_VERSION=23.0.0
ENV DJANGO_VERSION=3.2.25
RUN pip install \
  gunicorn==$GUNICORN_VERSION \
  django==$DJANGO_VERSION

# install pytz for Django 3.x
RUN if [[ "$DJANGO_VERSION" == 3.* ]]; then pip install pytz==2024.1; fi

# switch to non-root user
USER $GUNICORN_USER_UID
