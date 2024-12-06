$graph:
- class: CommandLineTool
  id: '#s1_make_stac'
  inputs:
  - id: '#s1_make_stac/files'
    doc: FILES
    type:
      type: array
      items: File
  - id: '#s1_make_stac/intersects'
    inputBinding:
      prefix: --intersects
    type:
    - 'null'
    - string
  requirements:
  - class: DockerRequirement
    dockerPull: ghcr.io/EO-DataHub/user-workflows/s1_make_stac:main
  - class: InlineJavascriptRequirement
  doc: "None\n"
  baseCommand:
  - python
  - /app/app.py
  outputs:
  - id: '#s1_make_stac/stac_catalog'
    outputBinding:
      glob: .
    type: Directory
- class: CommandLineTool
  id: '#s1_process'
  inputs:
  - id: '#s1_process/intersects'
    inputBinding:
      prefix: --intersects
    type:
    - 'null'
    - string
  - id: '#s1_process/pair'
    inputBinding:
      prefix: --pair
    type: File
  outputs:
  - id: '#s1_process/coherence'
    outputBinding:
      glob: data/results/*/coh_vv.tif
    type: File
  requirements:
  - class: DockerRequirement
    dockerPull: ghcr.io/EO-DataHub/user-workflows/s1_process:main
  - class: InlineJavascriptRequirement
  doc: "None\n"
  baseCommand:
  - python
  - /app/app.py
- class: CommandLineTool
  id: '#s1_search'
  inputs:
  - id: '#s1_search/end_datetime'
    inputBinding:
      prefix: --end-datetime
    type:
    - 'null'
    - string
  - id: '#s1_search/intersects'
    inputBinding:
      prefix: --intersects
    type:
    - 'null'
    - string
  - id: '#s1_search/start_datetime'
    inputBinding:
      prefix: --start-datetime
    type:
    - 'null'
    - string
  outputs:
  - id: '#s1_search/pairs'
    outputBinding:
      glob: pair_*.geojson
    type:
      items: File
      type: array
  requirements:
  - class: DockerRequirement
    dockerPull: ghcr.io/EO-DataHub/user-workflows/s1_search:main
  - class: InlineJavascriptRequirement
  doc: "None\n"
  baseCommand:
  - python
  - /app/app.py
- class: Workflow
  id: '#s1-coherence'
  inputs:
  - id: '#s1-coherence/intersects'
    label: Intersects
    doc: "a GeoJSON-like json string, which provides a \"type\" member describing
      the type of the geometry and \"coordinates\"  member providing a list of coordinates.
      Will search for images intersecting this geometry.\n"
    default: "{\n  \"type\": \"Polygon\",\n  \"coordinates\": [\n    [\n      [0.08905898091569497,
      52.69722175598818],\n      [0.08905898091569497, 52.15527412683906],\n     \
      \ [0.9565339502005088, 52.15527412683906],\n      [0.9565339502005088, 52.69722175598818],\n\
      \      [0.08905898091569497, 52.69722175598818]\n    ]\n  ]\n}\n"
    type: string
  - id: '#s1-coherence/start_datetime'
    label: Start datetime
    doc: Start datetime
    default: '2023-04-01'
    type: string
  - id: '#s1-coherence/end_datetime'
    label: End datetime
    doc: End datetime
    default: '2023-06-30'
    type: string
  outputs:
  - id: '#s1-coherence/stac_output'
    outputSource:
    - '#s1-coherence/s1_make_stac/stac_catalog'
    type: Directory
  requirements:
  - class: ScatterFeatureRequirement
  label: S1 coherence
  doc: Generate Sentinel 1 image pair coherence
  steps:
  - id: '#s1-coherence/s1_search'
    in:
    - id: '#s1-coherence/s1_search/intersects'
      source: '#s1-coherence/intersects'
    - id: '#s1-coherence/s1_search/start_datetime'
      source: '#s1-coherence/start_datetime'
    - id: '#s1-coherence/s1_search/end_datetime'
      source: '#s1-coherence/end_datetime'
    out:
    - id: '#s1-coherence/s1_search/pairs'
    run: '#s1_search'
  - id: '#s1-coherence/s1_process'
    in:
    - id: '#s1-coherence/s1_process/pair'
      source: '#s1-coherence/s1_search/pairs'
    - id: '#s1-coherence/s1_process/intersects'
      source: '#s1-coherence/intersects'
    out:
    - id: '#s1-coherence/s1_process/coherence'
    run: '#s1_process'
    scatter:
    - '#s1-coherence/s1_process/pair'
    scatterMethod: dotproduct
  - id: '#s1-coherence/s1_make_stac'
    in:
    - id: '#s1-coherence/s1_make_stac/intersects'
      source: '#s1-coherence/intersects'
    - id: '#s1-coherence/s1_make_stac/files'
      source: '#s1-coherence/s1_process/coherence'
    out:
    - id: '#s1-coherence/s1_make_stac/stac_catalog'
    run: '#s1_make_stac'
cwlVersion: v1.0
