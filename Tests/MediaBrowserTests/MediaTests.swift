//
//  MediaTests.swift
//  MediaBrowserTests
//
//  Deterministic unit tests for the Media model's construction and identity.
//  These run headlessly on the simulator (no image loading / network) and pin
//  the public initializers the browser relies on.
//

import XCTest
import UIKit
@testable import MediaBrowser

final class MediaTests: XCTestCase {

    func testImageInitHasEmptyCaptionByDefault() {
        let media = Media(image: UIImage())
        XCTAssertEqual(media.caption, "")
        XCTAssertFalse(media.isVideo)
    }

    func testImageWithCaptionInitStoresCaption() {
        let media = Media(image: UIImage(), caption: "A photo")
        XCTAssertEqual(media.caption, "A photo")
    }

    func testURLWithCaptionInitStoresCaption() {
        let media = Media(url: URL(string: "https://example.com/a.jpg")!, caption: "Remote")
        XCTAssertEqual(media.caption, "Remote")
    }

    func testVideoInitMarksAsVideoAndStoresURL() {
        let url = URL(string: "https://example.com/movie.mp4")!
        let media = Media(videoURL: url)

        XCTAssertTrue(media.isVideo)
        XCTAssertEqual(media.videoURL, url)
        // No preview image supplied → still considered "empty".
        XCTAssertTrue(media.emptyImage)
    }

    func testVideoInitWithPreviewIsNotEmpty() {
        let media = Media(
            videoURL: URL(string: "https://example.com/movie.mp4")!,
            previewImageURL: URL(string: "https://example.com/preview.jpg")!
        )
        XCTAssertFalse(media.emptyImage)
    }

    func testSettingVideoURLMarksAsVideo() {
        let media = Media(image: UIImage())
        XCTAssertFalse(media.isVideo)

        media.videoURL = URL(string: "https://example.com/clip.mov")!

        XCTAssertTrue(media.isVideo)
    }

    func testEqualsIsIdentityBased() {
        let a = Media(image: UIImage())
        let b = Media(image: UIImage())

        XCTAssertTrue(a.equals(photo: a))
        XCTAssertFalse(a.equals(photo: b))
    }
}
