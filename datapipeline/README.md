# Use below commands to configure the pipeline

# Cloudformation

Run the cloudformation template to create roles and s3 bucket

# Pipeline

## First create the pipeline

aws datapipeline create-pipeline --name shell_command_aarti_testing --unique-id shell_command_aarti_testing

## Second configure the pipeline you just created

aws datapipeline put-pipeline-definition --pipeline-definition file://data-pipeline.json --parameter-values myS3StagingPath=testpipelineaarti --pipeline-id shell_command_aarti_testing

## Third activate the pipeline

aws datapipeline activate-pipeline --pipeline-id shell_command_aarti_testing

## Check status of pipeline

aws datapipeline list-runs --pipeline-id shell_command_aarti_testing