class: Workflow
id: s1-coherence
inputs:
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
          [0.08905898091569497, 52.69722175598818]
        ]
      ]
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
  - s1_make_stac/stac_catalog
  type: Directory
requirements:
- class: ScatterFeatureRequirement
label: S1 coherence
doc: Generate Sentinel 1 image pair coherence
cwlVersion: v1.0
steps:
- id: s1_search
  in:
  - id: intersects
    source: s1-coherence/intersects
  - id: start_datetime
    source: s1-coherence/start_datetime
  - id: end_datetime
    source: s1-coherence/end_datetime
  out:
  - id: pairs
  run: 
    /home/figi/software/work/eodh/user-workflows/S1-coherence/eoap-gen-out/cli/s1_search/s1_search.cwl
- id: s1_process
  in:
  - id: pair
    source: s1_search/pairs
  - id: intersects
    source: s1-coherence/intersects
  out:
  - id: coherence
  run: 
    /home/figi/software/work/eodh/user-workflows/S1-coherence/eoap-gen-out/cli/s1_process/s1_process.cwl
  scatter:
  - pair
  scatterMethod: dotproduct
- id: s1_make_stac
  in:
  - id: intersects
    source: s1-coherence/intersects
  - id: files
    source: s1_process/coherence
  out:
  - id: stac_catalog
  run: 
    /home/figi/software/work/eodh/user-workflows/S1-coherence/eoap-gen-out/cli/s1_make_stac/s1_make_stac.cwl
