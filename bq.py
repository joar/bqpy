#!/bin/python
import csv
import json
import sys
from typing import IO

import click
import tqdm
from google.cloud import bigquery
from google.cloud.bigquery.table import RowIterator, Row


@click.group()
def cli():
    """
    BigQuery JSONL reader
    """
    pass


def get_bq_results(query):
    bq = bigquery.Client()
    return bq.query(query).result()  # type: RowIterator


def parse_query_argument(ctx, param, value):
    # type: (click.Context, click.Parameter, str) -> str
    if value.startswith("@"):
        filename = value[1:]
        try:
            return open(filename, "r").read()
        except Exception as exc:
            raise click.BadParameter(
                "Could not read file {filename!r}".format(filename=filename)
            ) from exc

    return value


@cli.command()
@click.help_option()
@click.argument(
    "query",
    callback=parse_query_argument,
)
def query(query):
    """
    QUERY
        BigQuery standard SQL query.
        The 'payload' column will be sent as the Pub/Sub payload
    """

    with tqdm.tqdm(
        unit="row",
        desc="Reading rows",
    ) as progress:
        row_iter = get_bq_results(query)

        for row in row_iter:
            if progress.total is None and row_iter.total_rows is not None:
                progress.total = row_iter.total_rows
            print(json.dumps(dict(row)))
            progress.update()

if __name__ == "__main__":
    cli()
