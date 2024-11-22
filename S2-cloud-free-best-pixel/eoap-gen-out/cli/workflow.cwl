class: Workflow
id: cloud-free-best-pixel
inputs:
- id: catalog
  label: Catalog path
  doc: Full catalog path
  default: supported-datasets/ceda-stac-catalogue
  type: string
- id: collection
  label: collection id
  doc: collection id
  default: sentinel2_ard
  type: string
- id: intersects
  label: Intersects
  doc: >
    a GeoJSON-like json string, which provides a "type" member describing the type
    of the geometry and "coordinates"  member providing a list of coordinates. Will
    search for images intersecting this geometry.
  default: >
    {
      "type": "Polygon",
      "coordinates": [
        [
          [0.08905898091569497, 52.69722175598818],
          [0.08905898091569497, 52.15527412683906],
          [0.9565339502005088, 52.15527412683906],
          [0.9565339502005088, 52.69722175598818],
          [0.08905898091569497, 52.69722175598818],
        ]
      ],
    }
  type: string
- id: start_datetime
  label: Start datetime
  doc: Start datetime
  default: '2023-04-01'
  type: string
- id: end_datetime
  label: End datetime
  doc: End datetime
  default: '2023-06-30'
  type: string
outputs:
- id: stac_output
  outputSource:
  - make_stac/stac_catalog
  type: Directory
requirements:
- class: ScatterFeatureRequirement
label: Cloud free best pixel
doc: Generate cloud free best pixel mosaic on a per month basis
cwlVersion: v1.0
steps:
- id: search
  in:
  - id: catalog
    source: cloud-free-best-pixel/catalog
  - id: collection
    source: cloud-free-best-pixel/collection
  - id: intersects
    source: cloud-free-best-pixel/intersects
  - id: start_datetime
    source: cloud-free-best-pixel/start_datetime
  - id: end_datetime
    source: cloud-free-best-pixel/end_datetime
  out:
  - id: urls
  - id: months
  run: 
    /home/figi/software/work/eodh/user-workflows/S2-cloud-free-best-pixel/eoap-gen-out/cli/search/search.cwl
- id: rm_cloud
  in:
  - id: item_url
    source: search/urls
  out:
  - id: cloud_masked
  run: 
    /home/figi/software/work/eodh/user-workflows/S2-cloud-free-best-pixel/eoap-gen-out/cli/rm_cloud/rm_cloud.cwl
  scatter:
  - item_url
  scatterMethod: dotproduct
- id: mosaic
  in:
  - id: intersects
    source: cloud-free-best-pixel/intersects
  - id: month_json
    source: search/months
  - id: all_images
    source: rm_cloud/cloud_masked
  out:
  - id: best_pixel
  run: 
    /home/figi/software/work/eodh/user-workflows/S2-cloud-free-best-pixel/eoap-gen-out/cli/mosaic/mosaic.cwl
  scatter:
  - month_json
  scatterMethod: dotproduct
- id: make_stac
  in:
  - id: geometry
    source: cloud-free-best-pixel/intersects
  - id: files
    source: mosaic/best_pixel
  out:
  - id: stac_catalog
  run: 
    /home/figi/software/work/eodh/user-workflows/S2-cloud-free-best-pixel/eoap-gen-out/cli/make_stac/make_stac.cwl
