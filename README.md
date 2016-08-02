# Supported tags
-   latest, 1.10-python3
-   1.10-python3-onbuild
-   1.10-python2
-   1.10-python2-onbuild
-   1.9-python3
-   1.9-python3-onbuild
-   1.9-python2
-   1.9-python2-onbuild
-   1.8-python3
-   1.8-python3-onbuild
-   1.8-python2
-   1.8-python2-onbuild

# About this image
This image can be used as a starting point to run django applications.
It uses [gunicorn](http://gunicorn.org/) in the latest version to serve the wsgi application.
The container picks up the wsgi entry point based on the environment variable `DJANGO_APP`.

Django is already installed within the version specified by the image.
For example `1.9-python3` will contain the latest django version of `1.9.x`.
The image does also ship with the latest version of `pytz` installed.

The image does export port `8000`.

It has a volume defined to generate static resources at `/var/www/static`.
The volume `/usr/django/app` can be used for live reload during development.

The environment variable `GUNICORN_RELOAD` can be set to `true` to active live reload if a source file
does change.

If the following environment variables are set to `true` the corresponding django command will
be executing on container start:
- `DJANGO_MIGRATE`
- `DJANGO_COLLECTSTATIC`
- `DJANGO_COMPRESS`

# How to use this image

## Basic Setup

    FROM alang/django
    ENV DJANGO_APP=demo                # will start /usr/django/app/demo/wsgi.py
    COPY django_source /usr/django/app

## Using the onbuild image

The `-onbuild` variant of the image does assume that your build directory (directory where the
Dockerfile is located) contains a directory called `src` which is the place where the django source
code is. This directory will be copied to `/usr/django/app`.
The image does also assume that your source code contains a `requirements.txt` file in the `src`
directory. All dependencies listed there will be installed.

## Executing one off commands

How to execute one off django commands like `makemigrations`:

    docker run --rm -v "src:/usr/django/app" alang/django python app/manage.py makemigrations

## Advanced Configuration

A custom gunicorn config can be included:

    COPY gunicorn.conf /etc/gunicorn/

# User Feedback

## Issues
If you have any problems with or questions about this image, please contact me through a GitHub issue.

## Contributing
You are invited to contribute new features, fixes, or updates, large or small.
Please send me a pull request.

