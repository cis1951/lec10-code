import SwiftUI
import PencilKit

enum InteractionMode {
    case webpage
    case canvas
}

struct ContentView: View {
    static let initialURL = URL(string: "https://seas.upenn.edu/~cis1951")!
    
    @State var drawing = PKDrawing()
    @State var currentMode = InteractionMode.webpage
    @State var url = Self.initialURL
    @State var urlString = Self.initialURL.absoluteString
    @State var isCanvasFocused = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Picker("Mode", selection: $currentMode) {
                        Text("Interact").tag(InteractionMode.webpage)
                        Text("Draw").tag(InteractionMode.canvas)
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
                    .opacity(currentMode == .webpage ? 1 : 0.5)
                DrawingCanvas(drawing: $drawing, isFocused: $isCanvasFocused)
                    .onTapGesture {
                        isCanvasFocused = true
                    }
                    .allowsHitTesting(currentMode == .canvas)
                    .opacity(currentMode == .canvas ? 1 : 0.5)
            }
            .background(.white)
            .environment(\.colorScheme, .light)
            .clipShape(.rect(cornerRadius: 16))
        }
        .padding()
        .preferredColorScheme(.dark)
        .onChange(of: currentMode) { mode in
            isCanvasFocused = mode == .canvas
        }
    }
}

#Preview {
    ContentView()
}
