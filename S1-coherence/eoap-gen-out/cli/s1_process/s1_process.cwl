class: CommandLineTool
id: 
  file:///home/runner/work/user-workflows/user-workflows/S1-coherence/eoap-gen-out/cli/s1_process/s1_process.cwl
inputs:
- id: intersects
  inputBinding:
    prefix: --intersects
  type:
  - "null"
  - string
- id: pair
  inputBinding:
    prefix: --pair
  type: File
- id: password
  inputBinding:
    prefix: --password
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
- id: coherence
  outputBinding:
    glob: data/results/coh_vv.tif
  type: File
requirements:
- class: DockerRequirement
  dockerPull: ghcr.io/eo-datahub/user-workflows/s1_process:main
- class: InlineJavascriptRequirement
doc: |
  None
cwlVersion: v1.0
baseCommand:
- /usr/local/bin/_entrypoint.sh
- python
- /app/app.py
