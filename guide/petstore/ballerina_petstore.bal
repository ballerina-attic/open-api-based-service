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
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

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

        // Send bad request message to the client if request doesn't contain pet data
        if (payloadDataError != null) {
            resp.setStringPayload("Error : Please provide the json payload with `id`,`catogery` and `name`");
            // set the response code as 400 to indicate a bad request
            resp.statusCode = 400;
            _ = conn.respond(resp);
            return;
        }
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

        // Send bad request message to the client if request doesn't contain valid pet data
        if (payloadDataError != null || !petData.hasKey(petId)) {
            resp.setStringPayload("Error : Please provide the json payload with valid `id`,`catogery` and `name`");
            // set the response code as 400 to indicate a bad request
            resp.statusCode = 400;
            _ = conn.respond(resp);
            return;
        }
        // Update the pet details in the map
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

        // Send bad request message to client if pet ID cannot found in petData map
        if (!petData.hasKey(petId)) {
            resp.setStringPayload("Error : Invalid Pet ID");
            // set the response code as 400 to indicate a bad request
            resp.statusCode = 400;
            _ = conn.respond(resp);
        }
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

        // Send bad request message to client if pet ID cannot found in petData map
        if (!petData.hasKey(petId)) {
            resp.setStringPayload("Error : Invalid Pet ID");
            // set the response code as 400 to indicate a bad request
            resp.statusCode = 400;
            _ = conn.respond(resp);
        }
        // Remove the pet data from the petData map
        petData.remove(petId);
        // Send the status back to the client
        string payload = "Deleted pet data successfully : Pet ID = " + petId;
        resp.setStringPayload(payload);
        _ = conn.respond(resp);
    }
}
