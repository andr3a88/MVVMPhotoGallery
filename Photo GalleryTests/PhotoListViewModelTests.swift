//
//  PhotoListViewModelTests.swift
//  Photo GalleryTests
//
//  Created by Andrea on 27/02/2018.
//  Copyright © 2018 Andrea Stevanato. All rights reserved.
//

import XCTest
@testable import Photo_Gallery

// We used a MockAPIService to check:
//
// If the SUT correctly interacts with the APIService.
// If the SUT handles the error state correctly.
// If the SUT handles the user interaction correctly.

class PhotoListViewModelTests: XCTestCase {

    var sut: PhotoListViewModel!
    var mockPhotoService: MockPhotoService!

    override func setUp() {
        super.setUp()
        mockPhotoService = MockPhotoService()
        sut = PhotoListViewModel(apiService: mockPhotoService)
    }

    override func tearDown() {
        sut = nil
        mockPhotoService = nil
        super.tearDown()
    }


    /// The PhotoListViewModel should fetch data from the APIService.
    func test_fetch_photo() {
        // Given
        mockPhotoService.completePhotos = [Photo]()

        // When
        sut.initFetch()

        // Assert
        XCTAssert(mockPhotoService!.isFetchPopularPhotoCalled)
    }

    /// Simulate the success and failure networking states by changing the response of the MockAPIService
    /// The PhotoListViewModel should display an error message if the request failed.
    func test_fetch_photo_fail() {

        // Given a failed fetch with a certain failure
        let error = APIError.permissionDenied

        // When
        sut.initFetch()

        mockPhotoService.fetchFail(error: error)

        // Sut should display predefined error message
        XCTAssertEqual(sut.alertMessage, error.rawValue)
    }

    /// The PhotoListViewModel should allow the segue to the detail page if a user presses on a “for sale” photo.
    func test_user_press_for_sale_item() {

        let indexPath = IndexPath(row: 0, section: 0)

        //Given some photo stubs
        mockPhotoService.completePhotos = StubGenerator().stubPhotos()

        sut.initFetch() // Fetch stubs
        mockPhotoService.fetchSuccess()

        //When User press a specific cell (a for sale photo stub)
        sut.userPressed( at: indexPath )

        XCTAssertTrue( sut.isAllowSegue )
    }

    func test_create_cell_view_model() {
        // Given
        let photos = StubGenerator().stubPhotos()
        mockPhotoService.completePhotos = photos
        let expect = XCTestExpectation(description: "reload closure triggered")
        sut.reloadTableViewClosure = { () in
            expect.fulfill()
        }

        // When
        sut.initFetch()
        mockPhotoService.fetchSuccess()

        // Number of cell view model is equal to the number of photos
        XCTAssertEqual( sut.numberOfCells, photos.count )

        // XCTAssert reload closure triggered
        wait(for: [expect], timeout: 1.0)

    }

    func test_loading_when_fetching() {

        //Given
        var loadingStatus = false
        let expect = XCTestExpectation(description: "Loading status updated")
        sut.updateLoadingStatus = { [weak sut] in
            loadingStatus = sut!.isLoading
            expect.fulfill()
        }

        //when fetching
        sut.initFetch()

        // Assert
        XCTAssertTrue( loadingStatus )

        // When finished fetching
        mockPhotoService!.fetchSuccess()
        XCTAssertFalse( loadingStatus )

        wait(for: [expect], timeout: 1.0)
    }

    func test_user_press_not_for_sale_item() {

        //Given a sut with fetched photos
        let indexPath = IndexPath(row: 4, section: 0)
        goToFetchPhotoFinished()

        let expect = XCTestExpectation(description: "Alert message is shown")
        sut.showAlertClosure = { [weak sut] in
            expect.fulfill()
            XCTAssertEqual(sut!.alertMessage, "This item is not for sale")
        }

        //When
        sut.userPressed( at: indexPath )

        //Assert
        XCTAssertFalse( sut.isAllowSegue )
        XCTAssertNil( sut.selectedPhoto )

        wait(for: [expect], timeout: 1.0)
    }

    func test_get_cell_view_model() {

        //Given a sut with fetched photos
        goToFetchPhotoFinished()

        let indexPath = IndexPath(row: 1, section: 0)
        let testPhoto = mockPhotoService.completePhotos[indexPath.row]

        // When
        let vm = sut.getCellViewModel(at: indexPath)

        //Assert
        XCTAssertEqual( vm.titleText, testPhoto.name)

    }

    func test_cell_view_model() {
        //Given photos
        let today = Date()
        let photo = Photo(identifier: 1, name: "Name", description: "desc", createdAt: today, imageUrl: "url", forSale: true, camera: "camera")
        let photoWithoutCamera = Photo(identifier: 1, name: "Name", description: "desc", createdAt: Date(), imageUrl: "url", forSale: true, camera: nil)
        let photoWithoutDesc = Photo(identifier: 1, name: "Name", description: nil, createdAt: Date(), imageUrl: "url", forSale: true, camera: "camera")
        let photoWithouCameraAndDesc = Photo(identifier: 1, name: "Name", description: nil, createdAt: Date(), imageUrl: "url", forSale: true, camera: nil)

        // When creat cell view model
        let cellViewModel = sut!.createCellViewModel( photo: photo )
        let cellViewModelWithoutCamera = sut!.createCellViewModel( photo: photoWithoutCamera )
        let cellViewModelWithoutDesc = sut!.createCellViewModel( photo: photoWithoutDesc )
        let cellViewModelWithoutCameraAndDesc = sut!.createCellViewModel( photo: photoWithouCameraAndDesc )

        // Assert the correctness of display information
        XCTAssertEqual( photo.name, cellViewModel.titleText )
        XCTAssertEqual( photo.imageUrl, cellViewModel.imageUrl )

        XCTAssertEqual(cellViewModel.descText, "\(photo.camera!) - \(photo.description!)" )
        XCTAssertEqual(cellViewModelWithoutDesc.descText, photoWithoutDesc.camera! )
        XCTAssertEqual(cellViewModelWithoutCamera.descText, photoWithoutCamera.description! )
        XCTAssertEqual(cellViewModelWithoutCameraAndDesc.descText, "" )

        let year = Calendar.current.component(.year, from: today)
        let month = Calendar.current.component(.month, from: today)
        let day = Calendar.current.component(.day, from: today)

        XCTAssertEqual( cellViewModel.dateText, String(format: "%d-%02d-%02d", year, month, day) )

    }
}

//MARK: State control
extension PhotoListViewModelTests {
    private func goToFetchPhotoFinished() {
        mockPhotoService.completePhotos = StubGenerator().stubPhotos()
        sut.initFetch()
        mockPhotoService.fetchSuccess()
    }
}

class StubGenerator {
    func stubPhotos() -> [Photo] {
        let path = Bundle.main.path(forResource: "data", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let photos = try! decoder.decode(Photos.self, from: data)
        return photos.photos
    }
}
