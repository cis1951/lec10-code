import SwiftUI
import PencilKit

class CustomCanvasView: PKCanvasView {
    weak var coordinator: DrawingCanvas.Coordinator?
    
    override func becomeFirstResponder() -> Bool {
        if let coordinator, !coordinator.ignoreChanges {
            coordinator.parent.isFocused = true
        }
        
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        if let coordinator, !coordinator.ignoreChanges {
            coordinator.parent.isFocused = false
        }
        
        return super.resignFirstResponder()
    }
}

struct DrawingCanvas: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var isFocused: Bool
    @State var toolPicker = PKToolPicker()
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let parent: DrawingCanvas
        var ignoreChanges = false
        
        init(parent: DrawingCanvas) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            guard !ignoreChanges else { return }
            
            parent.drawing = canvasView.drawing
        }
    }
    
    func makeUIView(context: Context) -> CustomCanvasView {
        let uiView = CustomCanvasView()
        
        toolPicker.setVisible(true, forFirstResponder: uiView)
        toolPicker.addObserver(uiView)
        
        uiView.delegate = context.coordinator
        uiView.coordinator = context.coordinator
        uiView.backgroundColor = .clear
        
        updateUIView(uiView, context: context)
        
        return uiView
    }
    
    func updateUIView(_ uiView: CustomCanvasView, context: Context) {
        context.coordinator.ignoreChanges = true
        defer { context.coordinator.ignoreChanges = false }
        
        toolPicker.colorUserInterfaceStyle = uiView.traitCollection.userInterfaceStyle
        
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
        
        if isFocused {
            _ = uiView.becomeFirstResponder()
        } else {
            _ = uiView.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
}
