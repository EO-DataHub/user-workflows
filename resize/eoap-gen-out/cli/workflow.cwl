class: Workflow
id: resize-urls
inputs:
- id: urls
  label: urls
  doc: urls
  type: string[]
- id: outsize_x
  label: outsize_x
  doc: outsize_x
  default: 5%
  type: string
- id: outsize_y
  label: outsize_y
  doc: outsize_y
  default: 5%
  type: string
outputs:
- id: stac_output
  outputSource:
  - resize_make_stac/stac_catalog
  type: Directory
requirements:
- class: ScatterFeatureRequirement
label: Resize urls
doc: Resize urls
cwlVersion: v1.0
steps:
- id: resize_process
  in:
  - id: outsize_x
    source: resize-urls/outsize_x
  - id: outsize_y
    source: resize-urls/outsize_y
  - id: url
    source: resize-urls/urls
  - id: fname
    valueFrom: $(inputs.url.split('/').pop() + "_resized.tif")
  out:
  - id: resized
  run: 
    /home/runner/work/user-workflows/user-workflows/resize/eoap-gen-out/cli/resize_process/resize_process.cwl
  scatter:
  - url
  scatterMethod: dotproduct
- id: resize_make_stac
  in:
  - id: files
    source: resize_process/resized
  out:
  - id: stac_catalog
  run: 
    /home/runner/work/user-workflows/user-workflows/resize/eoap-gen-out/cli/resize_make_stac/resize_make_stac.cwl
