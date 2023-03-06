workspace {

    model {
        customer = person "Customer" "Person wanting to sell second hand clothes." "External"
        data_scientist = person "Data Scientist" "Person involved in developing the machine learning model." "External"

        fancy_fashion_model = softwareSystem "Image categorization" "Machine learning model predicting the product category for images uploaded by customers." {
            model_api = container "Model API" "FastAPI web application serving predictions."
            model_training_pipeline = container "Model training pipeline" "Directed Acyclic Graph (DAG) loading and preprocessing data, and trains a model."
            cicd_pipeline = container "CI and CD pipeline" "Continuous integration and deployment (CI/CD) workflow running automated tests and controls the model version to be deployed." {
                this -> model_api "Deploys"
            }
            data_scientist -> this "Develops"
        }

        log_aggregator = softwareSystem "Log aggregator" "Software system able to receive and aggregate logs and allows browsing logs." "External" {
            model_api -> this "Sends logs" "Kafka"
            model_training_pipeline -> this "Sends logs" "Kafka"
            data_scientist -> this "Browses logs"
        }

        monitoring_service = softwareSystem "Monitoring service" "Prometheus metric collector scrapes metrics from HTTP and uses Grafana to visualize the metrics in dashboards." "External" {
            this -> model_api "Scrapes metrics" "HTTP"
            data_scientist -> this "Views dashboard"
        }

        model_registry = softwareSystem "Model Registry" "System to track experiments and store versioned model artifacts." "External" {
            model_training_pipeline -> this "Stores trained model and metadata"
            cicd_pipeline -> this "Downloads model artifact."
        }

        client_fe = softwareSystem "Browser application" "Client browser web application" "External,FE" {
            customer -> this "Uses"
        }

        mobile_app = softwareSystem "Mobile application" "Client mobile application" "External,Mobile" {
            customer -> this "Uses"
        }

        fancy_fashion_be = softwareSystem "Backend system" "The backend application users (indirectly) interact with to upload their images." "External" {
            client_fe -> this "Uploads image" "HTTP"
            mobile_app -> this "Uploads image" "HTTP"
            this -> model_api "Send image data" "HTTP"
            image_database = container "Image database" "Database containing images with product category labels." "Database"
        }

        data_warehouse = softwareSystem "Data warehouse" "Company wide data warehouse technology used for storing data used for analytical purposes." "External,Database" {
            image_database -> this "Stores images and labels"
            model_training_pipeline -> this "Loads images and labels"
        }

        notebook_service = softwareSystem "Data exploration service" "Jupyter notebook environment with access to data used for exploratory analysis." "External, FE" {
            this -> data_warehouse "Loads data from"
            data_scientist -> this "Uses"
        }
    }

    views {
        systemContext fancy_fashion_model {
            include *
            include customer
            include client_fe
            include mobile_app
            include data_warehouse
            include notebook_service
            autolayout lr
        }

        container fancy_fashion_model {
            include *
            autolayout lr
        }


        theme default

        styles {
            element "External" {
                background #cccccc
            }
            element "FE" {
                shape WebBrowser
            }
            element "Mobile" {
                shape MobileDevicePortrait
            }
            element "Database" {
                shape "Cylinder"
            }
        }
    }
}
