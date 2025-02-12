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

        batch_layer = softwareSystem "Input data" {
            elt -> this "Writes input data"
            tags "External"
            tags "Database"
        }

        features = softwareSystem "Feature store" {
            kafka -> this "Writes real-time feature"
            batch_layer -> this "Write batch feature"

            tags "External"
            tags "Database"
        }

        sync_serving = softwareSystem "Synchronous serving system with real-time and batch features" {


            training = container "Model training" {
                this -> features "Read training dataset"

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
            include batch_layer
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
