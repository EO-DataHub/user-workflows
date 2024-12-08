import json
import click
import pyeodh
from datetime import date, timedelta


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
    months = get_months(start_datetime, end_datetime)

    for item in items[:1]:
        urls.append(item._pystac_object.self_href)
        ym = item.datetime.strftime("%Y-%m")
        months[ym].append(
            {
                "id": item.id,
                "href": item._pystac_object.self_href,
            }
        )

    with open("urls.txt", "w") as f:
        print(*urls, file=f, sep="\n", end="")

    for month in months:
        if len(months[month]) == 0:
            continue
        with open(f"month_{month}.json", "w") as f:
            json.dump(months[month], f)


def get_months(start_str, end_str):
    start = date.fromisoformat(start_str)
    end = date.fromisoformat(end_str)

    months = {}

    for d in range((end - start).days):
        ym = (start + timedelta(days=d)).strftime("%Y-%m")
        if ym not in months:
            months[ym] = []

    return months


if __name__ == "__main__":
    main()
