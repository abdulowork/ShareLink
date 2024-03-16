import SwiftUI

public struct IconView: View {
    public init() {}
    
    public var body: some View {
        ZStack(alignment:.center) {
            Rectangle()
                .fill(Color.gray)
                .cornerRadius(5)
                .padding(2)
            Text("sl")
                .frame(maxWidth: .infinity, maxHeight: .infinity,  alignment: .bottomTrailing)
                .padding(.trailing, 5)
        }
    }
}
