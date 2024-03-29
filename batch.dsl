workspace {

    model {
        customer = person "Customer" "Customer using the app" "External"

        elt = softwareSystem "Ingestion pipeline" {
            tags "External"
            tags "Pipeline"
        }
        
        batch = softwareSystem "Batch prediction system" {

            batch_layer = container "Input data" {
                elt -> this "Writes input data"

                tags "Database"
            }

            training = container "Model training" {
                this -> batch_layer "Read training dataset"

                tags "Pipeline"
            }

            serving_layer = container "Predictions database" {
                tags "Database"
            }

            predictions = container "Batch pipeline" {
                this -> batch_layer "Reads input data"
                this -> serving_layer "Writes predictions"
                training -> this "Trigger execution"

                tags "Pipeline"
            }

            web_app = container "Web app" {
                this -> serving_layer "Reads predictions"
                customer -> this "Uses"

                tags "UI"
            }
        }
    }

    views {
        container batch {
            include *
            autoLayout lr
        }
        
        theme default
        
        styles {
            element "External" {
                background #cccccc
            }
            element "Pipeline" {
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
