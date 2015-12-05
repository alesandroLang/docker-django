FROM alang/django:1.9-python3

# add application source code
ONBUILD COPY src /usr/django/app

# install application dependencies
ONBUILD RUN pip install -r /usr/django/app/requirements.txt
