#!/bin/bash -xeu
if [[ "$CI_BRANCH" =~ ^v[0-9]+.[0-9]?* ]]; then
    eval export ${1^^}_RELEASE_VERSION=\$CI_BRANCH
    echo ${CI_BRANCH} | tail -c +2 > __conda_version__.txt
fi
python2 setup.py sdist
python3 -m pip install --force-reinstall --upgrade dist/*.tar.gz
(cd /; python3 -m pytest --pyargs $1)
python2 -m pip install --force-reinstall --upgrade dist/*.tar.gz
(cd /; python2 -m pytest --pyargs $1)
PYTHONPATH=$(pwd) ./scripts/run_tests.sh --cov $1 --cov-report html
./scripts/coverage_badge.py htmlcov/ htmlcov/coverage.svg
! grep "DO-NOT-MERGE!" -R . --exclude ci.sh
