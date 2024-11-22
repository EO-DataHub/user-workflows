import json
from pathlib import Path
import subprocess

import click


@click.command()
@click.argument("--intersects")
@click.argument("--month-json")
@click.argument("all_images", nargs=-1)
def main(intersects, month_json, all_images):
    with open(month_json, "r") as f:
        month_urls = json.load(f)

    # Get image ids relevant to the month
    month_ids = [item["id"] for item in month_urls]

    timestamp = Path(month_json).stem.split("_")[1]

    output_file = f"mosaic_{timestamp}.tif"

    # Get paths to all images relevant to the month
    month_images = [img for img in all_images if Path(img).stem in month_ids]
    input_args = [f"-i {img}" for img in month_images]
    intersects = json.loads(intersects)

    with open("aoi.geojson", "w") as f:
        json.dump(intersects, f)

    subprocess.run(
        [
            "pkcomposite",
            *input_args,
            "-cr",
            "mean",
            "-o",
            output_file,
            "-e",
            "aoi.geojson",
        ]
    )


if __name__ == "__main__":
    main()
