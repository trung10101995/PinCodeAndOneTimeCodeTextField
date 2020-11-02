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
    @IBInspectable public var udlMargin: CGFloat = 5
    @IBInspectable public var udlHeight: CGFloat = 3
    
    @IBInspectable public var udlColor: UIColor = UIColor.darkGray
    @IBInspectable public var udlUpdatedColor: UIColor = UIColor.blue
    
    deinit {
        timerFlicker?.invalidate()
    }
    
    private var timerFlicker: Timer?
    
    private var oldFlicerUnderLinesView: UIView?
    
    private var isFlickerUdl: Bool = true
    
    private var currentFlicerUnderLinesView: UIView? {
        didSet {
            
            if !isFlickerUdl {
                return
            }
            
            oldFlicerUnderLinesView?.backgroundColor = udlColor
            oldFlicerUnderLinesView = currentFlicerUnderLinesView
            if currentFlicerUnderLinesView == nil {
                timerFlicker?.invalidate()
            } else {
                currentFlicerUnderLinesView?.backgroundColor = udlUpdatedColor
                initTimer()
            }
        }
    }
    
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
        self.keyboardType = .numberPad
        self.becomeFirstResponder()
    }
    
    func initTimer() {
        timerFlicker?.invalidate()
        
        timerFlicker = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self] (timer) in
            self?.currentFlicerUnderLinesView?.backgroundColor = self?.currentFlicerUnderLinesView?.backgroundColor ?? UIColor.clear == UIColor.clear ? self?.udlUpdatedColor : UIColor.clear
            
        })
    }
    
    func configView(customOneTimeCodeTextFieldDelegate: CustomOneTimeCodeTextFieldDelegate?, isFlickerUdl: Bool = true) {
        clearSetting()
        self.customOneTimeCodeTextFieldDelegate = customOneTimeCodeTextFieldDelegate
        self.isFlickerUdl = isFlickerUdl
        setupTextField()
        setupUnderLines()
        setupLables()
        addGestureRecognizer(tapRecognizer)
    }
    
    private func clearSetting() {
        customOneTimeCodeTextFieldDelegate = nil
        labelsStackView.removeFromSuperview()
        labelsStackView = UIStackView()
        oneTimeCodeLabels.removeAll()
        isFlickerUdl = true
        underLinesStackView.removeFromSuperview()
        underLinesStackView = UIStackView()
        oneTimeCodeUnderLinesView.removeAll()
    }
    
    private func setupTextField() {
        text = ""
        tintColor = .clear
        textColor = .clear
        if #available(iOS 12.0, *) {
            textContentType = .oneTimeCode
        } else {
            textContentType = .name
        }
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
            label.backgroundColor = UIColor.clear
            label.tintColor = self.tintColor
            label.isUserInteractionEnabled = true
            
            labelsStackView.addArrangedSubview(label)
            
            oneTimeCodeLabels.append(label)
        }
        
        font = UIFont.systemFont(ofSize: 0)
        
        addSubview(labelsStackView)
        
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -udlHeight - udlMargin)
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
            
            if  i == 1 {
                currentFlicerUnderLinesView = underLine
            } else {
                underLine.backgroundColor = udlColor
            }
            
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
                currentFlicerUnderLinesView = currentUnderLinesView
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

