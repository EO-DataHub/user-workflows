$graph:
- class: CommandLineTool
  id: '#make_stac.cwl'
  inputs:
  - id: '#make_stac.cwl/files'
    doc: FILES
    type:
      type: array
      items: File
  - id: '#make_stac.cwl/geometry'
    inputBinding:
      prefix: --geometry
    type:
    - 'null'
    - string
  requirements:
  - class: DockerRequirement
    dockerPull: ghcr.io/EO-DataHub/user-workflows/make_stac:main
  - class: InlineJavascriptRequirement
  doc: "None\n"
  baseCommand:
  - python
  - /app/app.py
  outputs:
  - id: '#make_stac.cwl/stac_catalog'
    outputBinding:
      glob: .
    type: Directory
- class: CommandLineTool
  id: '#mosaic.cwl'
  inputs:
  - id: '#mosaic.cwl/all_images'
    doc: ALL_IMAGES
    type:
      type: array
      items: File
  - id: '#mosaic.cwl/intersects'
    inputBinding:
      prefix: --intersects
    type:
    - 'null'
    - string
  - id: '#mosaic.cwl/month_json'
    inputBinding:
      prefix: --month-json
    type: File
  outputs:
  - id: '#mosaic.cwl/best_pixel'
    outputBinding:
      glob: '*.tif'
    type: File
  requirements:
  - class: DockerRequirement
    dockerPull: ghcr.io/EO-DataHub/user-workflows/mosaic:main
  - class: InlineJavascriptRequirement
  doc: "None\n"
  baseCommand:
  - python
  - /app/app.py
- class: CommandLineTool
  id: '#rm_cloud.cwl'
  inputs:
  - id: '#rm_cloud.cwl/item_url'
    inputBinding:
      prefix: --item-url
    type:
    - 'null'
    - string
  outputs:
  - id: '#rm_cloud.cwl/cloud_masked'
    outputBinding:
      glob: '*.tif'
    type: File
  requirements:
  - class: DockerRequirement
    dockerPull: ghcr.io/EO-DataHub/user-workflows/rm_cloud:main
  - class: InlineJavascriptRequirement
  doc: "None\n"
  baseCommand:
  - python
  - /app/app.py
- class: CommandLineTool
  id: '#search.cwl'
  inputs:
  - id: '#search.cwl/catalog'
    inputBinding:
      prefix: --catalog
    type:
    - 'null'
    - string
  - id: '#search.cwl/collection'
    inputBinding:
      prefix: --collection
    type:
    - 'null'
    - string
  - id: '#search.cwl/end_datetime'
    inputBinding:
      prefix: --end-datetime
    type:
    - 'null'
    - string
  - id: '#search.cwl/intersects'
    inputBinding:
      prefix: --intersects
    type:
    - 'null'
    - string
  - id: '#search.cwl/start_datetime'
    inputBinding:
      prefix: --start-datetime
    type:
    - 'null'
    - string
  outputs:
  - id: '#search.cwl/months'
    outputBinding:
      glob: month_*.json
    type:
      items: File
      type: array
  - id: '#search.cwl/urls'
    outputBinding:
      glob: urls.txt
      loadContents: true
      outputEval: $(self[0].contents.split('\n'))
    type:
      items: string
      type: array
  requirements:
  - class: DockerRequirement
    dockerPull: ghcr.io/EO-DataHub/user-workflows/search:main
  - class: InlineJavascriptRequirement
  doc: "None\n"
  baseCommand:
  - python
  - /app/app.py
- class: Workflow
  id: '#main'
  inputs:
  - id: '#main/catalog'
    label: Catalog path
    doc: Full catalog path
    default: supported-datasets/ceda-stac-catalogue
    type: string
  - id: '#main/collection'
    label: collection id
    doc: collection id
    default: sentinel2_ard
    type: string
  - id: '#main/intersects'
    label: Intersects
    doc: "a GeoJSON-like json string, which provides a \"type\" member describing
      the type of the geometry and \"coordinates\"  member providing a list of coordinates.
      Will search for images intersecting this geometry.\n"
    default: "{\n  \"type\": \"Polygon\",\n  \"coordinates\": [\n    [\n      [0.08905898091569497,
      52.69722175598818],\n      [0.08905898091569497, 52.15527412683906],\n     \
      \ [0.9565339502005088, 52.15527412683906],\n      [0.9565339502005088, 52.69722175598818],\n\
      \      [0.08905898091569497, 52.69722175598818]\n    ]\n  ]\n}\n"
    type: string
  - id: '#main/start_datetime'
    label: Start datetime
    doc: Start datetime
    default: '2023-04-01'
    type: string
  - id: '#main/end_datetime'
    label: End datetime
    doc: End datetime
    default: '2023-06-30'
    type: string
  outputs:
  - id: '#main/stac_output'
    outputSource:
    - '#main/make_stac/stac_catalog'
    type: Directory
  requirements:
  - class: ScatterFeatureRequirement
  label: Cloud free best pixel
  doc: Generate cloud free best pixel mosaic on a per month basis
  steps:
  - id: '#main/search'
    in:
    - id: '#main/search/catalog'
      source: '#main/catalog'
    - id: '#main/search/collection'
      source: '#main/collection'
    - id: '#main/search/intersects'
      source: '#main/intersects'
    - id: '#main/search/start_datetime'
      source: '#main/start_datetime'
    - id: '#main/search/end_datetime'
      source: '#main/end_datetime'
    out:
    - id: '#main/search/urls'
    - id: '#main/search/months'
    run: '#search.cwl'
  - id: '#main/rm_cloud'
    in:
    - id: '#main/rm_cloud/item_url'
      source: '#main/search/urls'
    out:
    - id: '#main/rm_cloud/cloud_masked'
    run: '#rm_cloud.cwl'
    scatter:
    - '#main/rm_cloud/item_url'
    scatterMethod: dotproduct
  - id: '#main/mosaic'
    in:
    - id: '#main/mosaic/intersects'
      source: '#main/intersects'
    - id: '#main/mosaic/month_json'
      source: '#main/search/months'
    - id: '#main/mosaic/all_images'
      source: '#main/rm_cloud/cloud_masked'
    out:
    - id: '#main/mosaic/best_pixel'
    run: '#mosaic.cwl'
    scatter:
    - '#main/mosaic/month_json'
    scatterMethod: dotproduct
  - id: '#main/make_stac'
    in:
    - id: '#main/make_stac/geometry'
      source: '#main/intersects'
    - id: '#main/make_stac/files'
      source: '#main/mosaic/best_pixel'
    out:
    - id: '#main/make_stac/stac_catalog'
    run: '#make_stac.cwl'
cwlVersion: v1.0
