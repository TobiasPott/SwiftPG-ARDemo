import SwiftUI

struct MessageStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .foregroundColor(.primary)
            .frame(minWidth: 100)
            .padding()
            .background(.gray)
            .cornerRadius(4)
            .padding(10)
    }
}

extension Text {
    func textStyle<Style: ViewModifier>(_ style: Style) -> some View {
        ModifiedContent(content: self, modifier: style)
    }
}
