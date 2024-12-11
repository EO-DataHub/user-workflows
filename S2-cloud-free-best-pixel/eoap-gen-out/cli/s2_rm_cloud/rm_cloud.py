import threading
import click
import pyeodh
import rioxarray
import rasterio
import xarray
from pyeodh.resource_catalog import Item


@click.command()
@click.option("--item-url")
def main(item_url):
    print(f"item_url: {item_url}")

    print("Fetching from stac...")
    item = Item.from_href(pyeodh.Client(), item_url)

    cloud_href = item.assets["cloud"].href
    valid_href = item.assets["valid_pixels"].href
    cog_href = item.assets["cog"].href
    print(f"cloud_href: {cloud_href}")
    print(f"valid_href: {valid_href}")
    print(f"cog_href: {cog_href}")

    print("open_rasterio")
    valid = rioxarray.open_rasterio(valid_href, chunks=True)
    cloud = rioxarray.open_rasterio(cloud_href, chunks=True)
    cog = rioxarray.open_rasterio(cog_href, chunks=True)
    print("valid+cloud")
    result = valid + cloud
    # Set values greater than 1 to 0, others remain as 1
    print("xarray where")
    result = xarray.where(result > 1, 0, 1)
    # Multiply cog.tif by the result
    # We need to expand the result to match the shape of cog
    print("cog * result")
    fin = cog * result.squeeze("band").expand_dims(band=cog.band)

    print("to_raster")
    with rasterio.Env(CHECK_DISK_FREE_SPACE="NO"):
        fin.rio.to_raster(
            raster_path=f"{item.id}.tif", tiled=True, lock=threading.Lock()
        )


if __name__ == "__main__":
    main()
