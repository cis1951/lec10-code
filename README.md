# Trace

This repo contains the code for **Lecture 10: UIKit**.

In this lecture, we'll be using PencilKit and WebKit to build an app that lets you trace a drawing over any website. Along the way, you'll learn how to use [UIViewRepresentable](https://developer.apple.com/documentation/swiftui/uiviewrepresentable) to use these UIKit views with minimal fuss in SwiftUI.

We've implemented the SwiftUI bits for you, but it's up to you to fill in the UIKit parts! Here's a breakdown of what you'll be doing:

## Step 1: Create the `WebView` view using `UIViewRepresentable`

First, go to `WebView.swift`. We've already implemented a stub that conforms to `View`, but you'll need to replace it with a `UIViewRepresentable` that wraps a [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview). Start by adding some boilerplate:

```swift
struct WebView: UIViewRepresentable {
    var url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        // TODO
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // TODO
    }
}
```

In `makeUIView`, we'll want to create a `WKWebView` and load the URL we've been given:

```swift
func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.load(URLRequest(url: url))
    return webView
}
```

And in `updateUIView`, we'll want to make sure that the URL is updated, but only if it changes:

```swift
func updateUIView(_ uiView: WKWebView, context: Context) {
    if uiView.url != url {
        uiView.load(URLRequest(url: url))
    }
}
```

And that's it! Go ahead and run the app - you should now be able to navigate to the URL of your choice.

## Step 2: Set up your `DrawingCanvas`

Let's do the same for `DrawingCanvas`, but this time, we'll be using [PKCanvasView](https://developer.apple.com/documentation/pencilkit/pkcanvasview). We'll again start with some boilerplate:

```swift
struct DrawingCanvas: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var isFocused: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        // TODO
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // TODO
    }
}
```

In `makeUIView`, we'll want to create a `PKCanvasView` and set up its drawing, a starting tool, and a clear background color:

```swift
func makeUIView(context: Context) -> PKCanvasView {
    let canvas = PKCanvasView()
    canvas.drawing = drawing
    canvas.tool = PKInkingTool(.pen, color: .black, width: 15)
    canvas.backgroundColor = .clear
    return canvas
}
```

And in `updateUIView`, let's update the drawing:

```swift
func updateUIView(_ uiView: PKCanvasView, context: Context) {
    if uiView.drawing != drawing {
        uiView.drawing = drawing
    }
}
```

Go ahead and run the app again - once you switch it to the Draw mode, you should be able to draw on the canvas!

## Step 3: Set up a `PKCanvasViewDelegate` to save the drawing

Unfortunately, we're missing a key part: while we can edit the drawing on the `PKCanvasView`, we don't yet have a way to retrieve and save the updated drawing. Luckily, there's a protocol called `PKCanvasViewDelegate` that can help us with that.

Let's start by setting up a coordinator object to act as our delegate. When the drawing changes, we'll update the `drawing` property in `DrawingCanvas`, but only if we're not updating it from the SwiftUI side of things. Add this to the top of `DrawingCanvas`:

```swift
struct DrawingCanvas: UIViewRepresentable {
    // ...
    
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
}
```

Now, we'll tell SwiftUI to create our coordinator whenever it makes a `DrawingCanvas`. Add this method to your `DrawingCanvas`:

```swift
func makeCoordinator() -> Coordinator {
    return Coordinator(parent: self)
}
```

We're almost done! Now all we need to do is wire up the delegate to the PKCanvasView. In `makeUIView`, add this line right after creating the canvas:

```swift
canvas.delegate = context.coordinator
```

Go ahead and run the app again - the **Save to Photos** button should now work!

## Step 4: Add a tool picker

For our final step, we'll add a tool picker so we can change the pen and color we're using. PencilKit provides a class to do this - it's called `PKToolPicker`.

To use it, we'll add it as an `@State` on `DrawingCanvas`:

```swift
@State var toolPicker = PKToolPicker()
```

Then we'll wire it up in `makeUIView`:

```swift
toolPicker.setVisible(true, forFirstResponder: uiView)
toolPicker.addObserver(uiView)
toolPicker.colorUserInterfaceStyle = uiView.traitCollection.userInterfaceStyle
```

We've wired up our PKToolPicker, but if we take a close read at the documentation, you might notice that the tool picker only shows up if the drawing view is focused. In UIKit, the currently focused view is called the **first responder**, and views can either become or resign the first responder when needed.

We'll model this in SwiftUI using the `isFocused` binding we already have. First, in `updateUIView`, we'll need to tell the view to focus or unfocus itself depending on what `isFocused` is:

```swift
func updateUIView(_ uiView: CustomCanvasView, context: Context) {
    context.coordinator.ignoreChanges = true
    defer { context.coordinator.ignoreChanges = false }
    
    if uiView.drawing != drawing {
        uiView.drawing = drawing
    }
    
    if isFocused {
        _ = uiView.becomeFirstResponder()
    } else {
        _ = uiView.resignFirstResponder()
    }
}
```

But that's only part of the story - we'll need the view to tell us when it gets unfocused from an outside source. There are several ways to do this. In our case, we'll make a subclass of PKCanvasView so that we can customize its behavior when it focuses and unfocuses:


```swift
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
```

Now, we'll swap out PKCanvasView for CustomCanvasView. Replace all instances of `PKCanvasView` with `CustomCanvasView`, then modify `makeUIView` so that it sets the `coordinator` property we just added:

```swift
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
```

As a bonus, we've also modified `makeUIView` so that it calls `updateUIView` to set the drawing and the focus state. This helps us get rid of duplicate code, and it makes sure that the two methods behave in the same way.

And that's all! Try running the app now - you should get a floating tool picker!
