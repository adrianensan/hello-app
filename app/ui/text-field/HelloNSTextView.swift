#if os(macOS)
import SwiftUI

import HelloCore
import HelloApp

@MainActor
public class HelloNSTextView: NSTextView, NSTextViewDelegate {
  
  var maxWidth: CGFloat = .infinity
  
  var onSubmit: (() -> Void)?
  var onTextChange: ((String) -> Void)?
  var onFocus: (() -> Void)?
  var onDefocus: (() -> Void)?
  var onHeightChanged: ((CGFloat) -> Void)?
  var onCancel: (() -> Void)?
  
  var onFilePasted: ((Data, String?, ContentType) -> Void)?
  var onFileURLPasted: ((URL) -> Void)?
  
  var lastSize: CGSize = .zero
  
  func setup() {
    Task { [weak self] in
      for await _ in NotificationCenter.default.notifications(named: NSView.frameDidChangeNotification, object: nil).map({ $0.name }) {
        guard let self else { return }
        let newSize = round(frame.size)
        if lastSize != newSize {
          lastSize = newSize
          invalidateIntrinsicContentSize()
        }
      }
    }
  }
  
  public override func becomeFirstResponder() -> Bool {
    onFocus?()
    return super.becomeFirstResponder()
  }
  
  open override var intrinsicContentSize: NSSize {
    get {
      guard let layoutManager, let textContainer else {
        return super.intrinsicContentSize
      }
      
      layoutManager.ensureLayout(for: textContainer)
      var size = layoutManager.usedRect(for: textContainer).size
      size.width = min(bounds.width, size.width, maxWidth)
      Task {
        onHeightChanged?(size.height)
      }
      return size
    }
  }
  
  public override func didChangeText() {
    super.didChangeText()
    onTextChange?(string)
    invalidateIntrinsicContentSize()
  }
  
  var isFocused: Bool = false
  
  public func textDidEndEditing(_ notification: Notification) {
    isFocused = true
  }
  
  public override func readSelection(from pboard: NSPasteboard, type: NSPasteboard.PasteboardType) -> Bool {
    switch type {
    case .fileURL:
      if let onFileURLPasted, let urls = pboard.readObjects(forClasses: [NSURL.self]) as? [URL] {
        for url in urls {
          onFileURLPasted(url)
        }
        return true
      }
    case .tiff:
      if let onFilePasted,
         let data = pboard.data(forType: .tiff),
         NSImage(data: data) != nil {
        Task {
          if await ImageProcessor.animatedFrames(from: data)?.count ?? 0 <= 1,
             let rawImageRep = NSBitmapImageRep(data: data),
             let pngData = rawImageRep.representation(using: .png, properties: [.compressionFactor: 1.0]) {
            onFilePasted(pngData, nil, .png)
          } else {
            onFilePasted(data, nil, .png)
          }
        }
        return true
        
      }
    case .png:
      if let onFilePasted, let data = pboard.data(forType: .png) {
        onFilePasted(data, nil, .png)
        return true
      }
    default: ()
    }
    return super.readSelection(from: pboard, type: type)
  }
  
  public override var readablePasteboardTypes: [NSPasteboard.PasteboardType] { [.tiff, .png, .fileURL, .string] }
  
  public override func preferredPasteboardType(from availableTypes: [NSPasteboard.PasteboardType],
                                               restrictedToTypesFrom allowedTypes: [NSPasteboard.PasteboardType]?) -> NSPasteboard.PasteboardType? {
    if availableTypes.contains(.fileURL) {
      .fileURL
    } else if availableTypes.contains(.tiff) {
      .tiff
    } else if availableTypes.contains(.png) {
      .png
    } else if availableTypes.contains(.string) {
      .string
    } else {
      nil
    }
  }
  
  //  func controlTextDidBeginEditing(_ obj: Notification) {
  //    guard (obj.object as? ChatNSTextField) == self else { return }
  //    isFocused = true
  //  }
  
  func controlTextDidEndEditing(_ obj: Notification) {
    guard (obj.object as? HelloNSTextView) == self else { return }
    isFocused = false
    onDefocus?()
  }
  
