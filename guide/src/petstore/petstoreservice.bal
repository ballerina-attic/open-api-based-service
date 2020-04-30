import ballerina/http;
import ballerina/openapi;

listener http:Listener ep0 = new(9090, config = {host: "localhost"});

@openapi:ServiceInfo {
    contract: "resources/petstore.json",
    tags: [ ]
}
@http:ServiceConfig {
    basePath: "/v1"
}
service petstoreservice on ep0 {

    @http:ResourceConfig {
        methods:["PUT"],
        path:"/pet", 
        body:"pet"
    }
    resource function updatePet(http:Caller caller, http:Request req, Pet pet ) returns error? {

    }

    @http:ResourceConfig {
        methods:["POST"],
        path:"/pet", 
        body:"pet"
    }
    resource function addPet(http:Caller caller, http:Request req, Pet pet ) returns error? {

    }

    @http:ResourceConfig {
        methods:["GET"],
        path:"/pet/{petId}"
    }
    resource function getPetById(http:Caller caller, http:Request req, string petId) returns error? {

    }

    @http:ResourceConfig {
        methods:["DELETE"],
        path:"/pet/{petId}"
    }
    resource function deletePet(http:Caller caller, http:Request req, string petId) returns error? {

    }

}
