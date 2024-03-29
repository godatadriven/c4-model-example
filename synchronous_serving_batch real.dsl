workspace {

    model {
        customer = person "Customer" "Customer using the app" "External"

        elt = softwareSystem "Ingestion pipeline" {
            tags "External"
            tags "Pipeline"
        }

        kafka = softwareSystem "Real-time ingestion pipeline" {
            tags "External"
            tags "Message broker"
        }

        features = softwareSystem "Feature store" {
            kafka -> this "Writes features"
            
            tags "External"
            tags "Database"
        }

        sync_serving = softwareSystem "Synchronous serving system with real-time and batch features" {
            batch_layer = container "Input data" {
                elt -> this "Writes input data"

                tags "Database"
            }

            training = container "Model training" {
                this -> batch_layer "Read training dataset"

                tags "Pipeline"
            }

            feature_engineering = container "Feature engineering" {
                this -> features "Write features"
                this -> batch_layer "Reads input data"

                tags "Pipeline"
            }

            model_app = container "Model web application" {
                this -> features "Queries features" "SQL"
                training -> this "Deploys model"
            }

            web_app = container "Web app" {
                this -> model_app "Requests prediction" "HTTP/gRPC"
                customer -> this "Uses"

                tags "UI"
            }
        }
    }

    views {
        container sync_serving {
            include *
            include kafka
            autoLayout lr
        }
        
        theme default
        
        styles {
            element "External" {
                background #cccccc
            }
            element "Pipeline" {
                shape Pipe

                width 500
                height 300
            }
            element "Message broker" {
                shape Pipe

                width 600
                height 200
            }
            element "Database" {
                shape Cylinder
            }
            element "UI" {
                shape WebBrowser
            }
        }
    }
}
