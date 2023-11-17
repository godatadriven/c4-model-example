workspace {
    model {
        user = person "MLE / DS" {
            tags "External"
        }

        platform = softwareSystem "GCP MLOps Platform" "Platform " {
            group "Exploration" {
                ml_workbench = container "ML workbench" {
                    user -> this "Logs into" "SSH"
                }
                container "Startup script" {
                    ml_workbench -> this "Executes on boot" "GCS"
                    tags "Database"
                }
                container "Backup bucket"{
                    ml_workbench -> this "Backups files to" "rsync"
                    tags "Database"
                }
            }

            model_registry = container "Model registry" {
                ml_workbench -> this "Evaluate experiments and load model artifacts from"
                tags "Database"
            }
            vertex_pipelines = container "Pipeline execution engine" {
                ml_workbench -> this "Submits pipeline job"
                this -> model_registry "Writes experiment results and model artifacts to" "HTTPS"
            }
            vertex_serving = container "Vertex serving" {
                vertex_pipelines -> this "Deploys model API" "SDK/HTTPS"
                this -> model_registry "Loads model artifacts and dependency requirements from"
            }
            group "Scheduling" {
                schedule_code = container "Schedules as code" {
                    user -> this "Defines pipeline schedules in" "YAML"
                    description "Stores the CRON schedule by which to execute training and prediction pipelines "
                    tags "Database"
                }
                cloud_scheduler = container "Cloud Scheduler" {
                    schedule_code -> this "Configures schedule" "Terraform"
                }
                trigger_function = container "Trigger function" {
                    cloud_scheduler -> this "Triggers on schedule" "HTTPS"
                    this -> vertex_pipelines "Submit pipeline job"
                }
            }
            pipeline_bucket = container "Pipeline bucket" {
                ml_workbench -> this "Push pipeline definition to"
                trigger_function -> this "Reads pipeline definitions from"
                vertex_pipelines -> this "Reads pipeline definition from"
                tags "Database"
            }
            big_query = container "Big Query" {
                vertex_pipelines -> this "Loads data and writes predictions to" "SQL"
                ml_workbench -> this "Queries data for exploration from" "SQL"
                tags "Database"
            }
        }

        pipelines = softwareSystem "Model training and prediction pipelines"  {
            this -> platform "Runs on"
            this -> pipeline_bucket "Writes pipeline definition to"
            user -> this "Develops"
            ml_workbench -> this "Push model code to" "git"
            description "Model and prediction pipeline code stored in Github"
            tags "External"
        }
        
        data_platform = softwareSystem "Data platform" {
            platform -> this "Ingests data from"
            tags "External"
        }

        monitoring = softwareSystem "Monitoring system" {
            platform -> this "Writes metrics to"
            tags "External"
        }

        api = softwareSystem "Web application" {
            this -> vertex_serving "Calls model service" "HTTPS"
            tags "External"
        }

        dashboard = softwareSystem "Dashboard" {
            this -> big_query "Reads model predictions from BigQuery" "SQL"
            tags "External"
        }
    }

    views {
        systemContext platform {
            include *
            include user
            autoLayout lr
        }

        container platform {
            include *
            autoLayout lr     
        }

      theme default
 
        styles {
            element "Element" {
                background #2A10CF
            }
            element "External" {
                background #969393
            }
            element "Database" {
                shape Cylinder
            }
        }
    }
}