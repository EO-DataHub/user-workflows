class: CommandLineTool
id: 
  file:///home/figi/software/work/eodh/user-workflows/S2-cloud-free-best-pixel/eoap-gen-out/cli/rm_cloud/rm_cloud.cwl
inputs:
- id: item_url
  inputBinding:
    prefix: --item-url
  type:
  - "null"
  - string
outputs:
- id: cloud_masked
  outputBinding:
    glob: '*.tif'
  type: File
requirements:
- class: DockerRequirement
  dockerPull: ghcr.io/EO-DataHub/user-workflows/rm_cloud:main
- class: InlineJavascriptRequirement
doc: |
  None
cwlVersion: v1.0
baseCommand:
- python
- /app/app.py
