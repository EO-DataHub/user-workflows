import json
from itertools import combinations

import click
import geopandas as gpd
from eodag import EODataAccessGateway
from shapely.geometry import shape


@click.command()
@click.option("--start-datetime")
@click.option("--end-datetime")
@click.option("--intersects")
def main(start_datetime, end_datetime, intersects):
    dag = EODataAccessGateway()
    dag.set_preferred_provider("cop_dataspace")

    search_criteria = {
        "productType": "S1_SAR_SLC",
        "start": start_datetime,
        "end": end_datetime,
        "geom": shape(json.loads(intersects)).bounds,
    }

    results, _ = dag.search(**search_criteria)

    # Find overlaps
    data = []
    for item in results:
        id = item.properties["id"]
        geom = shape(item.geometry)
        data.append({"id": id, "geometry": geom})

    gdf = gpd.GeoDataFrame(data, crs="EPSG:4326")  # Assuming WGS84

    # 98% overlap
    threshold = 0.98

    overlaps = []
    for (idx1, row1), (idx2, row2) in combinations(gdf.iterrows(), 2):
        intersection = row1["geometry"].intersection(row2["geometry"])
        if not intersection.is_empty:
            # Calculate overlap ratio as the area of intersection divided by the area
            # of the smaller polygon
            overlap_ratio = intersection.area / min(
                row1["geometry"].area, row2["geometry"].area
            )
            if overlap_ratio >= threshold:
                overlaps.append((row1["id"], row2["id"], overlap_ratio))

    overlap_ids = [entry[:-1] for entry in overlaps]

    # Save each pair to a separate file, as a geojson
    for idx, pair in enumerate(overlap_ids):
        with open(f"pair_{idx}.geojson", "w") as f:
            to_dl = [it.as_dict() for it in results if it.properties["id"] in pair]
            json.dump(to_dl, f)
        break


if __name__ == "__main__":
    main()
