import SwiftUI

struct AccentButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(configuration.isPressed ? .gray : .white)
            .frame(minWidth: 100)
            .padding()
            .background(isEnabled ? Color.accentColor : .gray)
            .cornerRadius(8)
            .padding(10)
    }
}
