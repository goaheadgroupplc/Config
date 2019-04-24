//
//  ConfigurationPropertyTests.swift
//  Config
//
//  Created by David Hardiman on 17/04/2019.
//

@testable import Config
import Foundation
import Nimble
import XCTest

class ConfigurationPropertyTests: XCTestCase {
    func givenAStringProperty() -> ConfigurationProperty<String>? {
        return ConfigurationProperty<String>(key: "test", typeHint: "String", dict: [
            "defaultValue": "test value",
            "overrides": [
                "hello": "hello value",
                "pattern": "pattern value"
            ]
        ])
    }

    func whenTheDeclarationIsWritten<T>(for configurationProperty: ConfigurationProperty<T>?, scheme: String = "any", encryptionKey: String? = nil, isPublic: Bool = false, requiresNonObjC: Bool = false, indentWidth: Int = 0) throws -> String? {
        let iv = try IV(dict: ["initialise": "me"])
        print("\(iv.hash)")
        return configurationProperty?.propertyDeclaration(for: scheme, iv: iv, encryptionKey: encryptionKey, requiresNonObjCDeclarations: requiresNonObjC, isPublic: isPublic, indentWidth: indentWidth)
    }

    func testItCanWriteADeclarationForAStringPropertyUsingTheDefaultValue() throws {
        let stringProperty = givenAStringProperty()
        let expectedValue = #"    static let test: String = "test value""#
        let actualValue = try whenTheDeclarationIsWritten(for: stringProperty)
        expect(actualValue).to(equal(expectedValue))
    }

    func testItAddsAPublicAccessorWhenRequired() throws {
        let stringProperty = givenAStringProperty()
        let expectedValue = #"    public static let test: String = "test value""#
        let actualValue = try whenTheDeclarationIsWritten(for: stringProperty, isPublic: true)
        expect(actualValue).to(equal(expectedValue))
    }

    func testItCaIndentADeclaration() throws {
        let stringProperty = givenAStringProperty()
        let expectedValue = #"                static let test: String = "test value""#
        let actualValue = try whenTheDeclarationIsWritten(for: stringProperty, indentWidth: 3)
        expect(actualValue).to(equal(expectedValue))
    }

    func testItWritesNoObjCPropertiesWhenRequired() throws {
        let stringProperty = givenAStringProperty()
        let expectedValue = """
            @nonobjc static var test: String {
                return "test value"
            }
        """
        let actualValue = try whenTheDeclarationIsWritten(for: stringProperty, requiresNonObjC: true)
        expect(actualValue).to(equal(expectedValue))
    }

    func testItCanGetAnOverrideForAnExactMatch() throws {
        let stringProperty = givenAStringProperty()
        let expectedValue = #"    static let test: String = "hello value""#
        let actualValue = try whenTheDeclarationIsWritten(for: stringProperty, scheme: "hello")
        expect(actualValue).to(equal(expectedValue))
    }

    func testItCanGetAnOverrideForAPatternMatch() throws {
        let stringProperty = givenAStringProperty()
        let expectedValue = #"    static let test: String = "pattern value""#
        let actualValue = try whenTheDeclarationIsWritten(for: stringProperty, scheme: "match-a-pattern")
        expect(actualValue).to(equal(expectedValue))
    }

    func testItCanWriteADescriptionAsAComment() throws {
        let stringProperty = ConfigurationProperty<String>(key: "test", typeHint: "String", dict: [
            "defaultValue": "test value",
            "description": "A comment to add"
        ])
        let expectedValue = """
            /// A comment to add
            static let test: String = "test value"
        """
        let actualValue = try whenTheDeclarationIsWritten(for: stringProperty)
        expect(actualValue).to(equal(expectedValue))
    }

    func testItCanWriteAURLProperty() throws {
        let urlProperty = ConfigurationProperty<String>(key: "test", typeHint: "URL", dict: [
            "defaultValue": "https://www.google.com",
        ])
        let expectedValue = #"    static let test: URL = URL(string: "https://www.google.com")!"#
        let actualValue = try whenTheDeclarationIsWritten(for: urlProperty)
        expect(actualValue).to(equal(expectedValue))
    }

