import SwiftUI

// MARK: - NavigationIndicator
struct NavigationIndicator: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARView
    func makeUIViewController(context: Context) -> ARView {
        return ARView()
    }
    func updateUIViewController(_ uiViewController:
                                NavigationIndicator.UIViewControllerType, context:
                                UIViewControllerRepresentableContext<NavigationIndicator>) { }
}

struct ContentView: View {
    @State var page = "Home"
    
    var body: some View {
        VStack {
            if page == "Home" {
                Spacer()
                Spacer()
                Text("This is a demo application to showcase augmented reality features.")
                    .textStyle(MessageStyle()).frame(maxWidth: 400)
                Button("Start AR") {
                    self.page = "ARView"
                }.buttonStyle(AccentButtonStyle())
                Spacer()
                
                Text("This application was solely developed on an iPad using Swift Playgrounds and available online resources.")
                    .textStyle(MessageStyle()).frame(maxWidth: 400)
            } 
            else if page == "ARView" {
                ZStack {
                    ARViewIndicator()
                    VStack {
                        Spacer()
                        Button("Quit AR") {
                            self.page = "Home"
                        }.buttonStyle(AccentButtonStyle())
                    }
                }
            }
        }
    }
}
