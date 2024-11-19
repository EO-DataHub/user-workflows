import json
import click
import pyeodh


@click.command()
@click.option("--catalog")
@click.option("--collection")
@click.option("--intersects")
@click.option("--start-datetime")
@click.option("--end-datetime")
def main(catalog, collection, intersects, start_datetime, end_datetime):
    if not catalog or not collection or not intersects:
        return

    intersects = json.loads(intersects)
    rc = pyeodh.Client().get_catalog_service()

    items = rc.search(
        collections=[collection],
        catalog_paths=[catalog],
        intersects=intersects,
        query=[
            f"start_datetime>={start_datetime}",
            f"end_datetime<={end_datetime}",
        ],
        limit=1,
    )
    urls = []
    for item in items[0:1]:
        urls.append(item._pystac_object.self_href)

    with open("urls.txt", "w") as f:
        print(*urls, file=f, sep="\n", end="")


if __name__ == "__main__":
    main()
