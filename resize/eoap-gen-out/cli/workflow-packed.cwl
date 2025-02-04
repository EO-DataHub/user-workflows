$graph:
- class: CommandLineTool
  id: '#resize_make_stac'
  inputs:
  - id: '#resize_make_stac/files'
    doc: FILES
    type:
      type: array
      items: File
  requirements:
  - class: DockerRequirement
    dockerPull: ghcr.io/eo-datahub/user-workflows/resize_make_stac:main
  - class: InlineJavascriptRequirement
  doc: "None\n"
  baseCommand:
  - python
  - /app/app.py
  outputs:
  - id: '#resize_make_stac/stac_catalog'
    outputBinding:
      glob: .
    type: Directory
- class: CommandLineTool
  inputs:
  - id: '#resize_process/url'
    inputBinding:
      position: 1
      prefix: /vsicurl/
      separate: false
    type: string
  - id: '#resize_process/fname'
    inputBinding:
      position: 2
      separate: false
      valueFrom: $(inputs.url.split('/').pop() + "_resized.tif")
    type: string
  - id: '#resize_process/outsize_x'
    inputBinding:
      position: 4
      prefix: -outsize
      separate: true
    type: string
  - id: '#resize_process/outsize_y'
    inputBinding:
      position: 5
      separate: false
    type: string
  outputs:
  - type: File
    outputBinding:
      glob: '*.tif'
    id: '#resize_process/resized'
  requirements:
  - class: DockerRequirement
    dockerPull: ghcr.io/osgeo/gdal:ubuntu-small-latest
  - class: InlineJavascriptRequirement
  baseCommand: gdal_translate
  id: '#resize_process'
- class: Workflow
  id: '#resize-urls'
  inputs:
  - id: '#resize-urls/urls'
    label: urls
    doc: urls
    type:
      type: array
      items: string
  - id: '#resize-urls/outsize_x'
    label: outsize_x
    doc: outsize_x
    default: 5%
    type: string
  - id: '#resize-urls/outsize_y'
    label: outsize_y
    doc: outsize_y
    default: 5%
    type: string
  outputs:
  - id: '#resize-urls/stac_output'
    outputSource:
    - '#resize-urls/resize_make_stac/stac_catalog'
    type: Directory
  requirements:
  - class: ScatterFeatureRequirement
  label: Resize urls
  doc: Resize urls
  steps:
  - id: '#resize-urls/resize_process'
    in:
    - id: '#resize-urls/resize_process/outsize_x'
      source: '#resize-urls/outsize_x'
    - id: '#resize-urls/resize_process/outsize_y'
      source: '#resize-urls/outsize_y'
    - id: '#resize-urls/resize_process/url'
      source: '#resize-urls/urls'
    - id: '#resize-urls/resize_process/fname'
      valueFrom: $(inputs.url.split('/').pop() + "_resized.tif")
    out:
    - id: '#resize-urls/resize_process/resized'
    run: '#resize_process'
    scatter:
    - '#resize-urls/resize_process/url'
    scatterMethod: dotproduct
  - id: '#resize-urls/resize_make_stac'
    in:
    - id: '#resize-urls/resize_make_stac/files'
      source: '#resize-urls/resize_process/resized'
    out:
    - id: '#resize-urls/resize_make_stac/stac_catalog'
    run: '#resize_make_stac'
cwlVersion: v1.0
