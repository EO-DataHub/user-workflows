class: CommandLineTool
id: 
  file:///home/figi/software/work/eodh/user-workflows/S2-cloud-free-best-pixel/eoap-gen-out/cli/search/search.cwl
inputs:
- id: catalog
  inputBinding:
    prefix: --catalog
  type:
  - "null"
  - string
- id: collection
  inputBinding:
    prefix: --collection
  type:
  - "null"
  - string
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
- id: start_datetime
  inputBinding:
    prefix: --start-datetime
  type:
  - "null"
  - string
outputs:
- id: months
  outputBinding:
    glob: month_*.json
  type:
    items: File
    type: array
- id: urls
  outputBinding:
    glob: urls.txt
    loadContents: true
    outputEval: $(self[0].contents.split('\n'))
  type:
    items: string
    type: array
hints:
- class: DockerRequirement
  dockerPull: ghcr.io/EO-DataHub/user-workflows/search:main
- class: InlineJavascriptRequirement
doc: |
  None
cwlVersion: v1.0
baseCommand:
- python
- /app/app.py
