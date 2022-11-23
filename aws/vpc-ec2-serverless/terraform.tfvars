# ec2
apache_ec2_server_count = false

# rest api
# rest_api_types = ["REGIONAL"]
# rest_api_endpoint_ids = [] # uncomment for regional or edget type

rest_api_config = {
    test1 = {
        name = "test1"
        types = ["REGIONAL"]
        endpoint_ids = []
    }

    test2 = {
        name = "test2"
        types = ["REGIONAL"]
        endpoint_ids = []
    }
}