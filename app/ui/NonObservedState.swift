import SwiftUI

@MainActor
@propertyWrapper
public struct NonObservedState<Value> {
  
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
