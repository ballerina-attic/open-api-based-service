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
import ballerina.test;

function beforeTest () {
    // Start petStore service
    _ = test:startService("BallerinaPetstore");
}

function testPetStore () {
    // Create a connection with petStore service endpoint
    endpoint<http:HttpClient> httpEndpoint {
        create http:HttpClient("http://localhost:9090/v1", null);
    }

    // Prepare sample pet data to test the petStore service
    json samplePet = {"id":"1", "catogery":"dog", "name":"doggie"};
    json updatedPet = {"id":"1", "catogery":"dog-updated", "name":"Updated-doggie"};

    // Initialize the empty http request and response
    http:OutRequest req = {};
    http:InResponse resp = {};

    // Test the addPet resource
    req.setJsonPayload(samplePet);
    // Send a request to the pet store service
    resp, _ = httpEndpoint.post("/pet", req);
    test:assertIntEquals(resp.statusCode, 200, "pet store service didnot respond with 200 OK signal");
    string expectedOutputString = "Pet added successfully : Pet ID = 1";
    // Assert the response message payload string
    test:assertStringEquals(resp.getStringPayload(), expectedOutputString, "Reponse message not matched");

    // Test the updatePet resource
    req = {};
    req.setJsonPayload(updatedPet);
    // Send a request to the pet store service
    resp, _ = httpEndpoint.put("/pet", req);
    test:assertIntEquals(resp.statusCode, 200, "pet store service didnot respond with 200 OK signal");
    expectedOutputString = "Pet details updated successfully : id = 1";
    // Assert the response message payload string
    test:assertStringEquals(resp.getStringPayload(), expectedOutputString, "Reponse message not matched");

    // Test the getPetById resource
    req = {};
    // Send a request to the pet store service
    resp, _ = httpEndpoint.get("/pet/1", req);
    test:assertIntEquals(resp.statusCode, 200, "pet store service didnot respond with 200 OK signal");
    // Assert the response message payload string
    test:assertStringEquals(resp.getJsonPayload().toString(), updatedPet.toString(), "Reponse message not matched");

    // Test the deletePet resource
    req = {};
    // Send a request to the pet store service
    resp, _ = httpEndpoint.delete("/pet/1", req);
    test:assertIntEquals(resp.statusCode, 200, "pet store service didnot respond with 200 OK signal");
    expectedOutputString = "Deleted pet data successfully : Pet ID = 1";
    // Assert the response message payload string
    test:assertStringEquals(resp.getStringPayload(), expectedOutputString, "Reponse message not matched");
}
