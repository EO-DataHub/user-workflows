FROM python:3-slim

RUN apt update && apt install -y pktools

WORKDIR /app


RUN pip install click

COPY mosaic.py app.py

CMD ["python"]