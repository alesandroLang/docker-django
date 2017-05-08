FROM alang/django:{{IMAGE_VERSION}}-python{{PYTHON_VERSION}}

# add application source code
ONBUILD COPY src /usr/django/app

# install application dependencies
ONBUILD RUN pip install -r /usr/django/app/requirements.txt
