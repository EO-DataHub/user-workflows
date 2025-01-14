import glob
import json
import os
import shutil

import click
import shapely
from eo_tools.S1.process import process_insar
from eodag import EODataAccessGateway
from eodag.api.product._product import EOProduct


@click.command()
@click.option("--pair")
@click.option("--intersects")
@click.option("--username")
@click.option("--password")
def main(pair, intersects, username, password):
    os.environ["EODAG__COP_DATASPACE__AUTH__CREDENTIALS__USERNAME"] = username
    os.environ["EODAG__COP_DATASPACE__AUTH__CREDENTIALS__PASSWORD"] = password

    dag = EODataAccessGateway()
    dag.set_preferred_provider("cop_dataspace")
    print("setup dag")

    shp = shapely.geometry.shape(json.loads(intersects))

    with open(pair, "r") as f:
        pair = json.load(f)

    print("pair:")
    print(pair)

    products = [EOProduct.from_geojson(item) for item in pair]
    downloaded_0 = dag.download(products[0], outputs_prefix="data", extract=False)
    downloaded_1 = dag.download(products[1], outputs_prefix="data", extract=False)

    print("processing...")
    process_insar(
        dir_prm=downloaded_0,
        dir_sec=downloaded_1,
        outputs_prefix="data/results",
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
    print("processing done")
    for i in os.walk("data"):
        print(i)

    print("moving coherence file")
    coh_files = glob.glob("data/results/*/coh_vv.tif")
    if coh_files:
        shutil.move(coh_files[0], "data/results/coh_vv.tif")


if __name__ == "__main__":
    main()
