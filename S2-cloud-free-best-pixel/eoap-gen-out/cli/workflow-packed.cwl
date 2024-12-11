$graph:
- class: CommandLineTool
  id: '#s2_make_stac'
  inputs:
  - id: '#s2_make_stac/files'
    doc: FILES
    type:
      type: array
      items: File
  - id: '#s2_make_stac/geometry'
    inputBinding:
      prefix: --geometry
    type:
    - 'null'
    - string
  requirements:
  - class: DockerRequirement
    dockerPull: ghcr.io/eo-datahub/user-workflows/s2_make_stac:main
  - class: InlineJavascriptRequirement
  doc: "None\n"
  baseCommand:
  - python
  - /app/app.py
  outputs:
  - id: '#s2_make_stac/stac_catalog'
    outputBinding:
      glob: .
    type: Directory
- class: CommandLineTool
  id: '#s2_mosaic'
  inputs:
  - id: '#s2_mosaic/all_images'
    doc: ALL_IMAGES
    type:
      type: array
      items: File
  - id: '#s2_mosaic/intersects'
    inputBinding:
      prefix: --intersects
    type:
    - 'null'
    - string
  - id: '#s2_mosaic/month_json'
    inputBinding:
      prefix: --month-json
    type: File
  outputs:
  - id: '#s2_mosaic/best_pixel'
    outputBinding:
      glob: '*.tif'
    type: File
  requirements:
  - class: DockerRequirement
    dockerPull: ghcr.io/eo-datahub/user-workflows/s2_mosaic:main
  - class: InlineJavascriptRequirement
  doc: "None\n"
  baseCommand:
  - python
  - /app/app.py
- class: CommandLineTool
  id: '#s2_rm_cloud'
  inputs:
  - id: '#s2_rm_cloud/item_url'
    inputBinding:
      prefix: --item-url
    type:
    - 'null'
    - string
  outputs:
  - id: '#s2_rm_cloud/cloud_masked'
    outputBinding:
      glob: '*.tif'
    type: File
  requirements:
  - class: DockerRequirement
    dockerPull: ghcr.io/eo-datahub/user-workflows/s2_rm_cloud:main
  - class: InlineJavascriptRequirement
  doc: "None\n"
  baseCommand:
  - /usr/local/bin/_entrypoint.sh
  - python
  - /app/app.py
- class: CommandLineTool
  id: '#s2_search'
  inputs:
  - id: '#s2_search/catalog'
    inputBinding:
      prefix: --catalog
    type:
    - 'null'
    - string
  - id: '#s2_search/collection'
    inputBinding:
      prefix: --collection
    type:
    - 'null'
    - string
  - id: '#s2_search/end_datetime'
    inputBinding:
      prefix: --end-datetime
    type:
    - 'null'
    - string
  - id: '#s2_search/intersects'
    inputBinding:
      prefix: --intersects
    type:
    - 'null'
    - string
  - id: '#s2_search/start_datetime'
    inputBinding:
      prefix: --start-datetime
    type:
    - 'null'
    - string
  outputs:
  - id: '#s2_search/months'
    outputBinding:
      glob: month_*.json
    type:
      items: File
      type: array
  - id: '#s2_search/urls'
    outputBinding:
      glob: urls.txt
      loadContents: true
      outputEval: $(self[0].contents.split('\n'))
    type:
      items: string
      type: array
  requirements:
  - class: DockerRequirement
    dockerPull: ghcr.io/eo-datahub/user-workflows/s2_search:main
  - class: InlineJavascriptRequirement
  doc: "None\n"
  baseCommand:
  - python
  - /app/app.py
