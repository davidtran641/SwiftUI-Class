//
//  ViewController.swift
//  SwiftUIClassDemo
//
//  Created by david.tran on 19/11/21.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {

    private lazy var viewModel: MetadataViewModel = {
        let layout = ViewLayout(width: 400, height: nil)
        let content = String(repeating:  "This is a very long title and content ",
                             count: 3)
        return MetadataViewModel(viewLayout: layout, content: content)
    }()
    
    private lazy var presenter: Presenter = Presenter(viewModel: viewModel)
    
    private lazy var metaViewController = UIHostingController<MetadataView>(rootView: MetadataView(presenter: presenter))
    
    private lazy var button = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        metaViewController.willMove(toParent: self)
        metaViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(metaViewController)
        view.addSubview(metaViewController.view)
        metaViewController.didMove(toParent: self)
        
        button.setTitle("Change style", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.addTarget(self, action: #selector(didClickButton), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        metaViewController.view.frame = view.bounds
        
        let size = view.bounds.size
        button.frame = CGRect(x: size.width / 2 - 50, y: size.height - 100, width: 100, height: 50)
    }
    
    @objc func didClickButton() {
        presenter.updateLayout()
    }

}

struct MetadataView: View {
    @ObservedObject var presenter: Presenter
    
    init(presenter: Presenter) {
        self.presenter = presenter
    }
    
    var body: some View {
        let viewLayout = presenter.viewModel?.viewLayout
        HStack {
            if viewLayout?.alignment == .center {
                Spacer()
            }
            VStack(alignment: viewLayout?.alignment == .center ? .center : .leading) {
                Text("Title")
                    .font(.title)
                
                if let subtitle = presenter.viewModel?.subtitle {
                    TextView(viewModel: subtitle, preferredLayout: nil)
                        .border(.blue, width: 3)
                }
            }
            .border(.red, width: 2)
            
            Spacer()
        }
        .frame(width: viewLayout?.width, height: viewLayout?.height)
        .border(.green, width: 1)
    }
}

struct TextView: View {
    private let viewModel: TextViewModel
    private let preferredLayout: ViewLayout?
    init(viewModel: TextViewModel, preferredLayout: ViewLayout?) {
        self.viewModel = viewModel
        self.preferredLayout = preferredLayout
    }
    
    var body: some View {
        let layout = preferredLayout ?? viewModel.viewLayout
        
        Text(viewModel.content)
            .frame(width: layout?.width, height: layout?.height)
            .multilineTextAlignment(layout?.alignment == .center ? .center : .leading)
            .lineLimit(layout?.numberOfLines)
            
    }
}

class Presenter: ObservableObject {
    @Published var viewModel: MetadataViewModel?
    
    private var isIpad: Bool = false
    
    init(viewModel: MetadataViewModel?) {
        self.viewModel = viewModel
        changeLayout()
    }
    
    func updateLayout() {
        isIpad.toggle()
        changeLayout()
        
        // triger swift ui update
        self.viewModel = viewModel
    }
    
    private func changeLayout() {
        if isIpad {
            viewModel?.viewLayout?.updateLayout(numberOfLines: 0, alignment: .left)
            viewModel?.subtitle.viewLayout?.updateLayout(numberOfLines: 3, alignment: .left)
        } else {
            viewModel?.viewLayout?.updateLayout(numberOfLines: 0, alignment: .center)
            viewModel?.subtitle.viewLayout?.updateLayout(numberOfLines: 2, alignment: .center)
        }
    }
}

class ViewModel {
    private(set) var viewLayout: ViewLayout? = nil
    init(viewLayout: ViewLayout?) {
        self.viewLayout = viewLayout
    }
}

class ViewLayout {
    private(set) var width: CGFloat?
    private(set) var height: CGFloat?
    private(set) var alignment: NSTextAlignment
    private(set) var numberOfLines: Int = 0
    
    init(width: CGFloat? = nil, height: CGFloat? = nil, alignment: NSTextAlignment = .left, numberOfLines: Int = 0) {
        self.width = width
        self.height = height
        self.alignment = alignment
        self.numberOfLines = numberOfLines
    }
    
    func updateLayout(numberOfLines: Int, alignment: NSTextAlignment) {
        self.numberOfLines = numberOfLines
        self.alignment = alignment
    }
    
}

class TextViewModel: ViewModel {
    private(set) var content: String
    
    init(content: String, viewLayout: ViewLayout?) {
        self.content = content
        super.init(viewLayout: viewLayout)
    }
}

class MetadataViewModel: ViewModel {
    private(set) var subtitle: TextViewModel
    
    init(viewLayout: ViewLayout?, content: String) {
        self.subtitle = TextViewModel(content: content, viewLayout: ViewLayout(width: 240, height: nil, alignment: .left, numberOfLines: 2))
        super.init(viewLayout: viewLayout)
    }
}

