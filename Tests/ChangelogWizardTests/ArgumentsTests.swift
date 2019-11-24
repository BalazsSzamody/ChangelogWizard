//
//  ArgumentsTests.swift
//  
//
//  Created by Balazs Szamody on 24/11/19.
//

import Foundation
import XCTest
@testable import _ChangelogWizard

class ArgumentsTests: XCTestCase {
    
    func testParse() {
        do {
            let args = Mocks.args
            
            let sut = try Argument.parse(args)
            
            XCTAssertEqual(sut.count, 7)
        } catch {
            XCTFail(error.nsError().localizedDescription)
        }
    }
    
    func testBlockTag() {
        do {
            let args = "--block-tag TEST"
                .components(separatedBy: " ")
            let sut = try Argument.parse(args).first
            XCTAssertNotNil(sut)
            guard case Argument.blockTag(let name) = sut! else {
                XCTFail("Incorrect argument")
                return
            }
            XCTAssertEqual(name, "[TEST]")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testTitles() {
        do {
            let args = "--tags a b --titles test_a test_b"
                .components(separatedBy: " ")
            let sut = try Argument.parse(args).last
            XCTAssertNotNil(sut)
            guard case Argument.titles(let titles) = sut! else {
                XCTFail("Incorrect Argument")
                return
            }
            XCTAssertEqual(titles, ["test a", "test b"])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testTagsWithoutTitles() {
        do {
            let args = "--tags a b"
                .components(separatedBy: " ")
            _ = try Argument.parse(args)
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertEqual(error.nsError().localizedDescription, "Please provide both or neither tags and titles. Tags found, Titles not found")
        }
    }
    
    func testGetParams_OneParam_Last() {
        let sut = "--test param1".components(separatedBy: " ")
        let result = Argument.getParams(from: sut, forArgIndex: 0)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first, "param1")
    }
    
    func testGetParams_OneParam_NotLast() {
        let sut = "--test param1 --test".components(separatedBy: " ")
        let result = Argument.getParams(from: sut, forArgIndex: 0)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first, "param1")
    }
    
    func testGetParams_MoreParams_Last() {
        let sut = "--test param1 param2".components(separatedBy: " ")
        let result = Argument.getParams(from: sut, forArgIndex: 0)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result, ["param1", "param2"])
    }
    
    func testGetParams_MoreParams_NotFirst() {
        let sut = "--test --test param1 param2".components(separatedBy: " ")
        let result = Argument.getParams(from: sut, forArgIndex: 1)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result, ["param1", "param2"])
    }
}
