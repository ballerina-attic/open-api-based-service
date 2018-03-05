# Building RESTful Service with Swagger / OpenAPI Specifications
This guide walks you through building a RESTful Ballerina web service using [Swagger / OpenAPI Specification](https://swagger.io/specification/).
OpenAPI Specification (formerly called the Swagger Specification) is a specification that creates RESTful contract for APIs,
detailing all of its resources and operations in a human and machine-readable format for easy development, discovery, and integration.
The Swagger to Ballerina Code Generator can take existing Swagger definition files and generate Ballerina services from them.

## <a name="what-you-build"></a>  What you'll build
You'll build an RESTful web service using an OpenAPI / Swagger specification. This guide will walk you through building a pet store server from an OpenAPI / Swagger definition. The pet store service will have RESTful POST,PUT,GET and DELETE methods to handle pet data.

&nbsp; 
![alt text](https://github.com/rosensilva/open-api-based-service/blob/master/images/swagger_diagram.png)
&nbsp; 

## <a name="pre-req"></a> Prerequisites
 
* JDK 1.8 or later
* [Ballerina Distribution](https://ballerinalang.org/docs/quick-tour/quick-tour/#install-ballerina)
* A Text Editor or an IDE

Optional Requirements
- Ballerina IDE plugins. ( [IntelliJ IDEA](https://plugins.jetbrains.com/plugin/9520-ballerina), [VSCode](https://marketplace.visualstudio.com/items?itemName=WSO2.Ballerina), [Atom](https://atom.io/packages/language-ballerina))
- [Docker](https://docs.docker.com/engine/installation/)

## <a name="develop-app"></a> Develop the application
### Before you begin

#### Understand the Swagger / OpenAPI specification
The scenario that we use throughout this guide will base on a [OpenAPI / Swagger specification of a pet store web service](https://github.com/rosensilva/open-api-based-service/blob/master/petstore.json). The OpenAPI / Swagger specification
contains all the required details about the pet store RESTful API. Additionally, You can use the Swagger view in Ballerina Composer to create and edit OpenAPI / Swagger files. 

##### Basic structure of petstore Swagger/OpenAPI specification
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
NOTE :  The above OpenAPI / Swagger definition is only the basic structure. You can find the complete OpenAPI / Swagger definition in `open-api-based-service/petstore.json` file.

### Genarate the web service from the Swagger / OpenAPI definition

Ballerina language is capable of understanding the Swagger / OpenAPI specifications. You can easily generate the web service just by typing the following command structure in the terminal.
```
ballerina swagger skeleton <swaggerFile> [-d <output directory name>] [-p <package name>] 
```

For our pet store service you need to run the following command from the sample root directory(location where you have the petstore.json file) to generate the Ballerina service from the OpenAPI / Swagger definition

```bash 

$ ballerina swagger skeleton petstore.json -d guide/petstore/ballerinaPetstore.bal -p guide.petstore

```

The `-p` flag indicates the package name and `-d` flag indicates the file destination for the web service. These parameters are optional and can be used to have a customized package name and file location for the project.

#### Generated project structure 
After running the above command, the pet store web service will be auto-generated. You should see a package structure similar to the following,

```
├── guide
│   └── petstore
│       ├── ballerina_petstore.bal
│       └── ballerina_petstore_test.bal
└── petstore.json

```
The `guide.petstore` is the package for the pet store web service. You will have the skeleton of the service implementation. 

##### Generated `ballerina_petstore.bal` file
  
```ballerina
package guide.petstore;

import ballerina.net.http;


@http:configuration {
    host: "localhost",
    port: 9090,
    basePath: "/v1"
}
service<http> BallerinaPetstore {

    @http:resourceConfig {
        methods:["POST"],
        path:"/pet"
    }
    resource addPet (http:Connection conn, http:InRequest inReq) {
        //stub code - fill as necessary
        http:OutResponse resp = {};
        string payload = "Sample addPet Response";
        resp.setStringPayload(payload);
        _ = conn.respond(resp);
    }

    @http:resourceConfig {
        methods:["PUT"],
        path:"/pet"
    }
    resource updatePet (http:Connection conn, http:InRequest inReq) {
        //stub code - fill as necessary
        http:OutResponse resp = {};
        string payload = "Sample updatePet Response";
        resp.setStringPayload(payload);
        _ = conn.respond(resp);
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/pet/{petId}"
    }
    resource getPetById (http:Connection conn, http:InRequest inReq, string petId) {
        //stub de - fill as necessary
        http:OutResponse resp = {};
        string payload = "Sample getPetById Response";
        resp.setStringPayload(payload);
        _ = conn.respond(resp);
    }

    @http:resourceConfig {
        methods:["DELETE"],
        path:"/pet/{petId}"
    }
    resource deletePet (http:Connection conn, http:InRequest inReq, string petId) {
        //stub code - fill as necessary
        http:OutResponse resp = {};
        string payload = "Sample deletePet Response";
        resp.setStringPayload(payload);
        _ = conn.respond(resp);
    }
}

```

  Next we need to implement the business logic inside each RESTful resource and build the pet store web service.
  

### Implementation of the Ballerina web service

Now we have the Ballerina web service skeleton file. We only need to add the business logic inside each resource. For simplicity, we will use an in-memory map to store the pet data. The following code is the completed pet store web service implementation. 

```ballerina
package guide.petstore;

import ballerina.net.http;


@http:configuration {
    host:"localhost",
    port:9090,
    basePath:"/v1"
}
service<http> BallerinaPetstore {
    // Use in memory data map to store pet data
    map petData = {};

    @http:resourceConfig {
        methods:["POST"],
        path:"/pet"
    }
    resource addPet (http:Connection conn, http:InRequest inReq) {
        http:OutResponse resp = {};
        // Retrieve the json payload data of pets
        json petDataJson = inReq.getJsonPayload();
        var petId, payloadDataError = (string)petDataJson.id;

        // Add the pet details into the map
        petData[petId] = petDataJson;
        // Send back the status message back to the client
        string payload = "Pet added successfully : Pet ID = " + petId;
        resp.setStringPayload(payload);
        _ = conn.respond(resp);
    }

    @http:resourceConfig {
        methods:["PUT"],
        path:"/pet"
    }
    resource updatePet (http:Connection conn, http:InRequest inReq) {
        http:OutResponse resp = {};
        // Retrieve the payload data of pets
        json petUpdateData = inReq.getJsonPayload();
        var petId, payloadDataError = (string)petUpdateData.id;

        // Update the pet details into the map
        petData[petId] = petUpdateData;
        // Send back the status message back to the client
        string payload = "Pet details updated successfully : id = " + petId;
        resp.setStringPayload(payload);
        _ = conn.respond(resp);
    }

    @http:resourceConfig {
        methods:["GET"],
        path:"/pet/{petId}"
    }
    resource getPetById (http:Connection conn, http:InRequest inReq, string petId) {
        http:OutResponse resp = {};

        // Set the pet data as the payload and send back the response
        var payload, _ = (json)petData[petId];
        resp.setJsonPayload(payload);
        _ = conn.respond(resp);
    }

    @http:resourceConfig {
        methods:["DELETE"],
        path:"/pet/{petId}"
    }
    resource deletePet (http:Connection conn, http:InRequest inReq, string petId) {
        http:OutResponse resp = {};

        // Remove the pet data from the petData map
        petData.remove(petId);
        // Send the status back to the client
        string payload = "Deleted pet data successfully : Pet ID = " + petId;
        resp.setStringPayload(payload);
        _ = conn.respond(resp);
    }
}

```

With that, we have completed the implementation of the pet store web service.

## <a name="testing"></a> Testing 

### <a name="invoking"></a> Invoking the RESTful service 

You can run the RESTful service that you developed above, in your local environment. You need to have the Ballerina installation on your local machine and simply point to the <ballerina>/bin/ballerina binary to execute all the following steps.  

1. As the first step, you can build a Ballerina executable archive (.balx) of the service that we developed above, using the following command. It points to the directory structure of the service that we developed above and it will create an executable binary out of that. 

```
$ ballerina build guide/petstore/

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

### <a name="unit-testing"></a> Writing Unit Tests 

In ballerina, the unit test cases should be in the same package and the naming convention should be as follows,
* Test files should contain _test.bal suffix.
* Test functions should contain test prefix.
  * e.g.: testPetStore()

This guide contains unit test cases in the respective folders. The test cases are written to test the pet store web service.
To run the unit tests, go to the sample root directory and run the following command
```bash
$ ballerina test guide/petstore/
```

## <a name="deploying-the-scenario"></a> Deployment

Once you are done with the development, you can deploy the service using any of the methods that we listed below. 

### <a name="deploying-on-locally"></a> Deploying Locally
You can deploy the RESTful service that you developed above, in your local environment. You can use the Ballerina executable archive (.balx) archive that we created above and run it in your local environment as follows. 

```
ballerina run petstore.balx 
```


### <a name="deploying-on-docker"></a> Deploying on Docker

You can use the Ballerina executable (.balx) archive that we created above and create a docker image by using the following command. 
```
ballerina docker pet_store.balx  
```

Once you have created the docker image, you can run it using docker run. 

```
docker run -p <host_port>:9090 --name ballerina_pet_store -d pet_store:latest
```

### <a name="deploying-on-k8s"></a> Deploying on Kubernetes
(Work in progress) 


## <a name="observability"></a> Observability 


### <a name="logging"></a> Logging
(Work in progress) 

### <a name="metrics"></a> Metrics
(Work in progress) 


### <a name="tracing"></a> Tracing 
(Work in progress) 
