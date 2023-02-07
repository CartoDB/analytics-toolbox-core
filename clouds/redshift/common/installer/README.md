# CARTO Analytics Toolbox installer

A Python script to install the CARTO Analytics Toolbox in Redshift.

## Install

1. Install Python >= 3.7: https://www.python.org/downloads/

    Create a virtual environment (optional for Linux, macOS):

    ```
    python -m venv env
    source env/bin/activate
    ```

2. Install the tool:

    ```
    pip install -U pip
    pip install git+https://github.com/cartodb/analytics-toolbox-core.git@main#subdirectory=clouds/redshift/common/installer
    ```

> Note: if `python` does not point to Python 3, use `python3` instead.

## Usage

1. Create a `config.yml` file. This file must contain the information of the Redshift connection and LDS.

    ```yml
    connection:
      host: CLUSTER.ACCOUNT.REGION.redshift.amazonaws.com
      database: DATABASE
      user: USER
      password: PASSWORD
    lds:
      lambda: lds-function-europe-west1
      roles: arn:aws:iam::XXXXXXXXXXXX:role/CartoFunctionsRedshiftRole,arn:aws:iam::000955892807:role/CartoFunctionsRole
      api_base_url: https://gcp-europe-west1.api.carto.com
      token: eyJhbGciOiJ...
    ```

2. Download the installation package (zip file).

3. Run the script:

    ```
    cat-installer carto-analytics-toolbox-redshift-latest.zip
    ```

    ```
    Reading config file: config.yml
    Reading package file: carto-analytics-toolbox-redshift-latest.zip
    Installing libraries...
    100%|█████████████████████████████████████████████████████████████████| 8/8 [00:07<00:00,  1.03it/s]
    Installing modules...
    100%|█████████████████████████████████████████████████████████████| 244/244 [01:58<00:00,  2.06it/s]
    ```
