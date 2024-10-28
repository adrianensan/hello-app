import SwiftUI


/// SwiftUI property wrapper that behvaes the same as State, without triggering view updates.
/// Useful for storing state that doesn't directly impact the UI
@MainActor
@propertyWrapper
public struct NonObservedState<Value>: DynamicProperty {
  
  private class Model {
    var value: Value
    
    init(value: Value) {
      self.value = value
    }
  }
  
  @State private var model: Model
  
  public init(wrappedValue: Value) {
    _model = State(initialValue: Model(value: wrappedValue))
  }
  
  public var wrappedValue: Value {
    get { model.value }
    nonmutating set { model.value = newValue }
  }
  
  public var projectedValue: Binding<Value> {
    Binding(get: { wrappedValue },
            set: { wrappedValue = $0 })
  }
}
