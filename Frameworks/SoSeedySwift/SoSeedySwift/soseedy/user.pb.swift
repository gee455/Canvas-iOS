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

// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: user.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// Request messages
public struct Soseedy_CreateCanvasUserRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// Response messages
public struct Soseedy_CanvasUser {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: Int64 = 0

  public var loginID: String = String()

  public var password: String = String()

  public var domain: String = String()

  public var token: String = String()

  public var name: String = String()

  public var shortName: String = String()

  public var avatarURL: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "soseedy"

extension Soseedy_CreateCanvasUserRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".CreateCanvasUserRequest"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public func _protobuf_generated_isEqualTo(other: Soseedy_CreateCanvasUserRequest) -> Bool {
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension Soseedy_CanvasUser: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".CanvasUser"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "loginId"),
    3: .same(proto: "password"),
    4: .same(proto: "domain"),
    5: .same(proto: "token"),
    6: .same(proto: "name"),
    7: .same(proto: "shortName"),
    8: .same(proto: "avatarUrl"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularInt64Field(value: &self.id)
      case 2: try decoder.decodeSingularStringField(value: &self.loginID)
      case 3: try decoder.decodeSingularStringField(value: &self.password)
      case 4: try decoder.decodeSingularStringField(value: &self.domain)
      case 5: try decoder.decodeSingularStringField(value: &self.token)
      case 6: try decoder.decodeSingularStringField(value: &self.name)
      case 7: try decoder.decodeSingularStringField(value: &self.shortName)
      case 8: try decoder.decodeSingularStringField(value: &self.avatarURL)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    if !self.loginID.isEmpty {
      try visitor.visitSingularStringField(value: self.loginID, fieldNumber: 2)
    }
    if !self.password.isEmpty {
      try visitor.visitSingularStringField(value: self.password, fieldNumber: 3)
    }
    if !self.domain.isEmpty {
      try visitor.visitSingularStringField(value: self.domain, fieldNumber: 4)
    }
    if !self.token.isEmpty {
      try visitor.visitSingularStringField(value: self.token, fieldNumber: 5)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 6)
    }
    if !self.shortName.isEmpty {
      try visitor.visitSingularStringField(value: self.shortName, fieldNumber: 7)
    }
    if !self.avatarURL.isEmpty {
      try visitor.visitSingularStringField(value: self.avatarURL, fieldNumber: 8)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public func _protobuf_generated_isEqualTo(other: Soseedy_CanvasUser) -> Bool {
    if self.id != other.id {return false}
    if self.loginID != other.loginID {return false}
    if self.password != other.password {return false}
    if self.domain != other.domain {return false}
    if self.token != other.token {return false}
    if self.name != other.name {return false}
    if self.shortName != other.shortName {return false}
    if self.avatarURL != other.avatarURL {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}
