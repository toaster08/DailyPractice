//
//  StickyTabView.swift
//  DailyPractice
//
//  Created by 山田　天星 on 2024/10/11.
//

import SwiftUI

struct StickyTabView: View {
    var body: some View {
        HStack {
            Text("test")
        }
    }
}

enum TabType: String, CaseIterable, Hashable {
    case recipe
    case menu
}

struct FooTabView: View {
    @State var selection: TabType = .menu
    @State private var offset: CGFloat = .zero

    enum Constants {
        static let Header: CGSize = .init(width: 44, height: 44)
        static let TabBar: CGSize = .init(width: 44, height: 44)
    }

    private var topAreaHeight: CGFloat {
        Constants.Header.height + Constants.TabBar.height
    }

    var body: some View {
        ZStack(alignment: .top) {
            tabView
                .offset(y: offset)
                .padding(.bottom, -min(topAreaHeight, abs(offset)))

            VStack(alignment: .center, spacing: 0) {
                header
                    .frame(height: Constants.Header.height)
                TabBar(tabTypes: TabType.allCases, selection: $selection)
                    .frame(height: Constants.TabBar.height)
            }
            .offset(y: offset)
        }
    }

    private func updateOffset(_ newOffset: CGFloat) { // ②
        if newOffset <= -topAreaHeight { // HostingControllerを使わない場合、ここにsafeAreaを高さを足す必要がある。
            offset = -topAreaHeight
        } else if newOffset >= 0.0 {
            offset = 0
        } else {
            offset = newOffset
        }
    }

    private var header: some View {
        HStack {
            Text("Header")
        }
    }

    @ViewBuilder
    private var tabView: some View {
        TabView(selection: $selection) {
            OffsetReadableTabContentScrollView(
                tabType: TabType.recipe,
                selection: selection,
                onChangeOffset: { offset in
                    updateOffset(offset)
                },
                content: {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(1 ..< 21) { index in
                            Text("Item \(index) in \(TabType.recipe.rawValue)")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .offset(y: -offset)
                    .padding(.top)
                    .padding(.bottom, topAreaHeight)
                }
            )
            .tag(TabType.recipe)
            OffsetReadableTabContentScrollView(
                tabType: TabType.menu,
                selection: selection,
                onChangeOffset: { offset in
                    updateOffset(offset)
                },
                content: {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(1 ..< 21) { index in
                            Text("Item \(index) in \(TabType.menu.rawValue)")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .offset(y: -offset)
                    .padding(.top)
                    .padding(.bottom, topAreaHeight)
                }
            )
            .tag(TabType.menu)
        }
        .padding(.top, topAreaHeight)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }

    struct TabBar: View {
        let tabTypes: [TabType]
        @Binding var selection: TabType

        var body: some View {
            HStack {
                ForEach(tabTypes, id: \.self) { tab in
                    Button(action: {
                        selection = tab
                    }) {
                        Text(tab.rawValue)
                            .fontWeight(selection == tab ? .bold : .regular)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selection == tab ? Color.orange.opacity(0.2) : Color.clear)
                            .cornerRadius(10)
                    }
                }
            }
            .frame(height: Constants.TabBar.height)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }

    struct OffsetReadableTabContentScrollView<TabType: Hashable, Content: View>: View {
        let tabType: TabType
        var selection: TabType
        let onChangeOffset: (CGFloat) -> Void
        let content: () -> Content

        @State private var currentOffset: CGFloat = .zero

        var body: some View {
            OffsetReadableVerticalScrollView(
                onChangeOffset: { offset in
                    currentOffset = offset
                    if tabType == selection {
                        onChangeOffset(offset)
                    }
                },
                content: content
            )
            .onChange(of: selection) { _ in
                if tabType != selection {
                    print("selection: offset", (selection, currentOffset))
                    withAnimation {
                        onChangeOffset(currentOffset)
                    }
                }
            }
        }
    }
}

private struct ScrollViewOffsetYPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value _: inout CGFloat, nextValue _: () -> CGFloat) {}
}

public struct OffsetReadableVerticalScrollView<Content: View>: View {
    private struct CoordinateSpaceName: Hashable {}

    private let showsIndicators: Bool
    private let onChangeOffset: (CGFloat) -> Void
    private let content: () -> Content

    public init(
        showsIndicators: Bool = true,
        onChangeOffset: @escaping (CGFloat) -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.showsIndicators = showsIndicators
        self.onChangeOffset = onChangeOffset
        self.content = content
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: showsIndicators) {
            ZStack(alignment: .top) {
                GeometryReader { geometryProxy in
                    Color.clear.preference(
                        key: ScrollViewOffsetYPreferenceKey.self,
                        value: geometryProxy.frame(in: .named(CoordinateSpaceName())).minY
                    )
                }
                .frame(width: 1, height: 1)
                content()
            }
        }
        .coordinateSpace(name: CoordinateSpaceName())
        .onPreferenceChange(ScrollViewOffsetYPreferenceKey.self) { offset in
            onChangeOffset(offset)
        }
    }
}

#Preview {
    FooTabView()
}
