class: CommandLineTool
id: 
  file:///home/runner/work/user-workflows/user-workflows/S2-cloud-free-best-pixel/eoap-gen-out/cli/s2_mosaic/s2_mosaic.cwl
inputs:
- id: all_images
  doc: ALL_IMAGES
  type: File[]
- id: intersects
  inputBinding:
    prefix: --intersects
  type:
  - "null"
  - string
- id: month_json
  inputBinding:
    prefix: --month-json
  type: File
outputs:
- id: best_pixel
  outputBinding:
    glob: '*.tif'
  type: File
requirements:
- class: DockerRequirement
  dockerPull: ghcr.io/EO-DataHub/user-workflows/s2_mosaic:main
- class: InlineJavascriptRequirement
doc: |
  None
cwlVersion: v1.0
baseCommand:
- python
- /app/app.py
