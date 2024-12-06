class: CommandLineTool
id: 
  file:///home/runner/work/user-workflows/user-workflows/S1-coherence/eoap-gen-out/cli/s1_make_stac/s1_make_stac.cwl
inputs:
- id: files
  doc: FILES
  type: File[]
- id: intersects
  inputBinding:
    prefix: --intersects
  type:
  - "null"
  - string
outputs:
- id: stac_catalog
  outputBinding:
    glob: .
  type: Directory
requirements:
- class: DockerRequirement
  dockerPull: ghcr.io/EO-DataHub/user-workflows/s1_make_stac:main
- class: InlineJavascriptRequirement
doc: |
  None
cwlVersion: v1.0
baseCommand:
- python
- /app/app.py
