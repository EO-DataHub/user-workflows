class: CommandLineTool
id: 
  file:///home/runner/work/user-workflows/user-workflows/S2-cloud-free-best-pixel/eoap-gen-out/cli/s2_make_stac/s2_make_stac.cwl
inputs:
- id: files
  doc: FILES
  type: File[]
- id: geometry
  inputBinding:
    prefix: --geometry
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
  dockerPull: ghcr.io/EO-DataHub/user-workflows/s2_make_stac:main
- class: InlineJavascriptRequirement
doc: |
  None
cwlVersion: v1.0
baseCommand:
- python
- /app/app.py
