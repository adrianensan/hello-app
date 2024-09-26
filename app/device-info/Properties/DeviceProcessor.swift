import Foundation

public enum DeviceProcessor: Codable {
  case a8
  case a10
  case a10X
  case a11
  case a12
  case a12x
  case a12z
  case a13
  case a14
  case a15
  case a16
  case a17Pro
  case a18
  case a18Pro
  case a19
  case a19Pro
  
  case s6
  case s7
  case s8
  case s9
  
  case m1
  case m2
  case m3
  case m4
  
  public var name: String {
    switch self {
    case .a8: "A8"
    case .a10: "A10 Fusion"
    case .a10X: "A10X Fusion"
    case .a11: "A11"
    case .a12: "A12 Bionic"
    case .a12x: "A12X Bionic"
    case .a12z: "A12Z Bionic"
    case .a13: "A13 Bionic"
    case .a14: "A14 Bionic"
    case .a15: "A15 Bionic"
    case .a16: "A16 Bionic"
    case .a17Pro: "A17 Pro"
    case .a18: "A18"
    case .a18Pro: "A18 Pro"
    case .a19: "A19?"
    case .a19Pro: "A19 Pro?"
      
    case .s6: "S6"
    case .s7: "S7"
    case .s8: "S8"
    case .s9: "S9"
    
    case .m1: "M1"
    case .m2: "M2"
    case .m3: "M3"
    case .m4: "M4"
    }
  }
}
