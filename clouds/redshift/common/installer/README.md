# CARTO Analytics Toolbox installer

A Python script to install the CARTO Analytics Toolbox in Redshift.

## Install

Create a virtual environment (optional):

```
python -m venv env
source env/bin/activate
```

Install the tool:

```
pip install git+https://github.com/cartodb/analytics-toolbox-core.git@cat-installer
```

## Usage

Create a `config.yml` file. This file must contain the information of the Redshift connection and LDS.

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

Download the installation package and run the script:

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
