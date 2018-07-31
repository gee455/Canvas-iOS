//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest

class CKILiveAssessmentResultNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /*
    func testCreateLiveAssessments() {
        let client = MockCKIClient()
        let liveAssessmentDictionary = Helpers.loadJSONFixture("live_assessment") as NSDictionary
        let liveAssessment = CKILiveAssessment(fromJSONDictionary: liveAssessmentDictionary)
        
        client.createLiveAssessments([liveAssessment])
        
        // TODO not currently testible with default of nil for context in CKILiveAssessment
        // get CKILiveAssessmentNetworkingTests working and this will work
        XCTAssertEqual(client.capturedPath!, "/api/v1/<not sure yet what to put here>", "CKILiveAssessment returned API path for testCreateLiveAssessments was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Create, "CKILiveAssessment API Interaction Method was incorrect")
    }
*/
}
