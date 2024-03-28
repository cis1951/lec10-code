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