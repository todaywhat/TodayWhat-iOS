import SwiftUI
import WidgetKit

#if swift(>=6.0)
extension EnvironmentValues {
  @Entry var backportedWidgetRenderingMode: BackportedWidgetRenderingMode = .fullColor
}
#else
extension EnvironmentValues {
  var backportedWidgetRenderingMode: BackportedWidgetRenderingMode {
    get {
      self[BackportedWidgetRenderingModeEnvironmentValue.self]
    }
    set {
      self[BackportedWidgetRenderingModeEnvironmentValue.self] = newValue
    }
  }
}

fileprivate struct BackportedWidgetRenderingModeEnvironmentValue: EnvironmentKey {
  static let defaultValue: BackportedWidgetRenderingMode = .fullColor
}
#endif

struct BackportedWidgetRenderingModeView<Content: View>: View {
  private let viewBuilder: () -> Content
  @State private var backportedWidgetRenderingMode: BackportedWidgetRenderingMode = .fullColor
  
  init(@ViewBuilder viewBuilder: @escaping () -> Content) {
    self.viewBuilder = viewBuilder
  }
  
  var body: some View {
    Group {
      if #available(iOSApplicationExtension 16.0, *) {
        viewBuilder()
          .background {
            WidgetRenderingModeView { newValue in
              backportedWidgetRenderingMode = newValue
            }
          }
      } else {
        viewBuilder()
      }
    }
    .environment(\.backportedWidgetRenderingMode, backportedWidgetRenderingMode)
  }
}

@available(iOSApplicationExtension 16.0, *)
fileprivate struct WidgetRenderingModeView: View {
  @Environment(\.widgetRenderingMode) private var widgetRenderingMode: WidgetRenderingMode
  private let handler: (BackportedWidgetRenderingMode) -> Void
  
  init(handler: @escaping (BackportedWidgetRenderingMode) -> Void) {
    self.handler = handler
  }
  
  var body: some View {
    Color.clear
      .onAppear {
        handler(BackportedWidgetRenderingMode(platform: widgetRenderingMode))
      }
      .onChange(of: widgetRenderingMode) { newValue in
        handler(BackportedWidgetRenderingMode(platform: newValue))
      }
  }
}

struct BackportedWidgetRenderingMode: Hashable, Comparable, CaseIterable, CustomStringConvertible {
  static func < (lhs: BackportedWidgetRenderingMode, rhs: BackportedWidgetRenderingMode) -> Bool {
    lhs.mode.rawValue < rhs.mode.rawValue
  }
  
  static let allCases: [BackportedWidgetRenderingMode] = [.fullColor, .accented, .vibrant]
  
  static var fullColor: BackportedWidgetRenderingMode {
    BackportedWidgetRenderingMode(mode: .fullColor)
  }
  
  static var accented: BackportedWidgetRenderingMode {
    BackportedWidgetRenderingMode(mode: .accented)
  }
  
  static var vibrant: BackportedWidgetRenderingMode {
    BackportedWidgetRenderingMode(mode: .vibrant)
  }
  
  fileprivate var mode: Mode
  
  var description: String {
    switch self {
    case .fullColor: return "fullColor"
    case .accented: return "accented"
    case .vibrant: return "vibrant"
    default:
      assertionFailure()
      return "vibrant"
    }
  }
}

extension BackportedWidgetRenderingMode {
  fileprivate enum Mode: Int, Hashable, Encodable {
    case fullColor, accented, vibrant
  }
}

extension BackportedWidgetRenderingMode {
  @available(iOSApplicationExtension 16.0, *)
  fileprivate init(platform: WidgetRenderingMode) {
    switch platform {
    case .fullColor:
      mode = .fullColor
    case .accented:
      mode = .accented
    case .vibrant:
      mode = .vibrant
    default:
      assertionFailure()
      mode = .fullColor
    }
  }
}
