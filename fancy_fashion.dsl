workspace {
   
    model {
      customer = person "Fancy Fashion customer" {
        description = "Individual using the Fancy Fashion app to buy and sell second-hand clothing."
        tags        = "External"
      }
      
      image_tagging = softwareSystem "Image tagging" {
        description = "Machine learning system categorising images of fashion items and generates tags for them to improve ease of finding items."

        model_application = container "Model application" {
          description = "Machine learning model application serving model online synchronously as a REST API. Receives images and returns tags. Includes an endpoint to gather feedback from customers on tags. Exposes metrics endpoint to monitor performance."
        }

        database = container "Image metadata database" {
          description = "OLTP database storing metadata about images. Metadata includes tags, image ID, feedback etc."

          model_application -> this "Read and write data"
        }

        model_performance_dashboard = container "Model performance dashboard" {
          description = "Visualizes technical and functional metrics to provide insights into model performance."
        }

        metric_collection_config = container "Metric collection configuration" {
          description = "Defines which metrics need to be collected from applications within the image tagging software system."
        }
      }
      
      data_lake = softwareSystem "Data lake" {
        description = "Company central storage for unstructured data e.g. images."
        tags        = "External, Database"

        images = container "Images" {
          description = "Storage account containing images of fashion items stored by ID."
          tags        = "External, Database"
        }

        image_metadata = container "Image training data" {
          description = "OLAP datastore containing metadata about images. Metadata includes tags, image ID, image URL etc."
          tags        = "External, Database"

          database -> image_metadata "Write to analytics environment" 
        }
      }
      
      fancy_fashion_app = softwareSystem "Fancy Fashion" {
        description = "E-commerce application for selling second-hand fashion items."
        tags        = "External"
        
        front_end = container "Frontend" {
          description = "Web application or mobile application for users to interact with fashion item advertisements."
          tags        = "External, Database"

          customer    -> this "Browse, purchase, and sell items" "HTTPS"
        }

        back_end = container "Backend" {
          description = "Server-side application handling user requests, managing inventory, and processing payments."
          tags        = "External"

          front_end   -> this "Request advertisement data" "HTTPS"
          this        -> model_application "Request image tags and sends customer feedback" "HTTPS"
        }

        database = container "Database" {
          description = "The database stores user data, product data, and transaction data."
          tags        = "External, Database"

          back_end    -> this "Read and write data"
        }
      }

      metric_collection = softwareSystem "Metric collection" {
        description = "Centrally managed system collecting metrics from various applications by scraping."
        tags        = "External"

        metric_collector = container "Metric collector" {
          description = "Application that collects metrics from various applications."
          tags        = "External"

          this -> back_end "Scrapes metrics" "HTTPS"
          this -> image_tagging "Scrapes metrics" "HTTPS"
          this -> metric_collection_config "Reads configuration"
          model_performance_dashboard -> this "Query metrics" "PromQL"
        }

      }
    }
   
  views {
    systemContext image_tagging {
        include *
    }
    
    container image_tagging {
        include *
    }
    
    
    theme "https://static.structurizr.com/themes/microsoft-azure-2023.01.24/theme.json"
    
    styles {
      element "Element" {
        background #3420B1
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
    }
  }
}
