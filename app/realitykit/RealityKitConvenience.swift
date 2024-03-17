#if os(iOS) || os(visionOS)
import RealityKit

import HelloCore

public extension matrix_float4x4 {
  func position() -> SIMD3<Float> {
    SIMD3(columns.3.x, columns.3.y, columns.3.z)
  }
}

public extension HasModel {
  var boundingBox: BoundingBox {
    model?.mesh.bounds ?? .empty
  }
  
  var size: SIMD3<Float> {
    boundingBox.extents
  }
}

public extension HelloRotation3D where NumberType == Float {
  var simdFloat: simd_quatf {
    simd_quatf(angle: Float(angle), axis: axis.simdFloat)
  }
}

public extension HelloTransform3D where NumberType == Float {
  var realitykitTransform: Transform {
    Transform(scale: scale.simdFloat, rotation: rotation.simdFloat, translation: translation.simdFloat)
  }
}
#endif
