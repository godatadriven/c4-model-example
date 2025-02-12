workspace {
   
    model {
      customer = person "Fancy Fashion customer" {
        description "Individual using the Fancy Fashion app to buy and sell second-hand clothing."
        tags "External, Person"
      }
      
      image_tagging = softwareSystem "Image tagging system" {
        description "Machine learning system categorising images of fashion items and generates tags for them to improve ease of finding items."

        model_application = container "Model application" {
          description "Machine learning model application serving model online synchronously as a REST API. Receives images and returns tags. Includes an endpoint to gather feedback from customers on tags. Exposes metrics endpoint to monitor performance."
          technology "Python, FastAPI"

          prediction_endpoint = component "Prediction endpoint" {
            description "Endpoint that receives images and returns tags."
          }

          feedback_endpoint = component "Feedback endpoint" {
            description "Endpoint that receives advertisement ID, model ID, and tags."
          }

          metrics_endpoint = component "Metrics endpoint" {
            description "Endpoint exposing text based metrics for Prometheus scraping."

            feedback_endpoint -> this "Set feedback metrics"
          }

          prediction_model = component "Image classification model" {
            description "Machine learning model that predicts tags for images."

            technology "PyTorch"
          }

          model_preprocessing = component "Preprocessing" {
            description "Preprocesses images before feeding them into the model."

            this -> prediction_model "Call model"
            prediction_endpoint -> this "Call with images"
          }
        }

        image_metadata_db = container "Image metadata database" {
          description "OLTP database storing metadata about images. Metadata includes tags, image ID, feedback etc."
          tags = "Database"

          technology "PostgreSQL"

          feedback_endpoint -> this "Read and write data" "ODBC"
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

          prediction_model -> this "Loads model" "HTTPS"
        }

        model_training = container "Model training" {
          description "Pipeline that trains a new model based on labelled image data."
          tags "Pipeline"

          this -> model_file "Write candidate model"
        }

        preprocessing = container "Data preprocessing" {
          description "Pipeline that reads images and applies preprocessing logic (e.g. resizing)."
          tags "Pipeline"

          image_loading = component "Read images" {
            description "Reads raw images from the data lake."

            tags "Pipeline"
          }

          preprocessing_logic = component "Preprocessing" {
            description "Reads raw images, preprocesses them and stores preprocessed images."
            tags "Pipeline"

            image_loading -> this "Call with images"
          }
        }
      }
      
      data_lake = softwareSystem "Data lake" {
        description "Fancy fashion's central storage location for structured and unstructured data."
        tags "External, Database"

        images = container "Images" {
          description "Storage account containing images of fashion items stored by ID."
          tags "External, Database"

          technology "S3"

          model_training -> this "Read preprocesses images"
          image_loading -> this "Read images"
          preprocessing_logic -> this "Write preprocessed images"
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
          this        -> prediction_endpoint "Request image tags" "HTTPS"
          this        -> feedback_endpoint "Sends customer feedback" "HTTPS"
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
    
    component model_application {
      include *
    }
    
    component preprocessing {
      include *
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
