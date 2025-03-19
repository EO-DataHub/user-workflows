import glob
import json
import os
import shutil
import logging
import boto3
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
@click.option("--aws-access-key-id")
@click.option("--aws-secret-access-key")
@click.option("--aws-session-token")
def main(
    pair,
    intersects,
    username,
    password,
    aws_access_key_id,
    aws_secret_access_key,
    aws_session_token,
):
    try:
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

        s3 = boto3.client(
            "s3",
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            aws_session_token=aws_session_token,
        )

        bucket_name = "workspaces-eodhp-staging"
        workspace_name = "figi44"

        downloaded_products = []
        for product in products:
            product_id = product.properties["id"]
            file_name = f"{product_id}.zip"
            object_name = f"{workspace_name}/{product_id}"
            download_path = f"data/{file_name}"

            exists_in_s3 = False
            try:
                s3.head_object(Bucket=bucket_name, Key=object_name)
                exists_in_s3 = True
            except Exception:
                logger.info(f"File {object_name} not found")

            if exists_in_s3:
                logger.info(
                    f"File {object_name} already exists, downloading from s3..."
                )
                s3.download_file(bucket_name, object_name, download_path)
                logger.info(f"File {object_name} downloaded")
            else:
                logger.info(
                    f"File {object_name} does not exist in s3, downloading from sentinel hub..."
                )
                download_path = dag.download(product, output_dir="data", extract=False)
                logger.info(
                    f"File {download_path} downloaded from sentinel hub, uploading to s3..."
                )
                s3.upload_file(download_path, bucket_name, object_name)
                logger.info(f"File {object_name} uploaded to s3")
            downloaded_products.append(download_path)

        logger.info("processing...")
        process_insar(
            prm_path=downloaded_products[0],
            sec_path=downloaded_products[1],
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
    except Exception as e:
        logger.error(e)
        os.makedirs("data/results", exist_ok=True)
        os.mknod("data/results/coh_vv.tif")


if __name__ == "__main__":
    main()
