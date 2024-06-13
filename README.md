# Mu Python template

Template for [mu.semte.ch](http://mu.semte.ch)-microservices written in Python3. Based on the [FastAPI](https://fastapi.tiangolo.com/)-framework.

## Motivation Behind the Fork
The primary motivation for this fork is the heavy nature of the ML packages (mainly PyTorch and TensorFlow). Reusing this image across different systems can be highly efficient. Additionally, transitioning to FastAPI allows for better handling of concurrency and asynchronous processing of requests, which is crucial for performance and scalability.

## Quickstart

Create a `Dockerfile` which extends the `svercoutere/mu-python-ml`-image and set a maintainer.
```docker
FROM svercoutere/mu-python-ml:0.1.0
LABEL maintainer="user_name@mail_provider.com"
```

Create a `web.py` entrypoint-file. (naming of the entrypoint can be configured through `APP_ENTRYPOINT`)
```python
@app.get("/hello")
async def hello():
    return {"message": "Hello from mu-python-ml!"}
```

Build the Docker-image for your service
```sh
docker build -t my-python-service .
```

Run your service
```sh
docker run -p 8080:80
```

You now should be able to access your service's endpoint
```sh
curl localhost:8080/hello
```

## Developing a microservice using the template

### Dependencies

If your service needs external libraries other than the ones already provided by the template (FastAPI, SPARQLWrapper, rdflib, Numpy, Pandas, Scipy, PyTorch, Tensorflow, Transformers, HuggingFace ), you can specify those in a [`requirements.txt`](https://pip.pypa.io/en/stable/reference/requirements-file-format/)-file. The template will take care of installing them when you build your Docker image and when you boot the template in development mode for the first time.

### Development mode

By leveraging Dockers' [bind-mount](https://docs.docker.com/storage/bind-mounts/), you can mount your application code into an existing service image. This spares you from building a new image to test each change. Just mount your services' folder to the containers' `/app`. On top of that, you can configure the environment variable `MODE` to `development`. That enables live-reloading of the server, so it immediately updates when you save a file.  

example docker-compose parameters:
```yml
    environment:
      MODE: "development"
    volumes:
      - /home/my/code/my-python-service:/app
```


#### `query`

```python
def query(the_query: str, request: Request)
```

> Execute the given SPARQL query (select/ask/construct) on the triplestore and returns the results in the given return Format (JSON by default).

<a id="helpers.update"></a>

#### `update`

```python
def update(the_query: str, request: Request)
```

> Execute the given update SPARQL query on the triplestore. If the given query is not an update query, nothing happens.

<a id="helpers.update_modified"></a>

#### `update_modified`

```python
def update_modified(subject, request: Request, modified=datetime.datetime.now()
```

> (DEPRECATED) Executes a SPARQL query to update the modification date of the given subject URI (string).
> The default date is now.

<a id="escape_helpers.sparql_escape_string"></a>


### Writing SPARQL Queries

```py
from string import Template
from helpers import query
from escape_helpers import sparql_escape_uri

@app.get("/fetch_documents")
async def fetch_documents(request: Request):
    the_query = """

    SELECT ?document
    WHERE {
        ?document a <http://schema.org/Document> .
    }

    """
    print(the_query)
    results = query(the_query, request)
    
    return results
```

## Deployment

Example snippet for adding a service to a docker-compose stack:
```yml
my-python:
  image: my-python-service
  environment:
    LOG_LEVEL: "debug"
```

### Environment variables

- `LOG_LEVEL` takes the same options as defined in the Python [logging](https://docs.python.org/3/library/logging.html#logging-levels) module.

- `MODE` to specify the deployment mode. Can be `development` as well as `production`. Defaults to `production`

- `MU_SPARQL_ENDPOINT` is used to configure the SPARQL endpoint.

  - By default this is set to `http://database:8890/sparql`. In that case the triple store used in the backend should be linked to the microservice container as `database`.


- `MU_APPLICATION_GRAPH` specifies the graph in the triple store the microservice will work in.

  - By default this is set to `http://mu.semte.ch/application`. The graph name can be used in the service via `settings.graph`.


- `MU_SPARQL_TIMEOUT` is used to configure the timeout (in seconds) for SPARQL queries.


Since this template is based on the meinheld-gunicorn-docker image, all possible environment config for that image is also available for the template. See [meinheld-gunicorn-docker#environment-variables](https://github.com/tiangolo/meinheld-gunicorn-docker#environment-variables) for more info. The template configures `WEB_CONCURRENCY` in particular to `1` by default.

### Production

For hosting the app in a production setting, the template depends on [meinheld-gunicorn-docker](https://github.com/tiangolo/meinheld-gunicorn-docker). All [environment variables](https://github.com/tiangolo/meinheld-gunicorn-docker#environment-variables) used by meinheld-gunicorn can be used to configure your service as well.

## Other

### Reassigning `app`
In regular FastAPI applications (e.g. those not run within this template) you are required to define `app` by using `app = FastAPI(__name__)` or similar. This does *not* need to be done in your web.py, as this is handled by the microservice architecture/template. Redefining this may cause `The requested URL was not found on the server. If you entered the URL manually please check your spelling and try again.` to be thrown on your routes, which can be luckily be fixed by simply removing the previously mentioned `app = ...` line.

### readme.py
To simplify documenting the helper functions, `README.py` can be used to import & render the docstrings into README.md.
Usage:
```python3
python3 -m pip install pydoc-markdown
python3 README.py
```
You can customise the output through the API configuration! See [README.py](README.py) && the [pydoc-markdown docs](https://niklasrosenstein.github.io/pydoc-markdown/).
