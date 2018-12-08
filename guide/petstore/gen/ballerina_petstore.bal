// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/log;
import ballerina/http;
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
        {name: "pet", description: "Everything about your Pets", externalDocs: { description: "Find out more", url: "http://ballerina.io" } }
    ],
    externalDocs: { description: "Find out more about Ballerina", url: "http://ballerina.io" },
    security: [
    ]
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
