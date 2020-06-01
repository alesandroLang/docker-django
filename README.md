# Supported tags
-   latest, 3.0
-   2.2

More detailed information about the tags can be found in the *Image Update* section.

# About this image
This image can be used as a starting point to run django applications.

It uses [gunicorn](http://gunicorn.org/) in the latest version to serve the wsgi application.
The container picks up the wsgi entry point based on the environment variable `DJANGO_APP`.
Gunicorn uses the port defined by the environment variable `PORT` (default port is `8000`).
The environment variable `GUNICORN_RELOAD` can be set to `true` to active live reload if a source file does change.

Django is already installed within the version specified by the image.
For example `3.0` will contain the latest django version of `3.0.x`.
The image does also ship with the latest version of `pytz` and `gettext` installed.
Using the latest supported python version for the corresponding django release.

You can use volumes to access generated static and user-uploaded files (`/var/www/static` and `/var/www/media`).
Create a volume for `/usr/django/app` for live reload during development.

To execute django management commands like for example `collectstatic` the environment variable `DJANGO_MANAGEMENT_ON_START` can
be set to a semicolon separated list of commands (e.g. `migrate --noinput;collectstatic --noinput`). These commands will be
executed in the specified order before django will be started. This docker image can also be used to execute certain management
commands without starting django afterwards. This is useful if you are running multiple django containers and want to schedule a
job only once. Therefore use the environment variable `DJANGO_MANAGEMENT_JOB`.

Gunicorn starts with the non-root user `gunicorn`.
This user is member of the `root` group for OpenShift compatibility.

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

## Gunicorn Configuration

A custom gunicorn config can be included:

    COPY gunicorn.conf /etc/gunicorn/

## Install System Packages

The image is based on [Alpine Linux](https://alpinelinux.org/).

Therefore `apk` must be used to install additional packages:

    # install system packages required by psycopg2
    USER root
    RUN apk add --no-cache gcc postgresql-dev musl-dev
    USER $GUNICORN_USER_UID

# Image Update

Once a day the base image is updated, and a new image will be build based on it to pick up updates within the base image.

To simplify the update process when using this image, in addition to the stable tags (e.g. `3.0`), unique tags containing the git
commit of this repository plus the current date will be created (e.g. `3.0-c68d547-20200529`).

This means that the stable tags always represent the most recent version, whereby the unique tags allow changes in this
repository, or the base image to be imported in a controlled manner.

# User Feedback

## Issues
If you have any problems with or questions about this image, please contact me through a GitHub issue.

## Contributing
You are invited to contribute new features, fixes, or updates, large or small.
Please send me a pull request.

# CI

The following GitHub workflows do exist:

- **push-to-docker-registry**
  Does build the image with an updated base image and store it within the [official docker registry](https://hub.docker.com/r/alang/django).

- **verify**
  Verifies each commit on master and each pull request by building the docker image.

- **create-update-pr**
  Create a pull request whenever a new version of Django, Gunicorn or pytz is available.
