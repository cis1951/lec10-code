import SwiftUI
import PencilKit

struct DrawingCanvas: View {
    @Binding var drawing: PKDrawing
    @Binding var isFocused: Bool
    
    var body: some View {
        Text("TODO")
            .background(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