- class: Workflow
  id: '#cloud-free-best-pixel'
  inputs:
  - id: '#cloud-free-best-pixel/catalog'
    label: Catalog path
    doc: Full catalog path
    default: supported-datasets/ceda-stac-catalogue
    type: string
  - id: '#cloud-free-best-pixel/collection'
    label: collection id
    doc: collection id
    default: sentinel2_ard
    type: string
  - id: '#cloud-free-best-pixel/intersects'
    label: Intersects
    doc: "a GeoJSON-like json string, which provides a \"type\" member describing
      the type of the geometry and \"coordinates\"  member providing a list of coordinates.
      Will search for images intersecting this geometry.\n"
    default: "{\n  \"type\": \"Polygon\",\n  \"coordinates\": [\n    [\n      [0.08905898091569497,
      52.69722175598818],\n      [0.08905898091569497, 52.15527412683906],\n     \
      \ [0.9565339502005088, 52.15527412683906],\n      [0.9565339502005088, 52.69722175598818],\n\
      \      [0.08905898091569497, 52.69722175598818]\n    ]\n  ]\n}\n"
    type: string
  - id: '#cloud-free-best-pixel/start_datetime'
    label: Start datetime
    doc: Start datetime
    default: '2023-04-01'
    type: string
  - id: '#cloud-free-best-pixel/end_datetime'
    label: End datetime
    doc: End datetime
    default: '2023-06-30'
    type: string
  outputs:
  - id: '#cloud-free-best-pixel/stac_output'
    outputSource:
    - '#cloud-free-best-pixel/s2_make_stac/stac_catalog'
    type: Directory
  requirements:
  - class: ScatterFeatureRequirement
  label: Cloud free best pixel
  doc: Generate cloud free best pixel mosaic on a per month basis
  steps:
  - id: '#cloud-free-best-pixel/s2_search'
    in:
    - id: '#cloud-free-best-pixel/s2_search/catalog'
      source: '#cloud-free-best-pixel/catalog'
    - id: '#cloud-free-best-pixel/s2_search/collection'
      source: '#cloud-free-best-pixel/collection'
    - id: '#cloud-free-best-pixel/s2_search/intersects'
      source: '#cloud-free-best-pixel/intersects'
    - id: '#cloud-free-best-pixel/s2_search/start_datetime'
      source: '#cloud-free-best-pixel/start_datetime'
    - id: '#cloud-free-best-pixel/s2_search/end_datetime'
      source: '#cloud-free-best-pixel/end_datetime'
    out:
    - id: '#cloud-free-best-pixel/s2_search/urls'
    - id: '#cloud-free-best-pixel/s2_search/months'
    run: '#s2_search'
  - id: '#cloud-free-best-pixel/s2_rm_cloud'
    in:
    - id: '#cloud-free-best-pixel/s2_rm_cloud/item_url'
      source: '#cloud-free-best-pixel/s2_search/urls'
    out:
    - id: '#cloud-free-best-pixel/s2_rm_cloud/cloud_masked'
    run: '#s2_rm_cloud'
    scatter:
    - '#cloud-free-best-pixel/s2_rm_cloud/item_url'
    scatterMethod: dotproduct
  - id: '#cloud-free-best-pixel/s2_mosaic'
    in:
    - id: '#cloud-free-best-pixel/s2_mosaic/intersects'
      source: '#cloud-free-best-pixel/intersects'
    - id: '#cloud-free-best-pixel/s2_mosaic/month_json'
      source: '#cloud-free-best-pixel/s2_search/months'
    - id: '#cloud-free-best-pixel/s2_mosaic/all_images'
      source: '#cloud-free-best-pixel/s2_rm_cloud/cloud_masked'
    out:
    - id: '#cloud-free-best-pixel/s2_mosaic/best_pixel'
    run: '#s2_mosaic'
    scatter:
    - '#cloud-free-best-pixel/s2_mosaic/month_json'
    scatterMethod: dotproduct
  - id: '#cloud-free-best-pixel/s2_make_stac'
    in:
    - id: '#cloud-free-best-pixel/s2_make_stac/geometry'
      source: '#cloud-free-best-pixel/intersects'
    - id: '#cloud-free-best-pixel/s2_make_stac/files'
      source: '#cloud-free-best-pixel/s2_mosaic/best_pixel'
    out:
    - id: '#cloud-free-best-pixel/s2_make_stac/stac_catalog'
    run: '#s2_make_stac'
cwlVersion: v1.0
