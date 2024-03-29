model {
    customer = person "Customer" "Customer using the app" "External"

    elt = softwareSystem "Ingestion pipeline" {
        tags "External"
        tags "Pipeline"
    }
}
