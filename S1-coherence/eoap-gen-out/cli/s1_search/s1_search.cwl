class: CommandLineTool
id: 
  file:///home/runner/work/user-workflows/user-workflows/S1-coherence/eoap-gen-out/cli/s1_search/s1_search.cwl
inputs:
- id: end_datetime
  inputBinding:
    prefix: --end-datetime
  type:
  - "null"
  - string
- id: intersects
  inputBinding:
    prefix: --intersects
  type:
  - "null"
  - string
- id: password
  inputBinding:
    prefix: --password
  type:
  - "null"
  - string
- id: start_datetime
  inputBinding:
    prefix: --start-datetime
  type:
  - "null"
  - string
- id: username
  inputBinding:
    prefix: --username
  type:
  - "null"
  - string
outputs:
- id: pairs
  outputBinding:
    glob: pair_*.geojson
  type:
    items: File
    type: array
requirements:
- class: DockerRequirement
  dockerPull: ghcr.io/eo-datahub/user-workflows/s1_search:main
- class: InlineJavascriptRequirement
doc: |
  None
cwlVersion: v1.0
baseCommand:
- python
- /app/app.py
