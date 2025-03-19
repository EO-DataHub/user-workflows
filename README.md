# user-workflows

This repository contains user specific processing workflows for the EO Data Hub.

## S1 Coherence Workflow

To run on ADES, see [this notebook](S1-coherence/ades.ipynb).

## Development

### Requirements:

- micromamba/mamba/conda

### Setup virtual environment:

```
micromamba env create -p ./venv -f environment.yml
```

If missing pip dependencies, install from `requirements.txt`:

```
micromamba activate ./venv
pip install -r requirements.txt
```

_Note: This should not be necessary in the future, as micromamba fixed missing pip deps in environment.yml._

### Add conda dependency:

```
micromamba install <package name>
micromamba env export > environment.yml
```
