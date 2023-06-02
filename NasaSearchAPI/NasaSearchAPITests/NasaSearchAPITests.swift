//
//  NasaSearchAPITests.swift
//  NasaSearchAPITests
//
//  Created by Michael A Edgcumbe on 6/1/23.
//

import XCTest
@testable import NasaSearchAPI

class DelegateMock: SearchViewModelDelegate {
    var modelDidUpdateQueryCalled = false
    var modelDidUpdateCalled = false
    
    func modelDidUpdateQuery() {
        modelDidUpdateQueryCalled = true
    }
    
    func modelDidUpdate(with response: NasaSearchAPI.NASASearchResponse) {
        modelDidUpdateCalled = true
    }
}

class NetworkMock : NetworkProtocol {
    var responseData: Data?
    var error: Error?
    
    func fetch(endpoint: String, from server: URL, with queryItems: [URLQueryItem]?) async throws -> Data {
        if let error = error {
            throw error
        }
        
        guard let responseData = responseData else {
            fatalError("Response data not set in NetworkMock")
        }
        
        return responseData
    }
}

final class NasaSearchAPITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func setupMocks() -> (networkMock: NetworkMock, delegateMock: DelegateMock) {
        let networkMock = NetworkMock()
        let delegateMock = DelegateMock()
        
        // Configure networkMock
        // Add any necessary properties or methods to simulate network behavior
        // For example:
        
        let data = """
        {
        \"collection\" :     {
            \"href\" : \"http://images-api.nasa.gov/search?q=Moon&page=1&media_type=image\",
            \"items\" :         [
                            {
                    \"data\" :                 [
                                            {
                            \"center\" : \"JPL\",
                            \"date_created\" : \"2009-09-24T18:00:22Z\",
                            \"description\" : \"Nearside of the Moon\",
                            \"description_508\" : \"Nearside of the Moon\",
                            \"keywords\" :                         [
                                \"Moon\",
                                \"Chandrayaan-1\"
                            ],
                            \"media_type\" : \"image\",
                            \"nasa_id\" : \"PIA12235\",
                            \"secondary_creator\" : \"ISRO/NASA/JPL-Caltech/Brown Univ.\",
                            \"title\" : \"Nearside of the Moon\"
                        }
                    ],
                    \"href\" : \"https://images-assets.nasa.gov/image/PIA12235/collection.json\",
                    \"links\" :                 [
                                            {
                            \"href\" : \"https://images-assets.nasa.gov/image/PIA12235/PIA12235~thumb.jpg\",
                            \"rel\" : \"preview\",
                            \"render\" : \"image\"
                        }
                    ]
                }
            ],
            \"links\" :         [
                            {
                    \"href\" : \"http://images-api.nasa.gov/search?q=Moon&page=2&media_type=image\",
                    \"prompt\" : \"Next\",
                    \"rel\" : \"next\"
                }
            ],
            \"metadata\" :         {
                \"total_hits\" : 13873
            },
            \"version\" : \"1.0\"
        }
        }
        """.data(using: .utf8)!
        
        networkMock.responseData = data
        networkMock.error = nil
        
        // Configure delegateMock
        // Add any necessary properties or methods to track delegate calls or simulate delegate behavior
        // For example:
        delegateMock.modelDidUpdateQueryCalled = false
        delegateMock.modelDidUpdateCalled = false
        
        return (networkMock, delegateMock)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testQueryChange() async throws {
        
        let (networkMock, delegateMock) = setupMocks()
        
        // Create the object that contains the function being tested
        let viewModel = SearchViewModel()
        
        // Set the network and delegate objects
        viewModel.network = networkMock
        viewModel.delegate = delegateMock
        
        // Set initial query
        try await viewModel.search(for: "moon")
        
        // Verify initial state
        XCTAssertEqual(viewModel.currentQuery, "moon")
        XCTAssertEqual(viewModel.lastPage, 1)
        XCTAssertEqual(viewModel.allCollections.count, 0)
        
        // Search with a different query
        try await viewModel.search(for: "sun")
        
        // Verify query change
        XCTAssertEqual(viewModel.currentQuery, "sun")
        XCTAssertEqual(viewModel.lastPage, 1)
        XCTAssertEqual(viewModel.allCollections.count, 0)
        
        // Verify delegate method called
        XCTAssertTrue(delegateMock.modelDidUpdateQueryCalled)
    }
    
    func testSuccessfulNetworkRequest() async throws {
        let (networkMock, delegateMock) = setupMocks()
        
        // Create the object that contains the function being tested
        let viewModel = SearchViewModel()
        
        // Set the network and delegate objects
        viewModel.network = networkMock
        viewModel.delegate = delegateMock
                
        // Perform search
        try await viewModel.search(for: "moon")
        
        let expectation = self.expectation(description: "Test")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation])
        
        // Verify delegate method called
        XCTAssertTrue(delegateMock.modelDidUpdateCalled)
    }
    
    func testNetworkRequestFailure() async throws {
        let (networkMock, delegateMock) = setupMocks()
        
        // Create the object that contains the function being tested
        let viewModel = SearchViewModel()
        
        // Set the network and delegate objects
        viewModel.network = networkMock
        viewModel.delegate = delegateMock
        
        // Set up mock network error
        let error = NetworkError.MockError
        networkMock.error = error
        
        // Perform search
        do {
            try await viewModel.search(for: "Moon")
            XCTFail("Expected error to be thrown")
        } catch {
            // Verify error handling
            XCTAssertEqual(error as! NetworkError, NetworkError.MockError)
        }
        
        // Verify delegate method not called
        XCTAssertFalse(delegateMock.modelDidUpdateCalled)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
