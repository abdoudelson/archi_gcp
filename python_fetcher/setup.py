from setuptools import setup, find_packages

setup(
    name='crypto_fetcher',
    version='0.1.0',
    packages=find_packages(),
    install_requires=[
        'requests>=2.28.1',
        'google-cloud-storage>=2.5.0',
    ],
    entry_points={
        'console_scripts': [
            'crypto-fetcher=crypto_fetcher.fetch:fetch_top_10_cryptos'
        ],
    },
    python_requires='>=3.7',
)
