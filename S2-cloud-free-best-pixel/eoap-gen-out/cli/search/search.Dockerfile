FROM python:3-slim

WORKDIR /app

RUN pip install click pyeodh

COPY search.py app.py

CMD ["python"]