import ComposableArchitecture
import SwiftUI
import EnumUtil
import TWColor
import SwiftUIUtil

public struct AllergySettingView: View {
    private let store: StoreOf<AllergySettingCore>
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 9), count: 2)
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var viewStore: ViewStoreOf<AllergySettingCore>
    
    public init(store: StoreOf<AllergySettingCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    public var body: some View {
        ScrollView {
            Spacer()
                .frame(height: 20)

            LazyVGrid(columns: columns) {
                ForEach(AllergyType.allCases, id: \.hashValue) { allergy in
                    ZStack {
                        if viewStore.selectedAllergyList.contains(allergy) {
                            Color.extraPrimary
                                .cornerRadius(8)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(Color.background, lineWidth: 3)
                                        .padding(1)
                                }
                        } else {
                            Color.lightGray
                                .cornerRadius(8)
                        }

                        Text(allergy.rawValue)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.extraGray)
                    }
                    .frame(height: 88)
                    .onTapGesture {
                        viewStore.send(.allergyDidSelect(allergy), animation: .default)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("알레르기 설정")
        .onAppear {
            viewStore.send(.onAppear, animation: .default)
        }
        .onWillDisappear {
            viewStore.send(.onWillDisappear, animation: .default)
        }
        .twBackButton(dismiss: dismiss)
    }
}

private struct WillDisappearHandler: UIViewControllerRepresentable {
    
    let onWillDisappear: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        ViewWillDisappearViewController(onWillDisappear: onWillDisappear)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private class ViewWillDisappearViewController: UIViewController {
        let onWillDisappear: () -> Void

        init(onWillDisappear: @escaping () -> Void) {
            self.onWillDisappear = onWillDisappear
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onWillDisappear()
        }
    }
}

private extension View {
    func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
        background(WillDisappearHandler(onWillDisappear: perform))
    }
}
