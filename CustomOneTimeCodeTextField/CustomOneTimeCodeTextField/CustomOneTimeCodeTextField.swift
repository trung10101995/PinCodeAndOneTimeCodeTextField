//
//  CustomOneTimeCodeTextField.swift
//  CustomOneTimeCodeTextField
//
//  Created by Nguyễn Trung on 10/19/20.
//

import Foundation
import UIKit

protocol CustomOneTimeCodeTextFieldDelegate: class {
    func didEnterLastTextField(code: String)
}

class CustomOneTimeCodeTextField: UITextField {
    
    weak var customOneTimeCodeTextFieldDelegate: CustomOneTimeCodeTextFieldDelegate?
    
    @IBInspectable public var udlSpacing: CGFloat = 10
    @IBInspectable public var characterLimit: Int = 5
    @IBInspectable public var udlHeight: CGFloat = 3
    
    @IBInspectable public var udlColor: UIColor = UIColor.darkGray
    @IBInspectable public var udlUpdatedColor: UIColor = UIColor.blue
    
    private var oneTimeCodeLabels = [UILabel]()
    private var oneTimeCodeUnderLinesView = [UIView]()
    
    private var labelsStackView = UIStackView()
    private var underLinesStackView = UIStackView()
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(becomeFirstResponder))
        return recognizer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        configView(customOneTimeCodeTextFieldDelegate: nil)
    }
    
    func configView(customOneTimeCodeTextFieldDelegate: CustomOneTimeCodeTextFieldDelegate?) {
        clearSetting()
        self.customOneTimeCodeTextFieldDelegate = customOneTimeCodeTextFieldDelegate
        
        setupTextField()
        setupLables()
        setupUnderLines()
        addGestureRecognizer(tapRecognizer)
        
    }
    
    private func clearSetting() {
        self.customOneTimeCodeTextFieldDelegate = nil
        labelsStackView.removeFromSuperview()
        labelsStackView = UIStackView()
        oneTimeCodeLabels.removeAll()
        
        underLinesStackView.removeFromSuperview()
        underLinesStackView = UIStackView()
        oneTimeCodeUnderLinesView.removeAll()
    }
    
    private func setupTextField() {
        text = ""
        tintColor = .clear
        textColor = .clear
        textContentType = .oneTimeCode
        borderStyle = .none
        
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        delegate = self
    }
    
    private func setupLables() {
        
        labelsStackView.axis = .horizontal
        labelsStackView.alignment = .fill
        labelsStackView.distribution = .fillEqually
        labelsStackView.spacing = udlSpacing
        
        for _ in 1 ... characterLimit {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.font = self.font
            label.backgroundColor = self.backgroundColor
            label.tintColor = self.tintColor
            label.isUserInteractionEnabled = true
            
            labelsStackView.addArrangedSubview(label)
            
            oneTimeCodeLabels.append(label)
        }
        
        font = UIFont.systemFont(ofSize: 0)
        
        addSubview(labelsStackView)
        
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: topAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupUnderLines() {
        underLinesStackView.translatesAutoresizingMaskIntoConstraints = false
        underLinesStackView.axis = .horizontal
        underLinesStackView.alignment = .fill
        underLinesStackView.distribution = .fillEqually
        underLinesStackView.spacing = udlSpacing
        
        for i in 1 ... characterLimit {
            let underLine = UIView()
            underLine.translatesAutoresizingMaskIntoConstraints = false
            
            underLine.isUserInteractionEnabled = true
            
            underLine.backgroundColor = i == 1 ? udlUpdatedColor : udlColor
            
            underLinesStackView.addArrangedSubview(underLine)
            
            oneTimeCodeUnderLinesView.append(underLine)
        }
        
        addSubview(underLinesStackView)
        
        underLinesStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            underLinesStackView.heightAnchor.constraint(equalToConstant: udlHeight),
            underLinesStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            underLinesStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            underLinesStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    @objc
    private func textDidChange() {
        
        guard let text = self.text, text.count <= oneTimeCodeLabels.count, text.count <= oneTimeCodeUnderLinesView.count else { return }
        
        for i in 0 ..< oneTimeCodeLabels.count {
            let currentLabel = oneTimeCodeLabels[i]
            
            if i < text.count {
                let index = text.index(text.startIndex, offsetBy: i)
                currentLabel.text = String(text[index])
            } else {
                currentLabel.text = ""
            }
        }
        
        if text.count == oneTimeCodeLabels.count {
            customOneTimeCodeTextFieldDelegate?.didEnterLastTextField(code: text)
        }
        
        for i in 0 ..< oneTimeCodeUnderLinesView.count {
            let currentUnderLinesView = oneTimeCodeUnderLinesView[i]
            if i == text.count {
                currentUnderLinesView.backgroundColor = udlUpdatedColor
            } else {
                currentUnderLinesView.backgroundColor = udlColor
            }
        }
    }
}

extension CustomOneTimeCodeTextField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let characterCount = textField.text?.count else { return false }
        return characterCount < oneTimeCodeLabels.count || string == ""
    }
}

