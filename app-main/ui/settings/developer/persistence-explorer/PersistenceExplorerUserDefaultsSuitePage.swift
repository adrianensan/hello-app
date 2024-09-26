#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct PersistenceExplorerUserDefaultsSuitePage: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(PersistenceExplorerFileModel.self) private var fileModel
  
  private var snapshot: UserDefaultsSnapshot
  
  @State private var sortedAppEntries: [UserDefaultsEntry] = []
  @State private var sortedSystemEntries: [UserDefaultsEntry] = []
  @NonObservedState private var sortButtonFrame: CGRect = .zero
  
  init(snapshot: UserDefaultsSnapshot) {
    self.snapshot = snapshot
  }
  
  public var body: some View {
    NavigationPage(showScrollIndicators: true) {
      VStack(spacing: 32) {
        VStack(spacing: 8) {
          Text(snapshot.suite.name)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(theme.foreground.primary.style)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
          Text("\(snapshot.objects.count) Objects")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(theme.foreground.tertiary.style)
        }
        HelloSection(title: "App") {
          LazyVStack(spacing: 0) {
            ForEach(sortedAppEntries) { entry in
              PersistenceExplorerUserDefaultsObjectRow(entry: entry)
            }
          }
        }
        
        HelloSection(title: "System") {
          LazyVStack(spacing: 0) {
            ForEach(sortedSystemEntries) { entry in
              PersistenceExplorerUserDefaultsObjectRow(entry: entry)
            }
          }
        }
      }
    }.onAppear {
      sortedAppEntries = fileModel.sort(userDefaultsEntries: snapshot.objects.filter { !$0.isSystem })
      sortedSystemEntries = fileModel.sort(userDefaultsEntries: snapshot.objects.filter { $0.isSystem })
    }.onChange(of: fileModel.deletedUserDefaults) {
      sortedAppEntries = fileModel.sort(userDefaultsEntries: snapshot.objects.filter { !$0.isSystem })
      sortedSystemEntries = fileModel.sort(userDefaultsEntries: snapshot.objects.filter { $0.isSystem })
    }
  }
}
#endif
