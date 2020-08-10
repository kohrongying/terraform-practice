FROM python:3.6.1-alpine
WORKDIR /project
COPY . /project
RUN pip install -r requirements.txt
ENTRYPOINT [ "python" ]

CMD [ "app.py" ]