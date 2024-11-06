import SwiftUI
import PencilKit

struct ContentView: View {
    static let initialURL = URL(string: "https://seas.upenn.edu/~cis1951")!
    
    @State var drawing = PKDrawing()
    @State var isDrawing = false
    @State var url = Self.initialURL
    @State var urlString = Self.initialURL.absoluteString
    
    var body: some View {
        VStack {
            HStack {
                TextField("URL", text: $urlString)
                    .textFieldStyle(.roundedBorder)
                
                Button("Go") {
                    if let parsedURL = URL(string: urlString) {
                        url = parsedURL
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            
            HStack {
                Button("Interact", systemImage: "cursorarrow") {
                    isDrawing = false
                }
                .buttonStyle(CustomButtonStyle(isActive: !isDrawing))
                .accessibilityAddTraits(isDrawing ? [] : .isSelected)
                
                Button("Draw", systemImage: "pencil.and.scribble") {
                    isDrawing = true
                }
                .buttonStyle(CustomButtonStyle(isActive: isDrawing))
                .accessibilityAddTraits(isDrawing ? .isSelected : [])
                
                Spacer()
                
                Button("Save", systemImage: "square.and.arrow.down") {
                    let traitCollection = UITraitCollection(userInterfaceStyle: .light)
                    traitCollection.performAsCurrent {
                        let image = drawing.image(from: drawing.bounds, scale: 2)
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                }
                .buttonStyle(CustomButtonStyle())
            }
            
            ZStack {
                WebView(url: url)
                    .opacity(isDrawing ? 0.5 : 1)
                DrawingCanvas(drawing: $drawing, isFocused: $isDrawing)
                    .allowsHitTesting(isDrawing)
                    .opacity(isDrawing ? 1 : 0.5)
            }
            .background(.white)
            .environment(\.colorScheme, .light)
            .clipShape(.rect(cornerRadius: 16))
        }
        .padding()
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
