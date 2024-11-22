FROM mambaorg/micromamba

WORKDIR /app

RUN micromamba install -y -n base -c conda-forge python=3.12 click rioxarray xarray dask

ARG MAMBA_DOCKERFILE_ACTIVATE=1

RUN python -m pip install pyeodh

COPY rm_cloud.py app.py

CMD ["python"]
