import UIKit

func presentLoadingAlert(on viewController: UIViewController?, title: String, message: String, cancelButtonCTA: String, delay: TimeInterval, cancelAction: (() -> Void)?) {
    let alert = UIAlertController(title: title, message: "\(message)\n\n\n", preferredStyle: .alert)

    let cancelAction = UIAlertAction(title: cancelButtonCTA, style: .cancel) { _ in cancelAction?() }
    cancelAction.isEnabled = false
    alert.addAction(cancelAction)

    let spinner = UIActivityIndicatorView(style: .large)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.startAnimating()
    
    alert.view.addSubview(spinner)

    NSLayoutConstraint.activate([
        spinner.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
        spinner.centerYAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -80)
    ])

    viewController?.present(alert, animated: true)

    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        cancelAction.isEnabled = true
    }
}

fileprivate class PreviewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            presentLoadingAlert (on: self, 
                                 title: "Talking to server..", 
                                 message: "You won't lose any progress if you cancel this.", 
                                 cancelButtonCTA: "Nevermind that", 
                                 delay: 5, 
                                 cancelAction: {
                                     print("hello")
                                 }
            )
        }
    }
    
}

#Preview {
    PreviewController()
}
