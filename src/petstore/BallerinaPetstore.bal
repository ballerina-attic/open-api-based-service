package petstore;

import ballerina/mime;
import ballerina/net.http.swagger;
import ballerina/net.http;

map petData = {};

// Service endpoint for the pet store
endpoint http:ServiceEndpoint ep0 {
    host:"localhost",
    port:9090
};

@swagger:ServiceInfo {
    title:"Ballerina Petstore",
    description:"This is a sample Petstore server. This uses swagger definitions to create the ballerina service",
    serviceVersion:"1.0.0",
    termsOfService:"http://ballerina.io/terms/",
    contact:{name:"", email:"samples@ballerina.io", url:""},
    license:{name:"Apache 2.0", url:"http://www.apache.org/licenses/LICENSE-2.0.html"},
    tags:[
         {name:"pet", description:"Everything about your Pets", externalDocs:{description:"Find out more", url:"http://ballerina.io"}}
         ],
    externalDocs:{description:"Find out more about Ballerina", url:"http://ballerina.io"},
    security:[
             ]
}
@http:ServiceConfig {
    basePath:"/v1"
}
service<http:Service> BallerinaPetstore bind ep0 {

    @swagger:ResourceInfo {
        tags:["pet"],
        summary:"Add a new pet to the store",
        description:"",
        externalDocs:{},
        parameters:[
                   ]
    }
    @http:ResourceConfig {
        methods:["POST"],
        path:"/pet"
    }
    addPet (endpoint outboundEp, http:Request req) {
        // Initialize the http response message
        http:Response resp = {};
        // Retrieve the data about pets from the json payload of the request
        var reqesetPayloadData = req.getJsonPayload();
        // Match the json payload with json and errors
        match reqesetPayloadData {
        // If the req.getJsonPayload() returns JSON
            json petDataJson => {
            // Transform into Pet data structure
                Pet petDetails =? <Pet>petDataJson;
                if (petDetails.id == "") {
                    // Send bad request message to the client if request doesn't contain valid pet id
                    resp.setStringPayload("Error : Please provide the json payload with `id`,`catogery` and `name`");
                    // set the response code as 400 to indicate a bad request
                    resp.statusCode = 400;
                    // Send the error message with the response
                    _ = outboundEp -> respond(resp);
                }
                else {
                    // Add the pet details into the in memory map
                    petData[petDetails.id] = petDetails;
                    // Send back the status message back to the client
                    string payload = "Pet added successfully : Pet ID = " + petDetails.id;
                    resp.setStringPayload(payload);
                    _ = outboundEp -> respond(resp);
                }
            }
            mime:EntityError => {
            // Send bad request message to the client if request doesn't contain valid pet data
                resp.setStringPayload("Error : Please provide the json payload with `id`,`catogery` and `name`");
                // set the response code as 400 to indicate a bad request
                resp.statusCode = 400;
                _ = outboundEp -> respond(resp);
            }
        }
    }

    @swagger:ResourceInfo {
        tags:["pet"],
        summary:"Update an existing pet",
        description:"",
        externalDocs:{},
        parameters:[
                   ]
    }
    @http:ResourceConfig {
        methods:["PUT"],
        path:"/pet"
    }
    updatePet (endpoint outboundEp, http:Request req) {
        // Initialize the http response message
        http:Response resp = {};
        // Retrieve the data about pets from the json payload of the request
        var reqesetPayloadData = req.getJsonPayload();
        // Match the json payload with json and errors
        match reqesetPayloadData {
        // If the req.getJsonPayload() returns JSON
            json petDataJson => {
            // Transform into Pet data structure
                Pet petDetails =? <Pet>petDataJson;
                if (petDetails.id == "" || !petData.hasKey(petDetails.id)) {
                    // Send bad request message to the client if request doesn't contain valid pet id
                    resp.setStringPayload("Error : Please provide the json payload with valid `id``");
                    // set the response code as 400 to indicate a bad request
                    resp.statusCode = 400;
                    _ = outboundEp -> respond(resp);
                }
                else {
                    // Update the pet details in the map
                    petData[petDetails.id] = petDetails;
                    // Send back the status message back to the client
                    string payload = "Pet updated successfully : Pet ID = " + petDetails.id;
                    resp.setStringPayload(payload);
                    _ = outboundEp -> respond(resp);
                }
            }

            mime:EntityError => {
            // Send bad request message to the client if request doesn't contain valid pet data
                resp.setStringPayload("Error : Please provide the json payload with `id`,`catogery` and `name`");
                // set the response code as 400 to indicate a bad request
                resp.statusCode = 400;
                _ = outboundEp -> respond(resp);
            }
        }
    }

    @swagger:ResourceInfo {
        tags:["pet"],
        summary:"Find pet by ID",
        description:"Returns a single pet",
        externalDocs:{},
        parameters:[
                   {
                       name:"petId",
                       inInfo:"path",
                       description:"ID of pet to return",
                       required:true,
                       allowEmptyValue:""
                   }
                   ]
    }
    @http:ResourceConfig {
        methods:["GET"],
        path:"/pet/{petId}"
    }
    getPetById (endpoint outboundEp, http:Request req, string petId) {
        // Initialize http response message to send back to the client
        http:Response resp = {};
        // Send bad request message to client if pet ID cannot found in petData map
        if (!petData.hasKey(petId)) {
            resp.setStringPayload("Error : Invalid Pet ID");
            // set the response code as 400 to indicate a bad request
            resp.statusCode = 400;
            _ = outboundEp -> respond(resp);
        }
        else {
            // Set the pet data as the payload and send back the response
            var payload = <string>petData[petId];
            resp.setStringPayload(payload);
            _ = outboundEp -> respond(resp);
        }
    }

    @swagger:ResourceInfo {
        tags:["pet"],
        summary:"Deletes a pet",
        description:"",
        externalDocs:{},
        parameters:[
                   {
                       name:"petId",
                       inInfo:"path",
                       description:"Pet id to delete",
                       required:true,
                       allowEmptyValue:""
                   }
                   ]
    }
    @http:ResourceConfig {
        methods:["DELETE"],
        path:"/pet/{petId}"
    }
    deletePet (endpoint outboundEp, http:Request req, string petId) {
        // Initialize http response message
        http:Response resp = {};
        // Send bad request message to client if pet ID cannot found in petData map
        if (!petData.hasKey(petId)) {
            resp.setStringPayload("Error : Invalid Pet ID");
            // set the response code as 400 to indicate a bad request
            resp.statusCode = 400;
            _ = outboundEp -> respond(resp);
        }
        else {
            // Remove the pet data from the petData map
            _ = petData.remove(petId);
            // Send the status back to the client
            string payload = "Deleted pet data successfully : Pet ID = " + petId;
            resp.setStringPayload(payload);
            _ = outboundEp -> respond(resp);
        }
    }

}
