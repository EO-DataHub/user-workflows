import json
import subprocess

import click


@click.command()
@click.argument("--intersects")
@click.argument("images", nargs=-1)
def main(intersects, images):

    output_file = "mosaic.tif"
    input_args = [f"-i {img}" for img in images]
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
