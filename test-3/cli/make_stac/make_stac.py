import datetime
import json
import os
import shutil
from pathlib import Path

import click
import pystac
import pystac.utils
import shapely


@click.command()
@click.option("--geometry")
@click.argument("files", nargs=-1)
def main(files, geometry):
    geometry = json.loads(geometry)
    bbox = shapely.geometry.shape(geometry).bounds

    catalog = pystac.Catalog(id="catalog", description="Root catalog")

    for path in files:
        name = Path(path).stem
        os.mkdir(name)
        f_copy = shutil.copy(path, f"{name}/")
        item = pystac.Item(
            id=name,
            geometry=geometry,
            bbox=bbox,
            datetime=datetime.datetime.now(),
            properties={
                "created": pystac.utils.datetime_to_str(datetime.datetime.now()),
                "updated": pystac.utils.datetime_to_str(datetime.datetime.now()),
            },
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
