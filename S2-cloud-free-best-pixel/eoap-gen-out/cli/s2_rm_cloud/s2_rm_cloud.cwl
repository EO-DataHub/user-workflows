class: CommandLineTool
id: 
  file:///home/runner/work/user-workflows/user-workflows/S2-cloud-free-best-pixel/eoap-gen-out/cli/s2_rm_cloud/s2_rm_cloud.cwl
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
  dockerPull: ghcr.io/eo-datahub/user-workflows/s2_rm_cloud:main
- class: InlineJavascriptRequirement
doc: |
  None
cwlVersion: v1.0
baseCommand:
- /usr/local/bin/_entrypoint.sh
- env
- HOME=/tmp
- python
- /app/app.py
