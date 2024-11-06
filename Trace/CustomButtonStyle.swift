import SwiftUI

struct CustomLabelStyle: LabelStyle {
    var isActive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
                .frame(minWidth: 50, minHeight: 50)
                .background(.tint.opacity(isActive ? 1 : 0.4))
                .foregroundStyle(.white)
                .clipShape(.circle)
            
            configuration.title
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
    }
}

struct CustomButtonStyle: ButtonStyle {
    var isActive = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.labelStyle(CustomLabelStyle(isActive: isActive))
    }
}