    func testItCanWriteAnIntProperty() throws {
        let intProperty = ConfigurationProperty<Int>(key: "test", typeHint: "Int", dict: [
            "defaultValue": 2,
        ])
        let expectedValue = #"    static let test: Int = 2"#
        let actualValue = try whenTheDeclarationIsWritten(for: intProperty)
        expect(actualValue).to(equal(expectedValue))
    }

    func testItCanWriteADoubleProperty() throws {
        let doubleProperty = ConfigurationProperty<Double>(key: "test", typeHint: "Double", dict: [
            "defaultValue": 2.3,
        ])
        let expectedValue = #"    static let test: Double = 2.3"#
        let actualValue = try whenTheDeclarationIsWritten(for: doubleProperty)
        expect(actualValue).to(equal(expectedValue))
    }

    func testItCanWriteAFloatProperty() throws {
        let floatProperty = ConfigurationProperty<Double>(key: "test", typeHint: "Float", dict: [
            "defaultValue": 2.3,
        ])
        let expectedValue = #"    static let test: Float = 2.3"#
        let actualValue = try whenTheDeclarationIsWritten(for: floatProperty)
        expect(actualValue).to(equal(expectedValue))
    }

    func testItCanWriteABoolProperty() throws {
        let floatProperty = ConfigurationProperty<Bool>(key: "test", typeHint: "Bool", dict: [
            "defaultValue": true,
            ])
        let expectedValue = #"    static let test: Bool = true"#
        let actualValue = try whenTheDeclarationIsWritten(for: floatProperty)
        expect(actualValue).to(equal(expectedValue))
    }

    func testItCanWriteStringArrayProperty() throws {
        let stringArrayProperty = ConfigurationProperty<[String]>(key: "test", typeHint: "[String]", dict: [
            "defaultValue": [
                "one",
                "two"
            ]
        ])
        let expectedValue = #"    static let test: [String] = ["one", "two"]"#
        let actualValue = try whenTheDeclarationIsWritten(for: stringArrayProperty)
        expect(actualValue).to(equal(expectedValue))
    }

    func testItCanWriteAColourProperty() throws {
        let colourProperty = ConfigurationProperty<String>(key: "test", typeHint: "Colour", dict: [
            "defaultValue": "#FF0000",
        ])
        let expectedValue = #"    static let test: UIColor = UIColor(red: 255.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)"#
        let actualValue = try whenTheDeclarationIsWritten(for: colourProperty)
        expect(actualValue).to(equal(expectedValue))
    }

    func testItCanWriteAnImageProperty() throws {
        let imageProperty = ConfigurationProperty<String>(key: "test", typeHint: "Image", dict: [
            "defaultValue": "image-name",
        ])
        let expectedValue = #"    static let test: UIImage = UIImage(named: "image-name")!"#
        let actualValue = try whenTheDeclarationIsWritten(for: imageProperty)
        expect(actualValue).to(equal(expectedValue))
    }

    func testItCanWriteAnEncryptedValue() throws {
        // Note: this test doesn't test the encryption itself, that test will be written elsewhere
        let secretProperty = ConfigurationProperty<String>(key: "test", typeHint: "Encrypted", dict: [
            "defaultValue": "top-secret",
        ])
        let expectedValue = "    static let test: [UInt8] = ["
        let actualValue = try whenTheDeclarationIsWritten(for: secretProperty, encryptionKey: "the-key")
        expect(actualValue).to(beginWith(expectedValue))
    }

    func testItCanWriteAnEncryptionKey() throws {
        let secretProperty = ConfigurationProperty<String>(key: "test", typeHint: "EncryptionKey", dict: [
            "defaultValue": "top-secret",
        ])
        let expectedValue = "    static let test: [UInt8] = [UInt8(116), UInt8(111), UInt8(112), UInt8(45), UInt8(115), UInt8(101), UInt8(99), UInt8(114), UInt8(101), UInt8(116)]"
        let actualValue = try whenTheDeclarationIsWritten(for: secretProperty)
        expect(actualValue).to(equal(expectedValue))
    }
}