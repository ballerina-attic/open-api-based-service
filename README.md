[![Build Status](https://travis-ci.org/ballerina-guides/open-api-based-service.svg?branch=master)](https://travis-ci.org/ballerina-guides/open-api-based-service)

# Swagger / OpenAPI
[OpenAPI Specification](https://swagger.io/specification/) (formerly called the Swagger Specification) is a specification that creates RESTful contract for APIs, detailing all of its resources and operations in a human and machine-readable format for easy development, discovery, and integration.
The Swagger to Ballerina Code Generator can take existing Swagger definition files and generate Ballerina services from them.

> This guide walks you through building a RESTful Ballerina web service using Swagger / OpenAPI Specification.

The following are the sections available in this guide.

- [What you'll build](#what-youll-build)
- [Prerequisites](#prerequisites)
- [Implementation](#implementation)
- [Testing](#testing)
- [Deployment](#deployment)
- [Observability](#observability)

## What you'll build
You'll build an RESTful web service using an OpenAPI / Swagger specification. This guide will walk you through building a pet store server from an OpenAPI / Swagger definition. The pet store service will have RESTful POST,PUT,GET and DELETE methods to handle pet data.

&nbsp; 
![alt text](/images/OpenAPI.svg)
&nbsp; 

## Prerequisites
 
- [Ballerina Distribution](https://ballerina.io/learn/getting-started/)
- A Text Editor or an IDE 
> **Tip**: For a better development experience, install one of the following Ballerina IDE plugins: [VSCode](https://marketplace.visualstudio.com/items?itemName=ballerina.ballerina), [IntelliJ IDEA](https://plugins.jetbrains.com/plugin/9520-ballerina)

### Optional requirements

- [Docker](https://docs.docker.com/engine/installation/)
- [Kubernetes](https://kubernetes.io/docs/setup/)

## Implementation

> If you want to skip the basics, you can download the git repo and directly move to the "Testing" section by skipping  "Implementation" section.

### Understand the Swagger / OpenAPI specification
The scenario that we use throughout this guide will base on a [petstore.json](guide/petstore.json) swagger specification. The OpenAPI / Swagger specification contains all the required details about the pet store RESTful API. Additionally, You can use the Swagger view in Ballerina Composer to create and edit OpenAPI / Swagger files. 

#### Basic structure of petstore Swagger/OpenAPI specification
```json
{
  "swagger": "2.0",
  "info": {
    "title": "Ballerina Petstore",
    "description": "This is a sample Petstore server.",
    "version": "1.0.0"
  },
  "host": "localhost:9090",
  "basePath": "/v1",
  "schemes": [
    "http"
  ],
  "paths": {
    "/pet": {
      "post": {
        "summary": "Add a new pet to the store",
        "description": "Optional extended description in Markdown.",
        "produces": [
          "application/json"
        ],
        "responses": {
          "200": {
            "description": "OK"
          }
        }
      }
    }
  }
}
```

NOTE :  The above OpenAPI / Swagger definition is only the basic structure. You can find the complete OpenAPI / Swagger definition in [petstore.json](guide/petstore.json) file.


### Create the project structure

Ballerina is capable of maintaining custom project structures depending on the requirement. We use following project structure in this project to follow the guide.
```
open-api-based-service
  └── guide
	 └── petstore.json  
```

- Create the above directories in your local machine and also copy the [petstore.json](guide/petstore.json) file to the open-api-based-service directory.

- Then open the terminal and navigate to `open-api-based-service/guide` and run Ballerina project initializing toolkit.
```bash
   $ ballerina init
```

### Genarate the web service from the Swagger / OpenAPI definition

Ballerina language is capable of understanding the Swagger / OpenAPI specifications. We can easily generate the web service just by typing the following command structure in the terminal.
```
ballerina swagger mock <swaggerFile> [-o <output directory name>] [-m <module name>] 
```

For our pet store service we need to run the following command from the `/guide` in sample root directory(location where you have the petstore.json file) to generate the Ballerina service from the OpenAPI / Swagger definition

```bash 
$ ballerina swagger mock petstore.json -m petstore
```

The `-m` flag indicates the module name and `-o` flag indicates the file destination for the web service. These parameters are optional and can be used to have a customized module name and file location for the project.

#### Generated ballerina modules 
After running the above command, the pet store web service will be auto-generated. Now the module structure is similar to the following,

```
└── open-api-based-service
    └── guide
        ├── petstore
        │   ├── ballerina_petstore_impl.bal
        │   ├── gen
        │   │   ├── ballerina_petstore.bal
        │   │   └── schema.bal
        │   └── tests
        │       └── ballerina_petstore_test.bal
        └── petstore.json
```

`ballerina_petstore.bal` is the generated Ballerina code of the pet store service and `ballerina_petstore_impl.bal` is the generated mock implementation for the pet store functions.

#### Generated `ballerina_petstore.bal` file
  
```ballerina
import ballerina/http;
import ballerina/log;
import ballerina/mime;
import ballerina/swagger;

listener http:Listener ep0 = new(9090);

@swagger:ServiceInfo {
    title: "Ballerina Petstore",
    description: "This is a sample Petstore server. This uses swagger definitions to create the ballerina service",
    serviceVersion: "1.0.0",
    termsOfService: "http://ballerina.io/terms/",
    contact: {name: "", email: "samples@ballerina.io", url: ""},
    license: {name: "Apache 2.0", url: "http://www.apache.org/licenses/LICENSE-2.0.html"},
    tags: [
        {name: "pet", description: "Everything about your Pets", externalDocs: {description: "Find out more", url: "http://ballerina.io"}}
    ],
    externalDocs: {description: "Find out more about Ballerina", url: "http://ballerina.io"}
}
@http:ServiceConfig {
    basePath: "/v1"
}
service BallerinaPetstore on ep0 {

    @swagger:ResourceInfo {
        summary: "Update an existing pet",
        tags: ["pet"]
    }
    @http:ResourceConfig { 
        methods:["PUT"],
        path:"/pet",
        body:"petDetails"
    }
    resource function updatePet (http:Caller outboundEp, http:Request req, Pet petDetails) {
        http:Response res = updatePet(req, petDetails);
        var result = outboundEp->respond(res);

        if (result is error) {
            log:printError("Error while responding", err = result);
        }
    }

    @swagger:ResourceInfo {
        summary: "Add a new pet to the store",
        tags: ["pet"]
    }
    @http:ResourceConfig { 
        methods:["POST"],
        path:"/pet",
        body:"petDetails"
    }
    resource function addPet (http:Caller outboundEp, http:Request req, Pet petDetails) {
        http:Response res = addPet(req, petDetails);
        var result = outboundEp->respond(res);

        if (result is error) {
            log:printError("Error while responding", err = result);
        }
    }

    @swagger:ResourceInfo {
        summary: "Find pet by ID",
        tags: ["pet"],
        description: "Returns a single pet",
        parameters: [
            {
                name: "petId",
                inInfo: "path",
                description: "ID of pet to return", 
                required: true, 
                allowEmptyValue: ""
            }
        ]
    }
    @http:ResourceConfig { 
        methods:["GET"],
        path:"/pet/{petId}"
    }
    resource function getPetById (http:Caller outboundEp, http:Request req, string petId) {
        http:Response res = getPetById(req, petId);
        var result = outboundEp->respond(res);

        if (result is error) {
            log:printError("Error while responding", err = result);
        }
    }

    @swagger:ResourceInfo {
        summary: "Deletes a pet",
        tags: ["pet"],
        parameters: [
            {
                name: "petId",
                inInfo: "path",
                description: "Pet id to delete", 
                required: true, 
                allowEmptyValue: ""
            }
        ]
    }
    @http:ResourceConfig { 
        methods:["DELETE"],
        path:"/pet/{petId}"
    }
    resource function deletePet (http:Caller outboundEp, http:Request req, string petId) {
        http:Response res = deletePet(req, untaint petId);
        var result = outboundEp->respond(res);

        if (result is error) {
            log:printError("Error while responding", err = result);
        }
    }
}
```

Next we need to implement the business logic in the `ballerina_petstore_impl.bal` file.

### Implement the business logic for petstore 

Now we have the Ballerina web service for the give `petstore.json` Swagger file. Next task is to implement the business logic for functionality of each resource. The Ballerina Swagger generator has generated `ballerina_petstore_impl.bal` file inside the `open-api-based-service/guide/petstore`. We need to fill the `ballerina_petstore_impl.bal` as per the requirement. For simplicity, we will use an in-memory map to store the pet data. The following code is the completed pet store web service implementation. 

```ballerina
import ballerina/http;
import ballerina/mime;

map petData;

public function addPet(http:Request req, Pet petDetails) returns http:Response {

    // Initialize the http response message
    http:Response resp;
    // Access payload data which transformed from JSON to Pet data structure
    if (petDetails.id == "") {
        // Send bad request message to the client if request doesn't contain valid pet id
        resp.setTextPayload("Error : Please provide the json payload with `id`,`catogery` and `name`");
        // set the response code as 400 to indicate a bad request
        resp.statusCode = 400;
    }
    else {
        // Add the pet details into the in memory map
        petData[petDetails.id] = petDetails;
        // Send back the status message back to the client
        string payload = "Pet added successfully : Pet ID = " + petDetails.id;
        resp.setTextPayload(untaint payload);
    }
    return resp;
}

public function updatePet(http:Request req, Pet petDetails) returns http:Response {

    // Initialize the http response message
    http:Response resp;
    // Access payload data which transformed from JSON to Pet data structure
    if (petDetails.id == "" || !petData.hasKey(petDetails.id)) {
        // Send bad request message to the client if request doesn't contain valid pet id
        resp.setTextPayload("Error : Please provide the json payload with valid `id``");
        // set the response code as 400 to indicate a bad request
        resp.statusCode = 400;
    }
    else {
        // Update the pet details in the map
        petData[petDetails.id] = petDetails;
        // Send back the status message back to the client
        string payload = "Pet updated successfully : Pet ID = " + petDetails.id;
        resp.setTextPayload(untaint payload);
    }
    return resp;
}

public function getPetById(http:Request req, string petId) returns http:Response {
    // Initialize http response message to send back to the client
    http:Response resp;
    // Send bad request message to client if pet ID cannot found in petData map
    if (!petData.hasKey(petId)) {
        resp.setTextPayload("Error : Invalid Pet ID");
        // set the response code as 400 to indicate a bad request
        resp.statusCode = 400;
    }
    else {
        // Set the pet data as the payload and send back the response
        var payload = <string>petData[petId];
        resp.setTextPayload(untaint payload);
    }
    return resp;
}

public function deletePet(http:Request req, string petId) returns http:Response {
    // Initialize http response message
    http:Response resp;
    // Send bad request message to client if pet ID cannot found in petData map
    if (!petData.hasKey(petId)) {
        resp.setTextPayload("Error : Invalid Pet ID");
        // set the response code as 400 to indicate a bad request
        resp.statusCode = 400;
    }
    else {
        // Remove the pet data from the petData map
        _ = petData.remove(petId);
        // Send the status back to the client
        string payload = "Deleted pet data successfully : Pet ID = " + petId;
        resp.setTextPayload(payload);
    }
    return resp;
}
```

With that, we have completed the implementation of the pet store web service.

## Testing 

### Invoking the petstore service 

You can run the RESTful service that you developed above, in your local environment. Open your terminal and navigate to `open-api-based-service/guide`, and execute the following command.
```
$ ballerina run petstore
```

- You can test the functionality of the pet store RESTFul service by sending HTTP request for each operation. For example, we have used the curl commands to test each operation of pet store as follows. 

**Add a new pet** 
```
curl -X POST -d '{"id":1, "category":"dog", "name":"doggie"}' \
"http://localhost:9090/v1/pet/" -H "Content-Type:application/json"

Output :  
Pet added successfully : Pet ID = 1
```

**Retrieve pet data** 
```
curl "http://localhost:9090/v1/pet/1"

Output:
{"id":"1","category":"dog","name":"doggie"}
```

**Update pet data** 
```
curl -X PUT -d '{"id":1, "category":"dog-updated", "name":"Updated-doggie"}' \
"http://localhost:9090/v1/pet/" -H "Content-Type:application/json"

Output: 
Pet details updated successfully : id = 1
```

**Delete pet data** 
```
curl -X DELETE  "http://localhost:9090/v1/pet/1"

Output:
Deleted pet data successfully: Pet ID = 1
```

### Writing Unit Tests 

In Ballerina, the unit test cases should be in the same module inside a folder named as 'tests'.  When writing the test functions the below convention should be followed.
- Test functions should be annotated with `@test:Config`. See the below example.
```ballerina
   @test:Config
   function testPetStore() {
```
  
This guide contains unit test cases for each method available in the 'petstore service' implemented above. 

To run the unit tests, open your terminal and navigate to `open-api-based-service/guide`, and run the following command.
```bash
$ ballerina test
```

To check the implementation of the test file, refer to the [ballerina_petstore_test.bal](guide/petstore/tests/ballerina_petstore_test.bal).

## Deployment

Once you are done with the development, you can deploy the service using any of the methods that we listed below. 

### Deploying locally

- As the first step you can build a Ballerina executable archive (.balx) of the service that we developed above, using the following command. It points to the directory in which the service we developed above located and it will create an executable binary out of that. Navigate to `open-api-based-service/guide` and run the following command. 
```
   $ ballerina build petstore
```

- Once the restful_service.balx is created inside the target folder, you can run that with the following command. 
```
   $ ballerina run target/petstore.balx
```

- The successful execution of the service will show us the following output. 
```
   ballerina: initiating service(s) in 'target/petstore.balx'
   ballerina: started HTTP/WS endpoint 0.0.0.0:9090
```

### Deploying on Docker

You can run the service that we developed above as a Docker container. As Ballerina platform offers native support for running ballerina programs on 
containers, you just need to put the corresponding Docker annotations on your service code. 

- In our ballerina_petstore, we need to import  `` import ballerinax/docker; `` and use the annotation `` @docker:Config `` as shown below to enable Docker image generation during the build time. 

##### BallerinaPetstore.bal
```ballerina
// Other imports
import ballerinax/docker;

@docker:Config {
    registry:"ballerina.guides.io",
    name:"petstore",
    tag:"v1.0"
}

@docker:Expose{}
listener http:Listener ep0 = new(9090);

// 'petData' Map definition

// '@swagger:ServiceInfo' annotation

@http:ServiceConfig {
    basePath:"/v1"
}
service BallerinaPetstore on ep0 {
``` 

- Now you can build a Ballerina executable archive (.balx) of the service that we developed above, using the following command. It points to the service file that we developed above and it will create an executable binary out of that. 
This will also create the corresponding Docker image using the Docker annotations that you have configured above. Navigate to the `<SAMPLE_ROOT>/guide/` folder and run the following command.  
```
  $ballerina build petstore
  
  Run following command to start Docker container: 
  docker run -d -p 9090:9090 ballerina.guides.io/petstore:v1.0
```
- Once you successfully build the Docker image, you can run it with the `` docker run`` command that is shown in the previous step.  

```   
    docker run -d -p 9090:9090 ballerina.guides.io/petstore:v1.0
```
    Here we run the Docker image with flag`` -p <host_port>:<container_port>`` so that we  use  the host port 9090 and the container port 9090. Therefore you can access the service through the host port. 

- Verify Docker container is running with the use of `` $ docker ps``. The status of the Docker container should be shown as 'Up'. 
- You can access the service using the same curl commands that we've used above. 
 
```
    curl -X POST -d '{"id":1, "category":"dog", "name":"doggie"}' \
    "http://localhost:9090/v1/pet/" -H "Content-Type:application/json"  
```


### Deploying on Kubernetes

- You can run the service that we developed above, on Kubernetes. The Ballerina language offers native support for running a ballerina programs on Kubernetes, 
with the use of Kubernetes annotations that you can include as part of your service code. Also, it will take care of the creation of the Docker images. 
So you don't need to explicitly create Docker images prior to deploying it on Kubernetes.   

- We need to import `` import ballerinax/kubernetes; `` and use `` @kubernetes `` annotations as shown below to enable kubernetes deployment for the service we developed above. 

> NOTE: Linux users can use Minikube to try this out locally.

##### BallerinaPetstore.bal

```ballerina
// Other imports
import ballerinax/kubernetes;

@kubernetes:Ingress {
  hostname:"ballerina.guides.io",
  name:"ballerina-guides-petstore",
  path:"/"
}

@kubernetes:Service {
  serviceType:"NodePort",
  name:"ballerina-guides-petstore"
}

@kubernetes:Deployment {
  image:"ballerina.guides.io/petstore:v1.0",
  name:"ballerina-guides-petstore"
}

listener http:Listener ep0 = new(9090);

// 'petData' Map definition

// '@swagger:ServiceInfo' annotation

@http:ServiceConfig {
    basePath:"/v1"
}
service BallerinaPetstore on ep0 {
``` 
- Here we have used ``  @kubernetes:Deployment `` to specify the Docker image name which will be created as part of building this service. 
- We have also specified `` @kubernetes:Service `` so that it will create a Kubernetes service which will expose the Ballerina service that is running on a Pod.  
- In addition we have used `` @kubernetes:Ingress `` which is the external interface to access your service (with path `` /`` and host name ``ballerina.guides.io``)

If you are using Minikube, you need to set a couple of additional attributes to the `@kubernetes:Deployment` annotation.
- `dockerCertPath` - The path to the certificates directory of Minikube (e.g., `/home/ballerina/.minikube/certs`).
- `dockerHost` - The host for the running cluster (e.g., `tcp://192.168.99.100:2376`). The IP address of the cluster can be found by running the `minikube ip` command.

- Now you can build a Ballerina executable archive (.balx) of the service that we developed above, using the following command. It points to the service file that we developed above and it will create an executable binary out of that. 
This will also create the corresponding Docker image and the Kubernetes artifacts using the Kubernetes annotations that you have configured above.
  
```
  $ballerina build petstore
  
  Run following command to deploy kubernetes artifacts:  
  kubectl apply -f ./target/petstore/kubernetes
 
```

- You can verify that the Docker image that we specified in `` @kubernetes:Deployment `` is created, by using `` docker ps images ``. 
- Also the Kubernetes artifacts related our service, will be generated in `` ./target/petstore/kubernetes``. 
- Now you can create the Kubernetes deployment using:

```
 $ kubectl apply -f ./target/petstore/kubernetes 
   deployment.extensions "ballerina-guides-petstore" created
   ingress.extensions "ballerina-guides-petstore" created
   service "ballerina-guides-petstore" created

```
- You can verify Kubernetes deployment, service and ingress are running properly, by using following Kubernetes commands. 
```
$kubectl get service
$kubectl get deploy
$kubectl get pods
$kubectl get ingress

```

- If everything is successfully deployed, you can invoke the service either via Node port or ingress. 

Node Port:
 
```
curl -X POST -d '{"id":1, "category":"dog", "name":"doggie"}' \
"http://<Minikube_host_IP>:<Node_Port>/v1/pet/" -H "Content-Type:application/json"  
```
If you are using Minikube, you should use the IP address of the Minikube cluster obtained by running the `minikube ip` command. The port should be the node port given when running the `kubectl get services` command.

Ingress:

Add `/etc/hosts` entry to match hostname. For Minikube, the IP address should be the IP address of the cluster.
``` 
127.0.0.1 ballerina.guides.io
```

Access the service 

``` 
curl -X POST -d '{"id":1, "category":"dog", "name":"doggie"}' \
"http://ballerina.guides.io/v1/pet/" -H "Content-Type:application/json" 
    
```

## Observability 
Ballerina is by default observable. Meaning you can easily observe your services, resources, etc.
However, observability is disabled by default via configuration. Observability can be enabled by adding following configurations to `ballerina.conf` file and starting the ballerina service using it. A sample configuration file can be found in `open-api-based-service/guide/petstore`.

```ballerina
[b7a.observability]

[b7a.observability.metrics]
# Flag to enable Metrics
enabled=true

[b7a.observability.tracing]
# Flag to enable Tracing
enabled=true
```

To start the ballerina service using the configuration file, run the following command
```
   $ ballerina run --config petstore/ballerina.conf petstore
```
NOTE: The above configuration is the minimum configuration needed to enable tracing and metrics. With these configurations default values are load as the other configuration parameters of metrics and tracing.

### Tracing 

You can monitor ballerina services using in built tracing capabilities of Ballerina. We'll use [Jaeger](https://github.com/jaegertracing/jaeger) as the distributed tracing system.
Follow the following steps to use tracing with Ballerina.

- You can add the following configurations for tracing. Note that these configurations are optional if you already have the basic configuration in `ballerina.conf` as described above.
```
   [b7a.observability]

   [b7a.observability.tracing]
   enabled=true
   name="jaeger"

   [b7a.observability.tracing.jaeger]
   reporter.hostname="localhost"
   reporter.port=5775
   sampler.param=1.0
   sampler.type="const"
   reporter.flush.interval.ms=2000
   reporter.log.spans=true
   reporter.max.buffer.spans=1000
```

- Run Jaeger Docker image using the following command
```bash
   $ docker run -d -p5775:5775/udp -p6831:6831/udp -p6832:6832/udp -p5778:5778 -p16686:16686 \
   -p14268:14268 jaegertracing/all-in-one:latest
```

- Navigate to `open-api-based-service/guide` and run the restful-service using the following command
```
   $ ballerina run --config petstore/ballerina.conf petstore
```

- Observe the tracing using Jaeger UI using following URL
```
   http://localhost:16686
```

### Metrics
Metrics and alarts are built-in with ballerina. We will use Prometheus as the monitoring tool.
Follow the below steps to set up Prometheus and view metrics for Ballerina restful service.

- You can add the following configurations for metrics. Note that these configurations are optional if you already have the basic configuration in `ballerina.conf` as described under `Observability` section.

```
   [b7a.observability.metrics]
   enabled=true
   reporter="prometheus"

   [b7a.observability.metrics.prometheus]
   port=9797
   host="0.0.0.0"
```

- Create a file `prometheus.yml` inside `/tmp/` location. Add the below configurations to the `prometheus.yml` file.
```
   global:
     scrape_interval:     15s
     evaluation_interval: 15s

   scrape_configs:
     - job_name: prometheus
       static_configs:
         - targets: ['172.17.0.1:9797']
```

   NOTE : Replace `172.17.0.1` if your local Docker IP differs from `172.17.0.1`
   
- Run the Prometheus Docker image using the following command
```
   $ docker run -p 19090:9090 -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml \
   prom/prometheus
```

- Navigate to `open-api-based-service/guide` and run the restful-service using the following command
```
  $ ballerina run --config petstore/ballerina.conf petstore
```

- You can access Prometheus at the following URL
```
   http://localhost:19090/
```

NOTE:  Ballerina will by default have following metrics for HTTP server connector. You can enter following expression in Prometheus UI
-  http_requests_total
-  http_response_time


### Logging

Ballerina has a log module for logging to the console. You can import ballerina/log module and start logging. The following section will describe how to search, analyze, and visualize logs in real time using Elastic Stack.

- Start the Ballerina Service with the following command from `open-api-based-service/guide`
```
   $ nohup ballerina run petstore &>> ballerina.log&
```
   NOTE: This will write the console log to the `ballerina.log` file in the `open-api-based-service/guide` directory

- Start Elasticsearch using the following command

- Start Elasticsearch using the following command
```
   $ docker run -p 9200:9200 -p 9300:9300 -it -h elasticsearch --name \
   elasticsearch docker.elastic.co/elasticsearch/elasticsearch:6.2.2 
```

   NOTE: Linux users might need to run `sudo sysctl -w vm.max_map_count=262144` to increase `vm.max_map_count` 
   
- Start Kibana plugin for data visualization with Elasticsearch
```
   $ docker run -p 5601:5601 -h kibana --name kibana --link \
   elasticsearch:elasticsearch docker.elastic.co/kibana/kibana:6.2.2     
```

- Configure logstash to format the ballerina logs

i) Create a file named `logstash.conf` with the following content
```
input {  
 beats{ 
     port => 5044 
 }  
}

filter {  
 grok{  
     match => { 
	 "message" => "%{TIMESTAMP_ISO8601:date}%{SPACE}%{WORD:logLevel}%{SPACE}
	 \[%{GREEDYDATA:package}\]%{SPACE}\-%{SPACE}%{GREEDYDATA:logMessage}"
     }  
 }  
}   

output {  
 elasticsearch{  
     hosts => "elasticsearch:9200"  
     index => "store"  
     document_type => "store_logs"  
 }  
}  
```

ii) Save the above `logstash.conf` inside a directory named as `{SAMPLE_ROOT}\pipeline`
     
iii) Start the logstash container, replace the `{SAMPLE_ROOT}` with your directory name
     
```
$ docker run -h logstash --name logstash --link elasticsearch:elasticsearch \
-it --rm -v ~/{SAMPLE_ROOT}/pipeline:/usr/share/logstash/pipeline/ \
-p 5044:5044 docker.elastic.co/logstash/logstash:6.2.2
```
  
 - Configure filebeat to ship the ballerina logs
    
i) Create a file named `filebeat.yml` with the following content
```
filebeat.prospectors:
- type: log
  paths:
    - /usr/share/filebeat/ballerina.log
output.logstash:
  hosts: ["logstash:5044"]  
```
NOTE : Modify the ownership of filebeat.yml file using `$chmod go-w filebeat.yml` 

ii) Save the above `filebeat.yml` inside a directory named as `{SAMPLE_ROOT}\filebeat`   
        
iii) Start the logstash container, replace the `{SAMPLE_ROOT}` with your directory name
     
```
$ docker run -v {SAMPLE_ROOT}/filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml \
-v {SAMPLE_ROOT}/guide.restful_service/restful_service/ballerina.log:/usr/share\
/filebeat/ballerina.log --link logstash:logstash docker.elastic.co/beats/filebeat:6.2.2
```
 
 - Access Kibana to visualize the logs using following URL
```
   http://localhost:5601 
```
  
 
