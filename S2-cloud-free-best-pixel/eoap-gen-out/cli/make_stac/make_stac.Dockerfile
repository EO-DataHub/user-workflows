FROM python:3-slim

WORKDIR /app

RUN pip install pystac click shapely

COPY make_stac.py app.py

CMD ["python"]