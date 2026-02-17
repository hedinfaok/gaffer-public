# Traditional Makefile approach - we'll replace this with graph.json
.PHONY: install build test lint format clean

install:
	pip install -r requirements.txt

build:
	python setup.py build

test:
	pytest tests/ -v --cov=ml_models

lint:
	pylint ml_models/
	flake8 ml_models/

format:
	black ml_models/ tests/
	isort ml_models/ tests/

clean:
	rm -rf build/ dist/ *.egg-info .pytest_cache .coverage htmlcov/
	find . -type d -name __pycache__ -exec rm -rf {} +
