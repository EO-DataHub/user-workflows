FROM mambaorg/micromamba


WORKDIR /app

RUN micromamba install -y -n base -c conda-forge python=3.12 eo-tools
ARG MAMBA_DOCKERFILE_ACTIVATE=1
ENV NUMBA_CACHE_DIR=/tmp

RUN pip install click eodag shapely

COPY process.py app.py

CMD ["python"]