class: CommandLineTool
id: 
  file:///home/runner/work/user-workflows/user-workflows/S1-coherence/eoap-gen-out/cli/s1_process/s1_process.cwl
inputs:
- id: aws_access_key_id
  inputBinding:
    prefix: --aws-access-key-id
  type:
  - "null"
  - string
- id: aws_secret_access_key
  inputBinding:
    prefix: --aws-secret-access-key
  type:
  - "null"
  - string
- id: aws_session_token
  inputBinding:
    prefix: --aws-session-token
  type:
  - "null"
  - string
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
- env
- HOME=/tmp
- python
- /app/app.py
