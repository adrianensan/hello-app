//import SwiftUI
//
//@MainActor
//struct BaseTooltipView<Content: View>: View {
//  
//  @Environment(\.theme) var theme
//  
//  var content: Content
//  
//  init(content: () -> View) {
//    self.content = content
//  }
//  
//  var body: some View {
//    content
//      .padding(.horizontal, 12)
//      .padding(.vertical, 8)
//      .background(theme.backgroundView(for: RoundedRectangle(cornerRadius: 10, style: .continuous), isBaseLayer: false))
//      .compositingGroup()
//      .shadow(color: .black.opacity(0.2), radius: 4)
//      .padding(8)
//  }
//}
//
//import SwiftUI
//
//@MainActor
//struct TextTooltipView<Content: View>: View {
//  
//  @Environment(\.theme) var theme
//  
//  var string: String
//  
//  init(string: String) {
//    self.string = string
//  }
//  
//  var body: some View {
//    BaseTooltipView {
//      Text(string)
//        .font(.system(size: 14, weight: .regular))
//        .foregroundStyle(theme.text.primaryColor)
//        .multilineTextAlignment(.center)
//        .fixedSize()
//    }
//  }
//}
//
//@MainActor
//public class TooltipManager {
//  public static var main = TooltipManager()
//  
//  public var currentTooltipID: String?
//}
//
//public extension View {
//  func tooltip(() -> View) -> some View {
//    
//    
//  }
//}
