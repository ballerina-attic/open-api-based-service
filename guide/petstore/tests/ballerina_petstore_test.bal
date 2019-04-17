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

import ballerina/http;
import ballerina/test;
import ballerina/io;

// Create a connection with petStore service endpoint
http:Client httpEndpoint = new("http://localhost:9090/v1");

@test:Config
function testPetStore() {
    // Prepare sample pet data to test the petStore service
    json samplePet = { "id": 1, "category": "dog", "name": "doggie" };
    json updatedPet = { "id": 1, "category": "dog-updated", "name": "Updated-doggie" };

    // Initialize the empty http request and response
    http:Request req = new;
    string expectedOutputString;

    // Test the addPet resource
    req.setJsonPayload(samplePet);
    // Send a request to the pet store service
    var resp = httpEndpoint->post("/pet", req);
    if (resp is http:Response) {
        test:assertEquals(resp.statusCode, 200, msg =
            "pet store service did not respond with 200 OK signal");
        expectedOutputString = "Pet added successfully : Pet ID = 1";
        // Assert the response message payload string
        var receivedPayload1 = resp.getTextPayload();
        if (receivedPayload1 is string) {
            test:assertEquals(receivedPayload1, expectedOutputString, msg =
                    "Reponse message not matched");
        }
    } else {
        test:assertFail(msg = "Failed to obtain response:");
    }

    // Test the updatePet resource
    req = new;
    req.setJsonPayload(updatedPet);
    // Send a request to the pet store service
    resp = httpEndpoint->put("/pet", req);
    if (resp is http:Response) {
        test:assertEquals(resp.statusCode, 200, msg =
            "pet store service did not respond with 200 OK signal");
        expectedOutputString = "Pet updated successfully : Pet ID = 1";
        // Assert the response message payload string
        var receivedPayload2 = resp.getTextPayload();
        if (receivedPayload2 is string) {
            test:assertEquals(receivedPayload2, expectedOutputString, msg =
                    "Reponse message not matched");
        }
    } else {
        test:assertFail(msg = "Failed to obtain response:");
    }

    // Test the getPetById resource
    req = new;
    // Send a request to the pet store service
    resp = httpEndpoint->get("/pet/1");
    if (resp is http:Response) {
        test:assertEquals(resp.statusCode, 200, msg =
            "pet store service did not respond with 200 OK signal");
        // Assert the response message payload string
        var receivedPayload3 = resp.getJsonPayload();
        if (receivedPayload3 is json) {
            expectedOutputString = "{\"id\":\"1\", \"category\":\"dog-updated\", \"name\":\"Updated-doggie\"}";
            test:assertEquals(receivedPayload3.toString(), expectedOutputString, msg =
                    "Reponse message not matched");
        }
    } else {
        test:assertFail(msg = "Failed to obtain response:");
    }

    // Test the deletePet resource
    req = new;
    // Send a request to the pet store service
    resp = httpEndpoint->delete("/pet/1", req);
    if (resp is http:Response) {
        test:assertEquals(resp.statusCode, 200, msg =
            "pet store service did not respond with 200 OK signal");
        expectedOutputString = "Deleted pet data successfully : Pet ID = 1";
        // Assert the response message payload string
        var receivedPayload4 = resp.getTextPayload();
        if (receivedPayload4 is string) {
            test:assertEquals(receivedPayload4, expectedOutputString, msg =
                    "Reponse message not matched");
        }
    } else {
        test:assertFail(msg = "Failed to obtain response:");
    }
}
