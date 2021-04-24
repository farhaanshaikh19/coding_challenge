# Coding Challenge App

A skeleton flask app to use for a coding challenge.

## Install:

- Developed for Python 3.6.10

### You can use the setup_venv.sh shell script to install the virtual environment (requires pyenv to be installed)
```
sh setup_venv.sh
```

### Or just pip install from the requirements file
``` 
pip install -r requirements.txt
```

## Running the code

### Spin up the service

```
# start up local server
python -m run 
```

### Making Requests

```
curl -i "http://127.0.0.1:5000/health-check"
```


## What'd I'd like to improve on...
