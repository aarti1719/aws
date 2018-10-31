# Use following command to run

aws datapipeline put-pipeline-definition --pipeline-id id \
--pipeline-definition file://data-pipeline.yaml \
--parameter-values-uri file://data-pipeline.json

## Please make sure to populate appropriate values in *data-pipeline.json*

