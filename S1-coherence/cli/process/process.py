import glob
import json
import os
import shutil
import logging
import sys

import click
import shapely
from eo_tools.S1.process import process_insar
from eodag import EODataAccessGateway
from eodag.api.product._product import EOProduct

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@click.command()
@click.option("--pair")
@click.option("--intersects")
@click.option("--username")
@click.option("--password")
def main(pair, intersects, username, password):
    sys.exit(1)
    os.environ["EODAG__COP_DATASPACE__AUTH__CREDENTIALS__USERNAME"] = username
    os.environ["EODAG__COP_DATASPACE__AUTH__CREDENTIALS__PASSWORD"] = password

    dag = EODataAccessGateway()
    dag.set_preferred_provider("cop_dataspace")
    logger.info("setup dag")

    shp = shapely.geometry.shape(json.loads(intersects))

    with open(pair, "r") as f:
        pair = json.load(f)

    logger.info(f"pair: {pair}")
    products = [EOProduct.from_geojson(item) for item in pair]
    downloaded_0 = dag.download(products[0], outputs_prefix="data", extract=False)
    downloaded_1 = dag.download(products[1], outputs_prefix="data", extract=False)

    logger.info("processing...")
    process_insar(
        prm_path=downloaded_0,
        sec_path=downloaded_1,
        output_dir="data/results",
        aoi_name=None,
        shp=shp,
        pol="vv",
        subswaths=["IW1", "IW2", "IW3"],
        write_coherence=True,
        write_interferogram=False,
        write_primary_amplitude=False,
        write_secondary_amplitude=False,
        apply_fast_esd=True,
        dem_upsampling=1.8,
        dem_force_download=False,
        dem_buffer_arc_sec=40,
        boxcar_coherence=[3, 3],
        filter_ifg=True,
        multilook=[1, 4],
        warp_kernel="bicubic",
        clip_to_shape=True,
    )
    logger.info("processing done")

    logger.info("moving coherence file")
    coh_files = glob.glob("data/results/*/coh_vv.tif")
    if coh_files:
        shutil.move(coh_files[0], "data/results/coh_vv.tif")


if __name__ == "__main__":
    main()
