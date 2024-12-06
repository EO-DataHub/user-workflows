FROM python:3-slim


WORKDIR /app


RUN pip install click shapely geopandas eodag

COPY search.py app.py

CMD ["python"]