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

### Optional requirements
- Ballerina IDE plugins ([IntelliJ IDEA](https://plugins.jetbrains.com/plugin/9520-ballerina), [VSCode](https://marketplace.visualstudio.com/items?itemName=WSO2.Ballerina), [Atom](https://atom.io/packages/language-ballerina))
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

Ballerina is a complete programming language that can have any custom project structure that you wish. Although the language allows you to have any package structure, use the following package structure for this project to follow this guide.
```
open-api-based-service
  |── guide
	 └── petstore.json  
```

- Create the above directories in your local machine and also copy the [petstore.json](guide/petstore.json) file to the open-api-based-service directory.

- Then open the terminal and navigate to `open-api-based-service/guide` and run Ballerina project initializing toolkit.
```bash
   $ ballerina init
```

### Genarate the web service from the Swagger / OpenAPI definition

Ballerina language is capable of understanding the Swagger / OpenAPI specifications. You can easily generate the web service just by typing the following command structure in the terminal.
```
ballerina swagger mock <swaggerFile> [-o <output directory name>] [-p <package name>] 
```

For our pet store service you need to run the following command from the `/guide` in sample root directory(location where you have the petstore.json file) to generate the Ballerina service from the OpenAPI / Swagger definition

```bash 
$ ballerina swagger mock petstore.json -p petstore
```

The `-p` flag indicates the package name and `-o` flag indicates the file destination for the web service. These parameters are optional and can be used to have a customized package name and file location for the project.

#### Generated ballerina packages 
After running the above command, the pet store web service will be auto-generated. You should now see a package structure similar to the following,

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
import ballerina/log;
import ballerina/http;
import ballerina/swagger;

endpoint http:Listener ep0 { 
    host: "localhost",
    port: 9090
};

@swagger:ServiceInfo { 
    title: "Ballerina Petstore",
    description: "This is a sample Petstore server. This uses swagger definitions to create the ballerina service",
    serviceVersion: "1.0.0",
    termsOfService: "http://ballerina.io/terms/",
    contact: {name: "", email: "samples@ballerina.io", url: ""},
    license: {name: "Apache 2.0", url: "http://www.apache.org/licenses/LICENSE-2.0.html"},
    tags: [
        {name: "pet", description: "Everything about your Pets", externalDocs: { description: "Find out more", url: "http://ballerina.io" } }
    ],
    externalDocs: { description: "Find out more about Ballerina", url: "http://ballerina.io" },
    security: [
    ]
}
@http:ServiceConfig {
    basePath: "/v1"
}
service BallerinaPetstore bind ep0 {

    @swagger:ResourceInfo {
        tags: ["pet"],
        summary: "Update an existing pet",
        description: "",
        externalDocs: {  },
        parameters: [
        ]
    }
    @http:ResourceConfig { 
        methods:["PUT"],
        path:"/pet"
    }
    updatePet (endpoint outboundEp, http:Request req) {
        http:Response res = updatePet(req);
        outboundEp->respond(res) but { error e => log:printError("Error while responding", err = e) };
    }

    @swagger:ResourceInfo {
        tags: ["pet"],
        summary: "Add a new pet to the store",
        description: "",
        externalDocs: {  },
        parameters: [
        ]
    }
    @http:ResourceConfig { 
        methods:["POST"],
        path:"/pet"
    }
    addPet (endpoint outboundEp, http:Request req) {
        http:Response res = addPet(req);
        outboundEp->respond(res) but { error e => log:printError("Error while responding", err = e) };
    }

    @swagger:ResourceInfo {
        tags: ["pet"],
        summary: "Find pet by ID",
        description: "Returns a single pet",
        externalDocs: {  },
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
    getPetById (endpoint outboundEp, http:Request req, int petId) {
        http:Response res = getPetById(req, petId);
        outboundEp->respond(res) but { error e => log:printError("Error while responding", err = e) };
    }

    @swagger:ResourceInfo {
        tags: ["pet"],
        summary: "Deletes a pet",
        description: "",
        externalDocs: {  },
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
    deletePet (endpoint outboundEp, http:Request req, int petId) {
        http:Response res = deletePet(req, petId);
        outboundEp->respond(res) but { error e => log:printError("Error while responding", err = e) };
    }
}
```

Next we need to implement the business logic in the `ballerina_petstore_impl.bal` file.

### Implement the business logic for petstore 

Now you have the Ballerina web service for the give `petstore.json` Swagger file. Then you need to implement the business logic for functionality of each resource. The Ballerina Swagger generator has generated `ballerina_petstore_impl.bal` file inside the `open-api-based-service/guide/petstore`. You need to fill the `ballerina_petstore_impl.bal` as per your requirement. For simplicity, we will use an in-memory map to store the pet data. The following code is the completed pet store web service implementation. 

```ballerina
import ballerina/http;
import ballerina/mime;

map petData;

public function addPet(http:Request req) returns http:Response {

    // Initialize the http response message
    http:Response resp;
    // Retrieve the data about pets from the json payload of the request
    var reqesetPayloadData = req.getJsonPayload();
    // Match the json payload with json and errors
    match reqesetPayloadData {
        // If the req.getJsonPayload() returns JSON
        json petDataJson => {
            // Transform into Pet data structure
            Pet petDetails = check <Pet>petDataJson;
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
                resp.setTextPayload(payload);
            }
        }
        error => {
            // Send bad request message to the client if request doesn't contain valid pet data
            resp.setTextPayload("Error : Please provide the json payload with `id`,`catogery` and `name`");
            // set the response code as 400 to indicate a bad request
            resp.statusCode = 400;
        }
    }
    return resp;
}

public function updatePet(http:Request req) returns http:Response {

    // Initialize the http response message
    http:Response resp;
    // Retrieve the data about pets from the json payload of the request
    var reqesetPayloadData = req.getJsonPayload();
    // Match the json payload with json and errors
    match reqesetPayloadData {
        // If the req.getJsonPayload() returns JSON
        json petDataJson => {
            // Transform into Pet data structure
            Pet petDetails = check <Pet>petDataJson;
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
                resp.setTextPayload(payload);
            }
        }

        error => {
            // Send bad request message to the client if request doesn't contain valid pet data
            resp.setTextPayload("Error : Please provide the json payload with `id`,`catogery` and `name`");
            // set the response code as 400 to indicate a bad request
            resp.statusCode = 400;
        }
    }
    return resp;

}

public function getPetById(http:Request req, int petId) returns http:Response {
    // Initialize http response message to send back to the client
    http:Response resp;
    // Send bad request message to client if pet ID cannot found in petData map
    if (!petData.hasKey(<string>petId)) {
        resp.setTextPayload("Error : Invalid Pet ID");
        // set the response code as 400 to indicate a bad request
        resp.statusCode = 400;
    }
    else {
        // Set the pet data as the payload and send back the response
        var payload = <string>petData[<string>petId];
        resp.setTextPayload(payload);
    }
    return resp;
}

public function deletePet(http:Request req, int petId) returns http:Response {
    // Initialize http response message
    http:Response resp;
    // Send bad request message to client if pet ID cannot found in petData map
    if (!petData.hasKey(<string>petId)) {
        resp.setTextPayload("Error : Invalid Pet ID");
        // set the response code as 400 to indicate a bad request
        resp.statusCode = 400;
    }
    else {
        // Remove the pet data from the petData map
        _ = petData.remove(<string>petId);
        // Send the status back to the client
        string payload = "Deleted pet data successfully : Pet ID = " + petId;
        resp.setTextPayload(payload);
    }
    return resp;
}
```

With that, we have completed the implementation of the pet store web service.

## Testing 

### Invoking the RESTful service 

You can run the RESTful service that you developed above, in your local environment. You need to have the Ballerina installation on your local machine and simply point to the <ballerina>/bin/ballerina binary to execute all the following steps.  

1. As the first step, you can build a Ballerina executable archive (.balx) of the service that we developed above, using the following command. It points to the directory structure of the service that we developed above and it will create an executable binary out of that. 

```
$ ballerina build petstore/
```

2. Once the petstore.balx is created, you can run that with the following command. 

```
$ ballerina run petstore.balx  
```

3. The successful execution of the service should show us the following output. 
```
ballerina: deploying service(s) in 'petstore.balx'
ballerina: started HTTP/WS server connector 0.0.0.0:9090
```

4. You can test the functionality of the pet store RESTFul service by sending HTTP request for each operation. For example, we have used the curl commands to test each operation of pet store as follows. 

**Add a new pet** 
```
curl -X POST -d '{"id":"1", "catogery":"dog", "name":"doggie"}' 
"http://localhost:9090/v1/pet/" -H "Content-Type:application/json"

Output :  
Pet added successfully : Pet ID = 1
```

**Retrieve pet data** 
```
curl "http://localhost:9090/v1/pet/1"

Output:
{"id":"1","catogery":"dog","name":"Updated"}
```

**Update pet data** 
```
curl -X PUT -d '{"id":"1", "catogery":"dog-updated", "name":"Updated-doggie"}' 
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

In ballerina, the unit test cases should be in the same package inside a `tests` directory. The naming convention should be as follows,
* Test files should contain _test.bal suffix.
* Test functions should contain test prefix.
  * e.g.: testPetStore()

This guide contains unit test cases in the respective folders. The test cases are written to test the pet store web service.
To run the unit tests, go to the sample root directory and run the following command
```bash
$ ballerina test petstore/
```

## Deployment

Once you are done with the development, you can deploy the service using any of the methods that we listed below. 

### Deploying locally
You can deploy the RESTful service that you developed above, in your local environment. You can use the Ballerina executable archive (.balx) archive that we created above and run it in your local environment as follows. 

```
ballerina run petstore.balx 
```


### Deploying on Docker

You can run the service that we developed above as a docker container. As Ballerina platform offers native support for running ballerina programs on 
containers, you just need to put the corresponding docker annotations on your service code. 

- In our ballerina_petstore, we need to import  `` import ballerinax/docker; `` and use the annotation `` @docker:Config `` as shown below to enable docker image generation during the build time. 

##### BallerinaPetstore.bal
```ballerina
package petstore;

// Other imports
import ballerinax/docker;

@docker:Config {
    registry:"ballerina.guides.io",
    name:"petstore",
    tag:"v1.0"
}

endpoint http:ServiceEndpoint ep0 {
    host:"localhost",
    port:9090
};

// 'petData' Map definition

// '@swagger:ServiceInfo' annotation

@http:ServiceConfig {
    basePath:"/v1"
}
service<http:Service> BallerinaPetstore bind ep0 {
``` 

- Now you can build a Ballerina executable archive (.balx) of the service that we developed above, using the following command. It points to the service file that we developed above and it will create an executable binary out of that. 
This will also create the corresponding docker image using the docker annotations that you have configured above. Navigate to the `<SAMPLE_ROOT>/src/` folder and run the following command.  
```
  $ballerina build petstore
  
  Run following command to start docker container: 
  docker run -d -p 9090:9090 ballerina.guides.io/petstore:v1.0
```
- Once you successfully build the docker image, you can run it with the `` docker run`` command that is shown in the previous step.  

```   
    docker run -d -p 9090:9090 ballerina.guides.io/petstore:v1.0
```
    Here we run the docker image with flag`` -p <host_port>:<container_port>`` so that we  use  the host port 9090 and the container port 9090. Therefore you can access the service through the host port. 

- Verify docker container is running with the use of `` $ docker ps``. The status of the docker container should be shown as 'Up'. 
- You can access the service using the same curl commands that we've used above. 
 
```
    curl -X POST -d '{"id":"1", "catogery":"dog", "name":"doggie"}' \
    "http://localhost:9090/v1/pet/" -H "Content-Type:application/json"  
```


### Deploying on Kubernetes

- You can run the service that we developed above, on Kubernetes. The Ballerina language offers native support for running a ballerina programs on Kubernetes, 
with the use of Kubernetes annotations that you can include as part of your service code. Also, it will take care of the creation of the docker images. 
So you don't need to explicitly create docker images prior to deploying it on Kubernetes.   

- We need to import `` import ballerinax/kubernetes; `` and use `` @kubernetes `` annotations as shown below to enable kubernetes deployment for the service we developed above. 

##### BallerinaPetstore.bal

```ballerina
package petstore;

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

endpoint http:ServiceEndpoint ep0 {
    host:"localhost",
    port:9090
};

// 'petData' Map definition

// '@swagger:ServiceInfo' annotation

@http:ServiceConfig {
    basePath:"/v1"
}
service<http:Service> BallerinaPetstore bind ep0 {
``` 
- Here we have used ``  @kubernetes:Deployment `` to specify the docker image name which will be created as part of building this service. 
- We have also specified `` @kubernetes:Service {} `` so that it will create a Kubernetes service which will expose the Ballerina service that is running on a Pod.  
- In addition we have used `` @kubernetes:Ingress `` which is the external interface to access your service (with path `` /`` and host name ``ballerina.guides.io``)

- Now you can build a Ballerina executable archive (.balx) of the service that we developed above, using the following command. It points to the service file that we developed above and it will create an executable binary out of that. 
This will also create the corresponding docker image and the Kubernetes artifacts using the Kubernetes annotations that you have configured above.
  
```
  $ballerina build petstore
  
  Run following command to deploy kubernetes artifacts:  
  kubectl apply -f ./target/petstore/kubernetes
 
```

- You can verify that the docker image that we specified in `` @kubernetes:Deployment `` is created, by using `` docker ps images ``. 
- Also the Kubernetes artifacts related our service, will be generated in `` ./target/restful_service/kubernetes``. 
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
curl -X POST -d '{"id":"1", "catogery":"dog", "name":"doggie"}' \
"http://<Minikube_host_IP>:<Node_Port>/v1/pet/" -H "Content-Type:application/json"  

```
Ingress:

Add `/etc/hosts` entry to match hostname. 
``` 
127.0.0.1 ballerina.guides.io
```

Access the service 

``` 
curl -X POST -d '{"id":"1", "catogery":"dog", "name":"doggie"}' \
"http://ballerina.guides.io/v1/pet/" -H "Content-Type:application/json" 
    
```
