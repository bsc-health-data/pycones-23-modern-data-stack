## Step by step guide

### Architecture

- PostgreSQL
- Meltano
- dbt
- Apache Superset
- OpenMetadata

### PostgreSQL

``` 
docker run --name local_postgres -e POSTGRES_PASSWORD=<YOUR_PASS> -e POSTGRES_USER=postgres \ 
                                 -p 5433:5432 -v ${PWD}:/var/lib/postgresql/data -d postgres
``` 


### Meltano = Singer + dbt

Meltano is an open source ELT platform for data integration that facilitates:
  - the extraction of data from 3rd party SaaS services
  - the loading of data into data stores
  - the transformation of the data
