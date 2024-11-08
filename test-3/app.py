import click
import pyeodh
import xarray as xr
import rioxarray
import os
from pathlib import Path
import requests
import datetime
import os
import shutil
from pathlib import Path
import click
import pystac
import pystac.utils


@click.command()
def main():
    # pyeodh.set_log_level(10)
    rc = pyeodh.Client().get_catalog_service()

    thetford_pnt = {
        "coordinates": [
            [
                [0.08905898091569497, 52.69722175598818],
                [0.08905898091569497, 52.15527412683906],
                [0.9565339502005088, 52.15527412683906],
                [0.9565339502005088, 52.69722175598818],
                [0.08905898091569497, 52.69722175598818],
            ]
        ],
        "type": "Polygon",
    }

    items = rc.search(
        collections=["sentinel2_ard"],
        catalog_paths=["supported-datasets/ceda-stac-fastapi"],
        intersects=thetford_pnt,
        query=[
            "start_datetime>=2023-04-01",
            "end_datetime<=2023-06-30",
        ],
        limit=10,
    )

    for item in items.get_limited()[0:1]:
        cloud_href = item.assets["cloud"].href
        valid_href = item.assets["valid_pixels"].href
        cog_href = item.assets["cog"].href
        item
        print(item.id, cloud_href, valid_href, cog_href, sep="\n")
        valid = rioxarray.open_rasterio(valid_href)
        cloud = rioxarray.open_rasterio(cloud_href)

        # Check if cog file exists locally, if not download it
        cog_filename = f"data/{Path(cog_href).name}"
        if not os.path.isfile(cog_filename):
            with requests.get(cog_href, stream=True) as r:
                r.raise_for_status()
                with open(cog_filename, "wb") as f:
                    for chunk in r.iter_content(chunk_size=8192):
                        f.write(chunk)

        cog = rioxarray.open_rasterio(cog_filename)
        print("==" * 10)
        print("success")
        break

    result = valid + cloud

    # Set values greater than 1 to 0, others remain as 1
    result = xr.where(result > 1, 0, 1)

    # Multiply cog.tif by the result
    # We need to expand the result to match the shape of cog
    fin = cog * result.squeeze("band").expand_dims(band=cog.band)
    fin.rio.to_raster("data/result.tif", driver="COG")
    make_stac(["data/result.tif"])


def make_stac(files):
    catalog = pystac.Catalog(id="catalog", description="Root catalog")
    for path in files:
        name = Path(path).stem
        os.mkdir(name)
        f_copy = shutil.copy(path, f"{name}/")
        item = pystac.Item(
            id=name,
            geometry={
                "type": "Polygon",
                "coordinates": [
                    [[-180, -90], [-180, 90], [180, 90], [180, -90], [-180, -90]]
                ],
            },
            bbox=None,
            datetime=datetime.datetime.now(),
            properties={
                "created": pystac.utils.datetime_to_str(datetime.datetime.now()),
                "updated": pystac.utils.datetime_to_str(datetime.datetime.now()),
            },
            extra_fields={"bbox": [-180, -90, 180, 90]},
        )
        item.add_asset(
            name,
            pystac.Asset(
                href=os.path.basename(f_copy),
                media_type=pystac.MediaType.GEOTIFF,
                roles=["data"],
                extra_fields={"file:size": os.path.getsize(f_copy)},
            ),
        )
        catalog.add_item(item)
    catalog.normalize_and_save(
        root_href="./", catalog_type=pystac.CatalogType.SELF_CONTAINED
    )


if __name__ == "__main__":
    main()
