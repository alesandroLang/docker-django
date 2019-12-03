# Supported tags
-   latest, 3.0
-   2.2

# About this image
This image can be used as a starting point to run django applications.

It uses [gunicorn](http://gunicorn.org/) in the latest version to serve the wsgi application.
The container picks up the wsgi entry point based on the environment variable `DJANGO_APP`.
Gunicorn uses the port defined by the environment variable `PORT` (default port is `8000`).
The environment variable `GUNICORN_RELOAD` can be set to `true` to active live reload if a source file
does change.

Django is already installed within the version specified by the image.
For example `3.0` will contain the latest django version of `3.0.x`.
The image does also ship with the latest version of `pytz` and `gettext` installed.
Using the latest supported python version for the corresponding django release.

It has volumes defined for generated static and user-uploaded files (`/var/www/static` and `/var/www/media`).
The volume `/usr/django/app` can be used for live reload during development.

To execute django management commands like for example `collectstatic` the environment variable `DJANGO_MANAGEMENT_ON_START` can
be set to a semicolon separated list of commands (e.g. `migrate --noinput;collectstatic --noinput`). These commands will be
executed in the specified order before django will be started. This docker image can also be used to execute certain management
commands without starting django afterwards. This is useful if you are running multiple django containers and want to schedule a
job only once. Therefore use the environment variable `DJANGO_MANAGEMENT_JOB`.

*The environment variables `DJANGO_MIGRATE`, `DJANGO_COLLECTSTATIC` and `DJANGO_COMPRESS` are deprecated, please migrate to
`DJANGO_MANAGEMENT_ON_START`.*

# How to use this image

## Basic Setup

    FROM alang/django
    ENV DJANGO_APP=demo                # will start /usr/django/app/demo/wsgi.py
    COPY src /usr/django/app

## Create new django project

Bootstrap a new project called `demo` within the `src` folder:

    docker run --rm -v "$PWD/src:/usr/django/app" alang/django django-admin startproject demo app

## Executing one off commands

How to execute one off django commands like `makemigrations`:

    docker run --rm -v "$PWD/src:/usr/django/app" -e DJANGO_MANAGEMENT_JOB=makemigrations alang/django

## Advanced Configuration

A custom gunicorn config can be included:

    COPY gunicorn.conf /etc/gunicorn/

# User Feedback

## Issues
If you have any problems with or questions about this image, please contact me through a GitHub issue.

## Contributing
You are invited to contribute new features, fixes, or updates, large or small.
Please send me a pull request.
