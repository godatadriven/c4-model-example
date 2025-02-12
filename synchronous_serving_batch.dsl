workspace {

    model {
        customer = person "Customer" "Customer using the app" "External"

        elt = softwareSystem "Ingestion pipeline" {
            tags "External"
            tags "Pipeline"
        }

        batch_layer = softwareSystem "Input data" {
            elt -> this "Writes input data"

            tags "External"
            tags "Database"
        }

        sync_serving = softwareSystem "Synchronous serving system" {

            features = container "Pre-computed features" {
                tags "Database"
            }

            training = container "Model training" {
                this -> batch_layer "Read training dataset"
                this -> features "Write pre-computed features"

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
            element "Database" {
                shape Cylinder
            }
            element "UI" {
                shape WebBrowser
            }
        }
    }
}
