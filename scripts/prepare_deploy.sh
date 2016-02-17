#!/bin/bash
cp LICENSE doc/_build/html/
mkdir -p deploy/public_html/branches/"${CI_BRANCH}" deploy/script_queue
cp -r dist/* htmlcov/ doc/_build/html/ deploy/public_html/branches/"${CI_BRANCH}"/
