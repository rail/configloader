#!/usr/bin/env python

import click
import json
import jsone
import os
import yaml


@click.command()
@click.argument('input', type=click.File('r'))
@click.argument('output', type=click.File('w'))
def main(input, output):
    '''Convert JSON/YAML templates into using json-e.

       Accepts JSON or YAML format and outputs using JSON because it is YAML compatible.
    '''
    config_template = yaml.safe_load(input)
    config = jsone.render(config_template, os.environ)
    json.dump(config, output)
