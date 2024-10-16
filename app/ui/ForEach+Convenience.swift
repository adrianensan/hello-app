import SwiftUI

fileprivate struct HelloEnumeratedCollectionElement<Element: Sendable & Identifiable>: Identifiable, Sendable {
  var index: Int
  var element: Element
  var isLast: Bool
  
  init(index: Int, element: Element) {
    self.index = index
    self.element = element
    self.isLast = false
  }
  
  var id: Element.ID { element.id }
}

fileprivate extension Collection where Element: Sendable & Identifiable {
  func enumeratedIdentifiable() -> [HelloEnumeratedCollectionElement<Element>] {
    var enumeratedList = enumerated().map {
      HelloEnumeratedCollectionElement(index: $0.offset, element: $0.element)
    }
    if !enumeratedList.isEmpty {
      enumeratedList[enumeratedList.endIndex - 1].isLast = true
    }
    return enumeratedList
  }
}

public struct HelloForEach<Element, Content: View>: View where Element: Sendable & Identifiable {
  
  public var data: [Element]
  public var reversed: Bool
  @ViewBuilder public var content: @MainActor (Int, Element, Bool) -> Content
  
  public init(_ data: [Element], reversed: Bool = false, @ViewBuilder content: @escaping @MainActor (Int, Element) -> Content) {
    self.data = data
    self.reversed = reversed
    self.content = { index, element, _ in content(index, element) }
  }
  
  public init(_ data: [Element], reversed: Bool = false, @ViewBuilder content: @escaping @MainActor (Int, Element, Bool) -> Content) {
    self.data = data
    self.reversed = reversed
    self.content = content
  }
  
  public var body: some View {
    ForEach(reversed ? data.enumeratedIdentifiable().reversed() : data.enumeratedIdentifiable()) { element in
      content(element.index, element.element, element.isLast)
    }
    
//    ForEach(reversed ? data.reversed() : data) { element in
//      let index = data.firstIndex(where: { element.id == $0.id }) ?? 0
//      content(index, element, data.last?.id == element.id)
//    }
  }
}
