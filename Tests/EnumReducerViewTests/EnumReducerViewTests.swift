import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(EnumReducerViewMacros)
import EnumReducerViewMacros

let testMacros: [String: Macro.Type] = [
    "EnumReducerView": EnumReducerViewMacro.self,
]
#endif

final class EnumReducerViewTests: XCTestCase {
    func testEnumReducerViewMacro() throws {
        #if canImport(EnumReducerViewMacros)
        assertMacroExpansion(
            """
            @EnumReducerView
            enum TestFeature {}
            """,
            expandedSource: """
            enum TestFeature {}
            
            extension TestFeature {
                public struct View: SwiftUI.View {
                    let store: Store<State, Action>
                    public var body: some SwiftUI.View {
                        EmptyView()
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testEnumReducerViewMacroAdvanced() throws {
        #if canImport(EnumReducerViewMacros)
        assertMacroExpansion(
            """
            import SwiftUI

            protocol Reducer: Sendable {
                associatedtype State
                associatedtype Action
            }

            class Store<State, Action> {
                var state: State

                init(initialState: State) {
                    self.state = initialState
                }
            }

            struct TestFeature: Reducer {
                struct State {
                    var prop: Int = 0
                }

                enum Action {
                    case action
                }

                struct TestFeatureView {}
            }

            struct DetailsFeature: Reducer {
                struct DetailsFeatureView {
                    let store: Store<State, Action>
                }

                struct State {
                    var detail: Int = 0
                }
                enum Action {
                    case detailAction
                }
            }

            extension TestFeature {
                @EnumReducerView
                enum TestSheet: Reducer {
                    case details(DetailsFeature)

                    struct State {
                        var sheet: Int = 0
                    }
                    enum Action {
                        case sheetAction
                    }
                }
            }
            """,
            expandedSource: """
            import SwiftUI

            protocol Reducer: Sendable {
                associatedtype State
                associatedtype Action
            }

            class Store<State, Action> {
                var state: State

                init(initialState: State) {
                    self.state = initialState
                }
            }

            struct TestFeature: Reducer {
                struct State {
                    var prop: Int = 0
                }

                enum Action {
                    case action
                }

                struct TestFeatureView {}
            }

            struct DetailsFeature: Reducer {
                struct DetailsFeatureView {
                    let store: Store<State, Action>
                }

                struct State {
                    var detail: Int = 0
                }
                enum Action {
                    case detailAction
                }
            }

            extension TestFeature {
                enum TestSheet: Reducer {
                    case details(DetailsFeature)

                    struct State {
                        var sheet: Int = 0
                    }
                    enum Action {
                        case sheetAction
                    }
                }
            }

            extension TestFeature.TestSheet {
                public struct View: SwiftUI.View {
                    let store: Store<State, Action>
                    public var body: some SwiftUI.View {
                        switch store.state {
                        case .details:
                            if let store = store.scope(state: \\.details, action: \\.details) {
                                DetailsFeature.DetailsFeatureView(store: store)
                            }
                        }
                    }
                }
            }

            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
