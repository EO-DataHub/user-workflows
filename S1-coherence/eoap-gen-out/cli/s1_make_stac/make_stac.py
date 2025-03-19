import datetime
import json
import os
import shutil
from pathlib import Path
import logging

import click
import pystac
import pystac.utils
import shapely

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@click.command()
@click.argument("files", nargs=-1)
@click.option("--intersects")
def main(files, intersects):
    logger.info(f"files: {files}")
    logger.info(f"intersects: {intersects}")

    geometry = json.loads(intersects)
    logger.info(f"geometry: {geometry}")

    bbox = shapely.geometry.shape(geometry).bounds
    logger.info(f"bbox: {bbox}")

    catalog = pystac.Catalog(id="catalog", description="S1 Coherence")

    for path in files:
        name = Path(path).stem
        logger.info(f"Copying: {name} from {path}")
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
