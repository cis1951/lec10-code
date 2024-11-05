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
            VStack {
                HStack {
                    Picker("Mode", selection: $isDrawing) {
                        Text("Interact").tag(false)
                        Text("Draw").tag(true)
                    }
                    .pickerStyle(.segmented)
                    
                    Button {
                        let image = drawing.image(from: drawing.bounds, scale: 2)
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    } label: {
                        Label("Save to Photos", systemImage: "square.and.arrow.down")
                    }
                }
                                
                HStack {
                    TextField("URL", text: $urlString)
                    
                    Button("Go") {
                        if let parsedURL = URL(string: urlString) {
                            url = parsedURL
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
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
