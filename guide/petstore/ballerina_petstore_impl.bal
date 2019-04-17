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

import ballerina/http;
import ballerina/mime;
import ballerina/io;

map<Pet> petData = {};

public function addPet(http:Request req, Pet petDetails) returns http:Response {

    // Initialize the http response message
    http:Response resp = new;
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
    http:Response resp = new;
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
    http:Response resp = new;
    // Send bad request message to client if pet ID cannot found in petData map
    if (!petData.hasKey(petId)) {
        resp.setTextPayload("Error : Invalid Pet ID");
        // set the response code as 400 to indicate a bad request
        resp.statusCode = 400;
    }
    else {
        // Set the pet data as the payload and send back the response
        var payload = json.convert(petData[petId]);
        if (payload is json) {
            resp.setJsonPayload(untaint payload);
        }
    }
    return resp;
}

public function deletePet(http:Request req, string petId) returns http:Response {
    // Initialize http response message
    http:Response resp = new;
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
