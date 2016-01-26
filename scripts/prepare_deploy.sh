#!/bin/bash
cp LICENSE doc/_build/html/
mkdir -p deploy/branches/"${CI_BRANCH}" deploy/script_queue
cp -r dist/* htmlcov/ doc/_build/html/ deploy/branches/"${CI_BRANCH}"/
