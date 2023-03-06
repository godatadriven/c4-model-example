workspace {

    model {
        customer = person "Customer" "Person wanting to sell second hand clothes." "External"
        data_scientist = person "Data Scientist" "Person involved in developing the machine learning model." "External"

        fancy_fashion_model = softwareSystem "Image categorization" "Machine learning model predicting the product category for images uploaded by customers." {
            data_scientist -> this "Develops"
        }

        client_fe = softwareSystem "Browser application" "Client browser web application" "External,FE" {
            customer -> this "Uses"
        }

        mobile_app = softwareSystem "Mobile application" "Client mobile application" "External,Mobile" {
            customer -> this "Uses"
        }

        fancy_fashion_be = softwareSystem "BE application" "The backend application users (indirectly) interact with to upload their images." "External" {
            client_fe -> this "Requests information from" "HTTP"
            mobile_app -> this "Requests information from" "HTTP"
            this -> fancy_fashion_model "Requests information from" "HTTP"
        }
    }

    views {
        systemContext fancy_fashion_model {
            include *
            include customer
            include client_fe
            include mobile_app
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
        }
    }
}
