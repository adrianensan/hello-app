#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct PersistenceExplorerUserDefaultsRow: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(PagerModel.self) private var pagerModel
  @Environment(PersistenceExplorerFileModel.self) private var fileModel
  
  var userDefaults: UserDefaultsSnapshot
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, action: {
      pagerModel.push(id: userDefaults.id, name: userDefaults.suite.name) {
        PersistenceExplorerUserDefaultsSuitePage(snapshot: userDefaults)
          .environment(fileModel)
      }
    }) {
      HelloNavigationRow(icon: "cylinder.split.1x2", name: userDefaults.suite.name, actionIcon: .arrow) {
        Text("\(userDefaults.objects.count) Objects")
          .font(.system(size: 16, weight: .regular))
          .lineLimit(1)
      }
//      HelloSectionItem {
//        HStack(spacing: 4) {
//          Image(systemName: "cylinder.split.1x2")
//            .font(.system(size: 20, weight: .regular))
//            .frame(width: 30)
//            .padding(.trailing, 2)
//          Text(userDefaults.suite.name)
//            .font(.system(size: 16, weight: .regular))
//            .lineLimit(1)
//            .truncationMode(.middle)
//          
//          Spacer(minLength: 0)
//          Text("\(userDefaults.objects.count) Objects")
//            .font(.system(size: 16, weight: .regular))
//            .lineLimit(1)
//          Image(systemName: "chevron.right")
//            .font(.system(size: 16, weight: .regular))
//        }
//      }.frame(height: 56)
    }
  }
}
#endif
