import click
import pyeodh
import rioxarray
import xarray
from pyeodh.resource_catalog import Item


@click.command()
@click.option("--item-url")
def main(item_url):
    if not item_url:
        return

    item = Item.from_href(pyeodh.Client(), item_url)

    cloud_href = item.assets["cloud"].href
    valid_href = item.assets["valid_pixels"].href
    cog_href = item.assets["cog"].href

    valid = rioxarray.open_rasterio(valid_href)
    cloud = rioxarray.open_rasterio(cloud_href)
    cog = rioxarray.open_rasterio(cog_href)

    result = valid + cloud
    # Set values greater than 1 to 0, others remain as 1
    result = xarray.where(result > 1, 0, 1)

    # Multiply cog.tif by the result
    # We need to expand the result to match the shape of cog
    fin = cog * result.squeeze("band").expand_dims(band=cog.band)

    fin.rio.to_raster(raster_path=f"{item.id}.tif", driver="COG")


if __name__ == "__main__":
    main()
