class: CommandLineTool
id: 
  file:///home/runner/work/user-workflows/user-workflows/resize/eoap-gen-out/cli/resize_make_stac/resize_make_stac.cwl
inputs:
- id: files
  doc: FILES
  type: File[]
outputs:
- id: stac_catalog
  outputBinding:
    glob: .
  type: Directory
requirements:
- class: DockerRequirement
  dockerPull: ghcr.io/eo-datahub/user-workflows/resize_make_stac:main
- class: InlineJavascriptRequirement
doc: |
  None
cwlVersion: v1.0
baseCommand:
- python
- /app/app.py
