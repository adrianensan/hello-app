#if os(visionOS)
import Foundation
import ARKit

func angle(between vector1: SIMD3<Float>, and vector2: SIMD3<Float>) -> Float {
  abs(acos(dot(vector1, vector2) / (vector1.magnitude * vector2.magnitude)))
}

public struct FingerJoint: Sendable {
  
  public let localTransform: simd_float4x4
  public let localPosition: SIMD3<Float>
  public let globalTransform: simd_float4x4
  public let globalPosition: SIMD3<Float>
  
  public init(joint: HandSkeleton.Joint, globalHandTransform: simd_float4x4) {
    localTransform = joint.anchorFromJointTransform
    localPosition = localTransform.position()
    globalTransform = matrix_multiply(globalHandTransform, localTransform)
    globalPosition = globalTransform.position()
  }
}

public struct FingerStructure: Sendable {
  public var tip: FingerJoint
  public var intermediateTip: FingerJoint
  public var intermediateBase: FingerJoint
  public var knuckle: FingerJoint
  public var metacarpal: FingerJoint
  
  public var isFingerStraight: Bool {
    let fingerBendAngleThreshold: Float = 0.2 * .pi
    
    let IntermediateTipToTipSegment = tip.localPosition - intermediateTip.localPosition
    let IntermediateBaseToIntermediateTipSegment = intermediateTip.localPosition - intermediateBase.localPosition
    let knuckleToIntermediateBaseSegment = intermediateBase.localPosition - knuckle.localPosition
    let metacarpalToKnuckleSegment = knuckle.localPosition - metacarpal.localPosition
    return angle(between: IntermediateTipToTipSegment,
                 and: IntermediateBaseToIntermediateTipSegment) < fingerBendAngleThreshold
    && angle(between: IntermediateBaseToIntermediateTipSegment,
             and: knuckleToIntermediateBaseSegment) < fingerBendAngleThreshold
    && angle(between: knuckleToIntermediateBaseSegment,
             and: metacarpalToKnuckleSegment) < fingerBendAngleThreshold
  }
}

public struct ThumbStructure: Sendable {
  public var tip: FingerJoint
  public var intermediate: FingerJoint
  public var knuckle: FingerJoint
  public var metacarpal: FingerJoint
  
  public var isFingerStraight: Bool {
    let fingerBendAngleThreshold: Float = 0.2 * .pi
    
    let IntermediateToTipSegment = tip.localPosition - intermediate.localPosition
    let knuckleToIntermediateSegment = intermediate.localPosition - knuckle.localPosition
    let metacarpalToKnuckleSegment = knuckle.localPosition - metacarpal.localPosition
    return angle(between: IntermediateToTipSegment,
                 and: knuckleToIntermediateSegment) < fingerBendAngleThreshold
    && angle(between: knuckleToIntermediateSegment,
             and: metacarpalToKnuckleSegment) < fingerBendAngleThreshold
  }
}

public struct HandStructure: Sendable {
  
  public var thumb: ThumbStructure
  public var index: FingerStructure
  public var middle: FingerStructure
  public var ring: FingerStructure
  public var little: FingerStructure
  
  public init?(handAnchor: HandAnchor) {
    guard let handSkeleton = handAnchor.handSkeleton else { return nil }
    let transform = handAnchor.originFromAnchorTransform
    thumb = ThumbStructure(
      tip: FingerJoint(joint: handSkeleton.joint(.thumbTip), globalHandTransform: transform),
      intermediate: FingerJoint(joint: handSkeleton.joint(.thumbIntermediateTip), globalHandTransform: transform),
      knuckle: FingerJoint(joint: handSkeleton.joint(.thumbIntermediateBase), globalHandTransform: transform),
      metacarpal: FingerJoint(joint: handSkeleton.joint(.thumbKnuckle), globalHandTransform: transform))
    
    index = FingerStructure(
      tip: FingerJoint(joint: handSkeleton.joint(.indexFingerTip), globalHandTransform: transform),
      intermediateTip: FingerJoint(joint: handSkeleton.joint(.indexFingerIntermediateTip), globalHandTransform: transform),
      intermediateBase: FingerJoint(joint: handSkeleton.joint(.indexFingerIntermediateBase), globalHandTransform: transform),
      knuckle: FingerJoint(joint: handSkeleton.joint(.indexFingerKnuckle), globalHandTransform: transform),
      metacarpal: FingerJoint(joint: handSkeleton.joint(.indexFingerMetacarpal), globalHandTransform: transform))
    
    middle = FingerStructure(
      tip: FingerJoint(joint: handSkeleton.joint(.middleFingerTip), globalHandTransform: transform),
      intermediateTip: FingerJoint(joint: handSkeleton.joint(.middleFingerIntermediateTip), globalHandTransform: transform),
      intermediateBase: FingerJoint(joint: handSkeleton.joint(.middleFingerIntermediateBase), globalHandTransform: transform),
      knuckle: FingerJoint(joint: handSkeleton.joint(.middleFingerKnuckle), globalHandTransform: transform),
      metacarpal: FingerJoint(joint: handSkeleton.joint(.middleFingerMetacarpal), globalHandTransform: transform))
    
    ring = FingerStructure(
      tip: FingerJoint(joint: handSkeleton.joint(.ringFingerTip), globalHandTransform: transform),
      intermediateTip: FingerJoint(joint: handSkeleton.joint(.ringFingerIntermediateTip), globalHandTransform: transform),
      intermediateBase: FingerJoint(joint: handSkeleton.joint(.ringFingerIntermediateBase), globalHandTransform: transform),
      knuckle: FingerJoint(joint: handSkeleton.joint(.ringFingerKnuckle), globalHandTransform: transform),
      metacarpal: FingerJoint(joint: handSkeleton.joint(.ringFingerMetacarpal), globalHandTransform: transform))
    
    little = FingerStructure(
      tip: FingerJoint(joint: handSkeleton.joint(.littleFingerTip), globalHandTransform: transform),
      intermediateTip: FingerJoint(joint: handSkeleton.joint(.littleFingerIntermediateTip), globalHandTransform: transform),
      intermediateBase: FingerJoint(joint: handSkeleton.joint(.littleFingerIntermediateBase), globalHandTransform: transform),
      knuckle: FingerJoint(joint: handSkeleton.joint(.littleFingerKnuckle), globalHandTransform: transform),
      metacarpal: FingerJoint(joint: handSkeleton.joint(.littleFingerMetacarpal), globalHandTransform: transform))
  }
  
  public var areAllFingersStraight: Bool {
    thumb.isFingerStraight &&
    index.isFingerStraight &&
    middle.isFingerStraight &&
    ring.isFingerStraight && 
    little.isFingerStraight
  }
  
  public var isIndexAndThumbTouching: Bool {
    let segment = index.intermediateTip.globalPosition - index.tip.globalPosition
    let segmentNormal = normalize(segment)
    let progressDistance = dot(thumb.tip.globalPosition - index.tip.globalPosition, segmentNormal)
    let progress = progressDistance / segment.magnitude
    let shortestVector: SIMD3<Float>
    if progress < 0 {
      shortestVector = index.tip.globalPosition - thumb.tip.globalPosition
    } else if progress > 1 {
      shortestVector = index.intermediateTip.globalPosition - thumb.tip.globalPosition
    } else {
      shortestVector = index.tip.globalPosition + segmentNormal * progressDistance - thumb.tip.globalPosition
    }
    
    return shortestVector.magnitude < 0.015
  }
}
#endif
