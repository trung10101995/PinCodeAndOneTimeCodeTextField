//
//  ViewController.swift
//  CustomOneTimeCodeTextField
//
//  Created by Nguyễn Trung on 10/19/20.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tf: CustomOneTimeCodeTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround() 
        tf.configView(customOneTimeCodeTextFieldDelegate: self)
    }
}

extension ViewController: CustomOneTimeCodeTextFieldDelegate {
    func didEnterLastTextField(code: String) {
        print("didEnterLastTextField")
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
