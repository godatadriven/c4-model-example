This repo was created as an example of how you can model your software architecture using the [C4 model](https://c4model.com/).
It makes use of the [Structurizr DSL](https://structurizr.com/).

This repository contains two examples.
It is by no means complete, but serves as an example of how to start creating a C4 model. The architecture describes the Context, Container and Component level.  
The example makes use of the DSL's basic functionality and some more advanced features.

- [Machine Learning model serving platform](#machine-learning-model-serving-platform)
- [Image classification use case](#image-classification)

## Machine Learning model serving platform
This example architecture describes a Machine Learning model serving platform. 

### Context
![C4 context diagram](images/platform/context.png)

### Container
![C4 container diagram](images/platform/container.png)

### Component
![C4 component diagram](images/platform/component.png)

## Image classification
This example shows the architecture diagram of an image classification machine learning model.

### Context
![C4 context diagram](images/use_case/context.png)


```mermaid
graph LR
  linkStyle default fill:#ffffff

  subgraph diagram [ML Platform - System Context]
    style diagram fill:#ffffff,stroke:#ffffff

    1["<div style='font-weight: bold'>Customer</div><div style='font-size: 70%; margin-top: 0px'>[Person]</div><div style='font-size: 80%; margin-top:10px'>Customer using the banking<br />app</div>"]
    style 1 fill:#cccccc,stroke:#8e8e8e,color:#ffffff
    2["<div style='font-weight: bold'>Data Scientist</div><div style='font-size: 70%; margin-top: 0px'>[Person]</div><div style='font-size: 80%; margin-top:10px'>Data scientist developing a<br />machine learning model</div>"]
    style 2 fill:#cccccc,stroke:#8e8e8e,color:#ffffff
    20("<div style='font-weight: bold'>Log aggregator</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div><div style='font-size: 80%; margin-top:10px'>Logging system based on ELK<br />stack</div>")
    style 20 fill:#cccccc,stroke:#8e8e8e,color:#ffffff
    24("<div style='font-weight: bold'>Metrics collector</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div><div style='font-size: 80%; margin-top:10px'>Reliability toolkit<br />supporting web application<br />monitoring</div>")
    style 24 fill:#cccccc,stroke:#8e8e8e,color:#ffffff
    27("<div style='font-weight: bold'>Backend application A</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div><div style='font-size: 80%; margin-top:10px'>Any application that makes<br />use of a REST machine<br />learning model</div>")
    style 27 fill:#cccccc,stroke:#8e8e8e,color:#ffffff
    3("<div style='font-weight: bold'>ML Platform</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div><div style='font-size: 80%; margin-top:10px'>Machine learning model<br />serving platform exposing<br />models over REST and Kafka.</div>")
    style 3 fill:#1168bd,stroke:#0b4884,color:#ffffff
    31("<div style='font-weight: bold'>Backend application B</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div><div style='font-size: 80%; margin-top:10px'>Any application that makes<br />use of a streaming machine<br />learning model</div>")
    style 31 fill:#cccccc,stroke:#8e8e8e,color:#ffffff
    35["<div style='font-weight: bold'>FE application</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div><div style='font-size: 80%; margin-top:10px'>Client frontend web<br />application</div>"]
    style 35 fill:#cccccc,stroke:#8e8e8e,color:#ffffff

    2-. "<div>Develops</div><div style='font-size: 70%'></div>" .->3
    3-. "<div>Sends logs to</div><div style='font-size: 70%'>[Kafka]</div>" .->20
    3-. "<div>Exposes metrics to</div><div style='font-size: 70%'>[HTTP]</div>" .->24
    27-. "<div>Requests prediction from</div><div style='font-size: 70%'>[HTTP]</div>" .->3
    31-. "<div>Sends prediction to</div><div style='font-size: 70%'>[Kafka]</div>" .->3
    35-. "<div>Requests information from</div><div style='font-size: 70%'>[HTTP]</div>" .->27
    35-. "<div>Requests information from</div><div style='font-size: 70%'>[HTTP]</div>" .->31
    1-. "<div>Uses</div><div style='font-size: 70%'></div>" .->35
  end
```

```mermaid

graph LR
  linkStyle default fill:#ffffff

  subgraph diagram [ML Platform - Model - Components]
    style diagram fill:#ffffff,stroke:#ffffff

    2["<div style='font-weight: bold'>Data Scientist</div><div style='font-size: 70%; margin-top: 0px'>[Person]</div><div style='font-size: 80%; margin-top:10px'>Data scientist developing a<br />machine learning model</div>"]
    style 2 fill:#cccccc,stroke:#8e8e8e,color:#ffffff
    4("<div style='font-weight: bold'>Model sidecar application</div><div style='font-size: 70%; margin-top: 0px'>[Container]</div><div style='font-size: 80%; margin-top:10px'>Ambassador sidecar for ML<br />model</div>")
    style 4 fill:#438dd5,stroke:#2e6295,color:#ffffff

    subgraph 7 [Model]
      style 7 fill:#ffffff,stroke:#444444,color:#444444

      13("<div style='font-weight: bold'>Model wrapper</div><div style='font-size: 70%; margin-top: 0px'>[Component]</div><div style='font-size: 80%; margin-top:10px'>Python model wrapper serving<br />predictions using a Dataframe<br />=> Dataframe interface.</div>")
      style 13 fill:#85bbf0,stroke:#5d82a8,color:#000000
      9("<div style='font-weight: bold'>Python model implementation</div><div style='font-size: 70%; margin-top: 0px'>[Component]</div><div style='font-size: 80%; margin-top:10px'>Python Model class<br />implementing __init__ and<br />predict methods</div>")
      style 9 fill:#85bbf0,stroke:#5d82a8,color:#000000
    end

    2-. "<div>Develops</div><div style='font-size: 70%'></div>" .->9
    4-. "<div>Requests prediction from</div><div style='font-size: 70%'>[GRPC]</div>" .->13
    13-. "<div>Initializes and calls model.</div><div style='font-size: 70%'></div>" .->9
  end
```