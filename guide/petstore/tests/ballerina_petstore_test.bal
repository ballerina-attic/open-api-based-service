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

// Create a connection with petStore service endpoint
endpoint http:Client httpEndpoint {
    url: "http://localhost:9090/v1"
};

function beforeFunction() {
    // Start petStore service
    _ = test:startServices("petstore");
}

function afterFunction() {
    // Start petStore service
    test:stopServices("petstore");
}


@test:Config {
    before: "beforeFunction",
    after: "afterFunction"
}
function testPetStore() {
    // Prepare sample pet data to test the petStore service
    json samplePet = { "id": 1, "category": "dog", "name": "doggie" };
    json updatedPet = { "id": 1, "category": "dog-updated", "name": "Updated-doggie" };

    // Initialize the empty http request and response
    http:Request req;
    http:Response resp;

    // Test the addPet resource
    req.setJsonPayload(samplePet);
    // Send a request to the pet store service
    resp = check httpEndpoint->post("/pet", req);
    test:assertEquals(resp.statusCode, 200, msg =
        "pet store service didnot respond with 200 OK signal");
    string expectedOutputString = "Pet added successfully : Pet ID = 1";
    // Assert the response message payload string
    var receivedPayload1 = resp.getTextPayload();
    match receivedPayload1 {
        string receivedString => {
            test:assertEquals(receivedString, expectedOutputString, msg =
                "Reponse message not matched");
        }
        error|() => {
            return;
        }
    }

    // Test the updatePet resource
    req = new;
    req.setJsonPayload(updatedPet);
    // Send a request to the pet store service
    resp = check httpEndpoint->put("/pet", req);
    test:assertEquals(resp.statusCode, 200, msg =
        "pet store service didnot respond with 200 OK signal");
    expectedOutputString = "Pet updated successfully : Pet ID = 1";
    // Assert the response message payload string
    var receivedPayload2 = resp.getTextPayload();
    match receivedPayload2 {
        string receivedString => {
            test:assertEquals(receivedString, expectedOutputString, msg =
                "Reponse message not matched");
        }
        error|() => {
            return;
        }
    }
    // Test the getPetById resource
    req = new;
    // Send a request to the pet store service
    resp = check httpEndpoint->get("/pet/1");
    test:assertEquals(resp.statusCode, 200, msg =
        "pet store service didnot respond with 200 OK signal");
    // Assert the response message payload string
    var receivedPayload3 = resp.getJsonPayload();
    match receivedPayload3 {
        json receivedJson => {
            test:assertEquals(receivedJson, expectedOutputString, msg =
                "Reponse message not matched");
        }
        error|() => {
            return;
        }
    }
    // Test the deletePet resource
    req = new;
    // Send a request to the pet store service
    resp = check httpEndpoint->delete("/pet/1", req);
    test:assertEquals(resp.statusCode, 200, msg =
        "pet store service didnot respond with 200 OK signal");
    expectedOutputString = "Deleted pet data successfully : Pet ID = 1";
    // Assert the response message payload string
    var receivedPayload4 = resp.getTextPayload();
    match receivedPayload4 {
        string receivedString => {
            test:assertEquals(receivedString, expectedOutputString, msg =
                "Reponse message not matched");
        }
        error|() => {
            return;
        }
    }
}
