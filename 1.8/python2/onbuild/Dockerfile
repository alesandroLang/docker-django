FROM alang/django:1.8-python2

# add application source code
ONBUILD COPY src /usr/django/app

# install application dependencies
ONBUILD RUN pip install -r /usr/django/app/requirements.txt
