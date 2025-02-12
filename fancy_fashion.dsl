workspace {
   
    model {
      customer = person "Fancy Fashion customer" {
        description "Individual using the Fancy Fashion app to buy and sell second-hand clothing."
        tags "External, Person"
      }
      
      image_tagging = softwareSystem "Image tagging" {
        description "Machine learning system categorising images of fashion items and generates tags for them to improve ease of finding items."

        model_application = container "Model application" {
          description "Machine learning model application serving model online synchronously as a REST API. Receives images and returns tags. Includes an endpoint to gather feedback from customers on tags. Exposes metrics endpoint to monitor performance."
          technology "Python, FastAPI"
        }

        image_metadata_db = container "Image metadata database" {
          description "OLTP database storing metadata about images. Metadata includes tags, image ID, feedback etc."
          tags = "Database"

          technology "PostgreSQL"

          model_application -> this "Read and write data" "ODBC"
        }

        model_performance_dashboard = container "Model performance dashboard" {
          description "Visualizes technical and functional metrics to provide insights into model performance."

          technology "Grafana"
          tags "FE"
        }

        metric_collection_config = container "Metric collection configuration" {
          description "Defines which metrics need to be collected from applications within the image tagging software system. Configuration is stored in git."

          technology "Prometheus YAML"
        }

        model_file = container "Serialized model" {
          description "Serialized model file containing the machine learning model weights and parameters stored in a model registry."
          tags "Model Registry"

          technology "MLFlow"

          model_application -> this "Loads model" "HTTPS"
        }

        model_training = container "Model training" {
          description "Pipeline that trains a new model based on labelled image data."
          tags "Pipeline"

          this -> model_file "Writes candidate model"
        }

        preprocessing = container "Data preprocessing" {
          description "Pipeline that reads images and applies preprocessing logic (e.g. resizing)."
          tags "Pipeline"
        }
      }
      
      data_lake = softwareSystem "Data lake" {
        description "Fancy fashion's central storage location for structured and unstructured data."
        tags "External, Database"

        images = container "Images" {
          description "Storage account containing images of fashion items stored by ID."
          tags "External, Database"

          technology "S3"

          model_training -> this "Read images"
          preprocessing -> this "Writes preprocessed images"
        }

        image_metadata = container "Image training data" {
          description "OLAP datastore containing metadata about images. Metadata includes tags, image ID, image URL etc."
          tags "External, Database"

          technology "Parquet"

          image_metadata_db -> this "Write to analytics environment"
          model_training -> this "Read labels"
        }
      }
      
      fancy_fashion_app = softwareSystem "Fancy Fashion" {
        description "E-commerce application for selling second-hand fashion items."
        tags "External"
        
        front_end = container "Frontend" {
          description "Web application or mobile application for users to interact with fashion item advertisements."
          tags "External, Database"

          customer    -> this "Browse, purchase, and sell items" "HTTPS"
        }

        back_end = container "Backend" {
          description "Server-side application handling user requests, managing inventory, and processing payments."
          tags "External"

          front_end   -> this "Request advertisement data" "HTTPS"
          this        -> model_application "Request image tags and sends customer feedback" "HTTPS"
        }

        database = container "Database" {
          description "The database stores user data, product data, and transaction data."
          tags "External, Database"

          back_end -> this "Read and write data" "SQL"
        }
      }

      metric_collection = softwareSystem "Metric collection" {
        description "Centrally managed system collecting metrics from various applications by scraping."
        tags "External"

        metric_collector = container "Metric collector" {
          description "Application that collects metrics from various applications."
          tags "External"

          this -> model_application "Scrapes metrics" "HTTPS"
          this -> metric_collection_config "Reads configuration"
          model_performance_dashboard -> this "Query metrics" "PromQL"
        }

      }
    }
   
  views {
    systemContext image_tagging {
        include *
        include customer
    }
    
    container image_tagging {
      include *
      include customer
      include model_training->images
    }
    
        
    styles {
      element "Element" {
        background #4326FF
      }
      element "Model Registry" {
        icon "https://raw.githubusercontent.com/mlflow/mlflow/master/docs/source/_static/MLflow-logo-final-black.png"
      }
      element "External" {
        background #cccccc
      }
      element "FE" {
        shape WebBrowser
      }
      element "Database" {
        shape Cylinder
      }
      element "Person" {
        shape Person
      }
      element "Pipeline" {
        shape Pipe
        
        width 500
        height 200
      }
    }
  }
}
