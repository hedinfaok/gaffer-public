from setuptools import setup, find_packages

setup(
    name="ml_models",
    version="1.0.0",
    description="Machine Learning Models for Prediction Service",
    packages=find_packages(),
    python_requires=">=3.8",
    install_requires=[
        "numpy>=1.24.0",
        "scikit-learn>=1.3.0",
        "pandas>=2.0.0",
        "joblib>=1.3.0",
    ],
)
