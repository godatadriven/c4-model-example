workspace {

    model {
        customer = person "Customer" "Customer using the app" "External"
        data_scientist = person "Data Scientist" "Data scientist developing a machine learning model" "External"
        
        ml_platform = softwareSystem "ML Platform" "Machine learning model serving platform exposing models over REST and Kafka." {
            sidecar = container "Model sidecar application" "Ambassador sidecar for ML model" {
                streaming_module = component "Streaming module" "Reads prediction requests from Kafka topic and returns predictions to another."{
                }
    
                rest_module = component "REST module" "Receives prediction requests and returns response."
            }
            
            model_container = container "Model" "Machine learning model serving predictions" {
                sidecar -> this "Sends request to" "GRPC"
                model_module = component "Python model implementation" "Python Model class implementing __init__ and predict methods" {
                    data_scientist -> this "Develops"
                }
    
                api_module = component "Model wrapper" "Python model wrapper serving predictions using a Dataframe => Dataframe interface." {
                    rest_module -> this "Requests prediction from" "GRPC"
                    streaming_module -> this "Requests prediction from" "GRPC"
                    this -> model_module "Initializes and calls model."
                }
            }
        }
        
        logging = softwareSystem "Log aggregator" "Logging system based on ELK stack" "External" {
            sidecar -> this "Sends logs to" "Kafka"
            model_container -> this "Sends logs to" "Filebeat"
        }
        
        RTK = softwareSystem "Metrics collector" "Reliability toolkit supporting web application monitoring" "External" {
            sidecar -> this "Exposes metrics to" "HTTP"
        }

        rest_client = softwareSystem "Backend application A" "Any application that makes use of a REST machine learning model" "External" {
            this -> rest_module "Requests prediction from" "HTTP"
        }
        
        streaming_client = softwareSystem "Backend application B" "Any application that makes use of a streaming machine learning model" "External" {
            this -> streaming_module "Sends prediction to" "Kafka"
        }
        
        client_fe = softwareSystem "FE application" "Client frontend web application" "External,FE" {
            this -> rest_client "Requests information from" "HTTP"
            this -> streaming_client "Requests information from" "HTTP"
            customer -> this "Uses"
        }
    }

    views {
        systemContext ml_platform {
            include *
            include customer
            include client_fe
            autolayout lr
        }

        container ml_platform {
            include *
            autolayout lr
        }

        component model_container {
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
        }
    }
}
