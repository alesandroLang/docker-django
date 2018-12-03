FROM python:3.7

# create directory which can be a place for generated static content
# volume can be used to serve these files with a webserver
RUN mkdir -p /var/www/static
VOLUME /var/www/static

# create directory which can be a place for user-uploaded files
# volume can be used to serve these files with a webserver
RUN mkdir -p /var/www/media
VOLUME /var/www/media

# create directory for application source code
# volume can be used for live-reload during development
RUN mkdir -p /usr/django/app
VOLUME /usr/django/app

# set default port for gunicorn
ENV PORT=8000

# add gunicorn config
RUN mkdir -p /etc/gunicorn
COPY gunicorn.conf /etc/gunicorn/

# run start.sh on container start
WORKDIR /usr/django
COPY start.sh /usr/django/
RUN chmod +x start.sh
CMD ./start.sh

# install gettext
RUN apt-get update -yqq && apt-get install -y gettext

# install gunicorn, django and pytz
ENV GUNICORN_VERSION=19.9.0
ENV DJANGO_VERSION=2.1.4
ENV PYTZ_VERSION=2018.7
RUN pip install gunicorn==$GUNICORN_VERSION
RUN pip install django==$DJANGO_VERSION
RUN pip install pytz==$PYTZ_VERSION
