#if os (iOS)
import SwiftUI

struct HelloSheetDismissDragViewModifier: ViewModifier {
  
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.viewID) private var viewID
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(HelloSheetModel.self) private var model
  
  @GestureState private var drag: CGFloat?
  
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
  
  func body(content: Content) -> some View {
    content
      .readSize {
        guard model.sheetSize != $0 else { return }
        model.sheetSize = $0
      }
      .opacity(model.sheetSize != .zero ? 1 : 0)
      .disabled(yDrag != 0)
      .compositingGroup()
//      .frame(height: model.isVisible ? nil : 1, alignment: .top)
      .animation(.dampSpring, value: model.isVisible)
      .offset(y: model.isVisible ? yDrag : (isfloating ? windowFrame.height : model.sheetSize.height) + 8)
      .animation(yDrag == 0 ? .dampSpring : .interactive, value: yDrag)
      .frame(maxWidth: isfloating ? 560 : .infinity, maxHeight: isfloating ? 0.8 * windowFrame.height : .infinity, alignment: isfloating ? .center : .bottom)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      .background(HelloBackgroundDimmingView()
        .opacity(model.isVisible ? 1 : 0)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .sheet)
          .updating($drag) { value, state, transaction in
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
      .allowsHitTesting(model.isVisible)
      .environment(\.hasAppeared, model.isVisible)
      .onChange(of: model.isVisible) {
        if !model.isVisible {
          Task {
            windowModel.dismiss(id: viewID)
          }
        }
      }.onChange(of: model.sheetSize != .zero) {
        guard model.sheetSize != .zero && !model.isVisible else { return }
        Task {
          try? await Task.sleepForOneFrame()
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
