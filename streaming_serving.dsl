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
            description "addfasadfdfs"

            tags "External"
            tags "Database"
        }

        features = softwareSystem "Feature store" {
            kafka -> this "Writes features"
            batch_layer -> this "Write batch feature"

            tags "External"
            tags "Database"
        }

        async_serving = softwareSystem "Streaming serving system with real-time and batch features" {

            training = container "Model training" {
                this -> features "Read training dataset"

                tags "Pipeline"
            }

            input_queue = container "Input queue" {
                tags "Message broker"
            }


            prediction_queue = container "Prediction queue" {
                tags "Message broker"
            }

            model_app = container "Model web application" {
                this -> features "Queries features" "SQL"
                training -> this "Deploys model"

                this -> input_queue "Read event"
                this -> prediction_queue "Write prediction"
            }

            web_app = container "Web app" {
                this -> input_queue "Requests prediction"
                this -> prediction_queue "Reads prediction"

                customer -> this "Uses"

                tags "UI"
            }
        }
    }

    views {
        container async_serving {
            include *
            include kafka
            include batch_layer
        }
        
        theme default
        
        styles {
            element "External" {
                background #cccccc
                description false
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
