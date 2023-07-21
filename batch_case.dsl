workspace {
   
   model {
      stock_controller = person "Stock controller" "Person responsible for the stock levels of all products in a certain product category." "External"
      data_scientist = person "Data Scientist" "Person involved in developing the machine learning model." "External"
      
      forecasting_model = softwareSystem "Demand forecasting" "Machine learning model predicting the monthly product demand." {
         data_scientist -> this "Develops"
         
         model_predictions_database = container "Forecast storage" "OLTP database used for storing predicted demand per product per month/year." "" "Database, Microsoft Azure - Azure Cosmos DB"
         model_registry = container "Model registry" "Storage location for experiments, model artifacts and model metadata." "MLFlow" "Database, Model Registry"
         prediction_pipeline = container "Prediction pipeline" "Pyspark script scheduled to run the first of each month predicting demand for all products three months in advance." "PySpark pipeline" "Microsoft Azure - Azure Databricks" {
            this -> model_predictions_database "Writes forecasts to"
            this -> model_registry "Loads model from"
         }
         model_training_pipeline = container "Model training" "Pipeline that trains a new model based on input data." "Azure ML pipeline" "Microsoft Azure - Machine Learning" {
            this -> model_registry "Writes candidate model to"
         }
         evaluation_dashboard = container "Performance dashboard" "Dashboard showing key performance indicator for demand predictions." "" "FE, Microsoft Azure - Azure Databricks" {
            stock_controller -> this "Analyses"
            data_scientist -> this "Analyses"
         }
         evaluation_pipeline = container "Evaluation job" "Compares the real demand figures with the predicted values and creates a dashboard for analysis." "PySpark pipeline" "Microsoft Azure - Azure Databricks" {
            this -> model_predictions_database "Reads forecasts"
            this -> evaluation_dashboard "Writes data"
         } 
         notebook_service = container "Data exploration service" "Jupyter notebook environment with access to data used for exploratory analysis." "Jupyter notebook" "FE, Microsoft Azure - Machine Learning Studio Workspaces" {
            data_scientist -> this "Uses"
         }
      }
      
      data_warehouse = softwareSystem "Data warehouse" "Company data warehouse." "External, Database, Microsoft Azure - Azure Databricks" {
         training_database = container "Sales data" "Data warehouse tables containing historical sales figures." {
            evaluation_pipeline -> this "Read sales figures"
            notebook_service -> this "Loads data from"
            model_training_pipeline -> this "Read data from"
         }
      }
      
      erp_system = softwareSystem "Enterprise Resource Planning (ERP) software" "Software used to manage warehouse inventory." "External" {
         this -> model_predictions_database "Reads data from" "JDBC"
         stock_controller -> this "Uses"
      }
      
   }
   
   views {
      systemContext forecasting_model {
         include *
         include stock_controller
      }
      
      container forecasting_model {
         include *
         include stock_controller
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
