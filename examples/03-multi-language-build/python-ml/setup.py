from setuptools import setup, find_packages

setup(
    name="python-ml",
    version="1.0.0",
    description="Python ML component for multi-language application",
    author="Multi-Language Build Example",
    packages=find_packages(),  # Now finds ml_analysis package
    install_requires=[
        "requests>=2.31.0",
        "numpy>=1.24.0", 
        "pandas>=2.0.0",
        "matplotlib>=3.7.0",
        "scikit-learn>=1.3.0",
    ],
    python_requires=">=3.8",
    py_modules=['analyze'],  # Include the analyze.py script
    entry_points={
        "console_scripts": [
            "ml-analyze=analyze:main",
        ],
    },
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
        "Topic :: Scientific/Engineering :: Artificial Intelligence",
    ],
)