  public func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
    switch commandSelector {
    case #selector(NSTextView.insertNewline(_:)):
      if let event: NSEvent = NSApp.currentEvent,
          event.modifierFlags.intersection(.deviceIndependentFlagsMask) == [.shift] {
        return false
      }
      if let onSubmit {
        onSubmit()
        return true
      }
    case #selector(NSTextView.cancelOperation(_:)):
      if let onCancel {
        onCancel()
        return true
      }
    default: ()
    }
    
    return false
  }
}

@MainActor
public struct HelloTextView<FocusValue: Hashable>: NSViewRepresentable {
  
  @Binding var text: String
  @Binding var height: CGFloat
  var maxWidth: CGFloat
  var onSubmit: @MainActor @Sendable () -> Void
  var onFileURLPasted: @MainActor @Sendable (URL) -> Void
  var onFilePasted: @MainActor @Sendable (Data, String?, ContentType) -> Void
  var onCancel: @MainActor @Sendable () -> Void
  var isEditable: Bool
  
  @FocusState.Binding var currentFocus: FocusValue?
  var focusValue: FocusValue
  
  var shouldBeFocused: Bool { currentFocus == focusValue }
  
  public init(text: Binding<String>,
              height: Binding<CGFloat>,
              maxWidth: CGFloat,
              onSubmit: @MainActor @Sendable @escaping () -> Void,
              onFileURLPasted: @MainActor @Sendable @escaping (URL) -> Void,
              onFilePasted: @MainActor @Sendable @escaping (Data, String?, ContentType) -> Void,
              onCancel: @MainActor @Sendable @escaping () -> Void,
              isEditable: Bool,
              currentFocus: FocusState<FocusValue?>.Binding,
              focusValue: FocusValue) {
    _text = text
    _height = height
    self.maxWidth = maxWidth
    self.onSubmit = onSubmit
    self.onFileURLPasted = onFileURLPasted
    self.onFilePasted = onFilePasted
    self.onCancel = onCancel
    self.isEditable = isEditable
    _currentFocus = currentFocus
    self.focusValue = focusValue
  }
  
  func onFocus() {
    if currentFocus != focusValue {
      currentFocus = focusValue
    }
  }
  
  func onDefocus() {
    if currentFocus == focusValue {
      currentFocus = nil
    }
  }
  
  func updateHeight(to newHeight: CGFloat) {
    guard height != newHeight else { return }
    height = newHeight
  }
  
  public func makeNSView(context: Context) -> HelloNSTextView {
    let textField = HelloNSTextView() +& {
      $0.maxWidth = maxWidth
      $0.onSubmit = onSubmit
      $0.onFocus = onFocus
      $0.onDefocus = onDefocus
      $0.onTextChange = { self.text = $0 }
      $0.onCancel = { onCancel() }
      $0.onHeightChanged = { newHeight in updateHeight(to: newHeight) }
      $0.onFilePasted = { onFilePasted($0, $1, $2) }
      $0.onFileURLPasted = { onFileURLPasted($0) }
    }
    textField.allowsUndo = true
    textField.font = .systemFont(ofSize: 17, weight: .regular)
    textField.textColor = .textColor
    textField.textContainerInset = .zero
    textField.textContainer?.lineFragmentPadding = 0
    textField.postsFrameChangedNotifications = true
    textField.setup()
    textField.focusRingType = .none
    textField.backgroundColor = .clear
    textField.delegate = textField
    return textField
  }
  
  public func updateNSView(_ textField: HelloNSTextView, context: Context) {
    //    textField.textColor = theme.textPrimary.nativeColor
    textField.isEditable = isEditable
    textField.frame.size.width = maxWidth
    textField.string = text
//    if shouldBeFocused && !textField.isFocused {
//      textField.window?.makeFirstResponder(textField)
//      textField.isFocused = true
//    } else if !shouldBeFocused && textField.isFocused {
//      textField.window?.resignFirstResponder()
//      textField.isFocused = false
//    }
  }
}
#endif
