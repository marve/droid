#!/bin/bash
set -e
pushd wordsearcher-main
pip3 install --upgrade pip && pip3 install --user --requirement requirements.txt
export FLASK_APP=src/webapp.py
python -m flask --app src/webapp.py run --host=0.0.0.0
popd