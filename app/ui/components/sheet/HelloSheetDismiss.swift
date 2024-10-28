#if os (iOS)
import SwiftUI

import HelloCore

struct HelloSheetDismissDragViewModifier: ViewModifier {
  
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.keyboardFrame) private var keyboardFrame
  @Environment(\.popupID) private var viewID
  @Environment(\.viewID) private var viiiewID
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(HelloSheetModel.self) private var model
  
  @GestureState private var drag: CGPoint?
  @NonObservedState private var dragID: CGPoint?
  
  @State private var readyToShow: Bool = false
  
  private var yDrag: CGFloat {
    if model.dismissDrag < 0 {
      0.06 * model.dismissDrag
    } else {
      model.dismissDrag
    }
  }
  
  private var isfloating: Bool {
    windowFrame.size.minSide > 700
  }
  
  private var offset: CGFloat {
    (isfloating ? -0.5 * keyboardFrame.height : 0) + yDrag
  }
  
  private var height: CGFloat {
    isfloating ? (keyboardFrame.height > 0 ? 0.9 * windowFrame.height - keyboardFrame.height : 0.7 * windowFrame.height) : .infinity
  }
  
  func body(content: Content) -> some View {
    content
      .environment(\.viewFrame, .init(origin: .zero, size: model.sheetSize))
      .readSizeSync {
        guard model.sheetSize != $0 else { return }
        model.sheetSize = $0
      }
      .compositingGroup()
      .disabled(yDrag != 0)
      .animation(.dampSpring, value: model.isVisible)
      .offset(y: model.isVisible ? offset : (isfloating ? windowFrame.height : (readyToShow ? model.sheetSize.height : windowFrame.height)) + 8)
      .animation(yDrag == 0 ? .pageAnimation : .interactive, value: yDrag)
      .animation(.dampSpring, value: keyboardFrame)
      .frame(maxWidth: isfloating ? 560 : .infinity, maxHeight: height, alignment: isfloating ? .center : .bottom)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      .background(HelloBackgroundDimmingView()
        .opacity(model.isVisible ? 1 : 0)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .sheet)
          .updating($drag) { value, state, transaction in
//            if dragID == nil {
//              dragID = value.startLocation
//              state = value.startLocation
//            }
//            guard dragID == value.startLocation else {
//              if state != dragID {
//                state = dragID
//              }
//              return
//            }
            if state == nil {
              state = value.startLocation
            }
            model.dismissDrag = value.translation.height
          }.onEnded { gesture in
            if gesture.predictedEndTranslation.maxSide == 0 || gesture.predictedEndTranslation.height > 200 {
              model.dismiss()
            } else {
              model.dismissDrag = 0
            }
          })
          .animation(.easeInOut(duration: 0.2), value: model.isVisible))
      .gesture(type: model.dragToDismissType, DragGesture(minimumDistance: 8, coordinateSpace: .sheet)
        .updating($drag) { drag, state, transaction in
//          if dragID == nil {
//            dragID = drag.startLocation
//            state = drag.startLocation
//          }
//          guard dragID == drag.startLocation else {
//            if state != dragID {
//              state = dragID
//            }
//            return
//          }
          if state == nil {
            state = drag.startLocation
          }
          if model.dragCanDismiss == nil {
            model.dragCanDismiss = (model.isDraggingNavBar || !model.shouldScrollInsteadOfDismiss) && 0.8 * drag.translation.height > abs(drag.translation.width)
          }
          
          if model.dragCanDismiss == true {
            model.dismissDrag = drag.translation.height
          }
        }.onEnded { gesture in
          if model.dragCanDismiss == true &&
              (gesture.predictedEndTranslation.maxSide == 0 || gesture.predictedEndTranslation.height > 200) {
            model.dismiss()
          } else {
            if model.dismissDrag != 0 {
              model.dismissDrag = 0
            }
          }
          model.dragCanDismiss = nil
        })
      .onChange(of: drag) {
        if drag == nil {
          model.isDraggingNavBar = false
          if model.dismissDrag != 0 {
            model.dismissDrag = 0
          }
        }
      }
      .allowsHitTesting(model.isVisible && model.dismissDrag == 0)
      .environment(\.hasAppeared, model.isVisible)
      .onChange(of: model.isVisible) {
        if !model.isVisible {
          Task {
            try? await Task.sleep(seconds: 0.2)
            windowModel.dismiss(id: viewID)
          }
        }
      }
      .onChange(of: model.sheetSize) { oldSize, newSize in
        if model.waitingForSizing && oldSize.height > 0 {
          model.waitingForSizing = false
        }
        guard model.sheetSize != .zero && !model.isVisible else { return }
        Task {
          if model.waitingForSizing {
            try await Task.sleepForABit()
            guard !readyToShow else { return }
          }
          try await Task.sleepForOneFrame()
          readyToShow = true
          try await Task.sleepForOneFrame()
          model.isVisible = true
        }
      }
  }
}

extension View {
  func handleSheetDismissDrag() -> some View {
    self.modifier(HelloSheetDismissDragViewModifier())
  }
}
#endif
