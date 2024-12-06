FROM python:3-slim


WORKDIR /app


RUN pip install click pyeodh rioxarray xarray

COPY rm_cloud.py app.py

CMD ["python"]