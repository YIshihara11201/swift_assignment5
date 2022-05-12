//
//  ViewController.swift
//  Tip Calculator
//
//  Created by Yusuke Ishihara on 2022-05-10.
//
// https://stackoverflow.com/questions/27338573/rounding-a-double-value-to-x-number-of-decimal-places-in-swift
// https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
// https://stackoverflow.com/questions/6370342/implementing-steps-snapping-uislider
// https://stackoverflow.com/questions/24356888/how-do-i-change-the-font-size-of-a-uilabel-in-swift
// https://medium.com/mobile-app-development-publication/making-ios-uitextfield-accept-number-only-4e9f569ae0c6


import UIKit

class ViewController: UIViewController {
    
    lazy var scrollView:UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .lightGray
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        return sv
    }()
    
    lazy var tipLabel:UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.text = "$0.00"
        lb.font = UIFont.systemFont(ofSize: 30)
        lb.translatesAutoresizingMaskIntoConstraints = false
        
        return lb
    }()
    
    lazy var totalBillLabel:UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.text = "Total Amount"
        lb.translatesAutoresizingMaskIntoConstraints = false
        
        return lb
    }()
    
    lazy var tipPercentageLabel:UILabel = {
        let lb = UILabel()
        lb.textAlignment = .left
        lb.text = "Tip Percentage"
        lb.translatesAutoresizingMaskIntoConstraints = false
        
        return lb
    }()
    
    lazy var tipPercentageValueLabel:UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.text = "15%"
        lb.translatesAutoresizingMaskIntoConstraints = false
        
        return lb
    }()
    
    lazy var billAmountTextField:UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.textAlignment = .center
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .numberPad
        tf.addTarget(self, action: #selector(textFieldContentChanged(_ :)), for: .editingDidEnd)
        tf.addTarget(self, action: #selector(textFieldFilter(_ :)), for: .editingChanged)
        
        return tf
    }()
    
    lazy var tipPercentageSlider:UISlider = {
        let slider = UISlider()
        slider.maximumValue = 100
        slider.minimumValue = 0
        slider.value = 15
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        return slider
    }()
    
    lazy var stack:UIStackView = {
        let stack = UIStackView()
        stack.backgroundColor = .yellow
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        registerForKeyboardNotification()
        
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(stack)
        
        [UIView(), tipLabel, totalBillLabel, billAmountTextField, tipPercentageLabel, tipPercentageSlider, tipPercentageValueLabel, UIView()].forEach({stack.addArrangedSubview($0)})
        
        NSLayoutConstraint.activate([
            scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.frameLayoutGuide.heightAnchor.constraint(equalTo: view.heightAnchor),
            stack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, multiplier: 1.0),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: 0),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 30),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -30),
//            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
//            scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: stack.topAnchor),
//            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: stack.bottomAnchor),
//            scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
//            scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
        ])
        
    }
    
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_ :)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let keyboardFrame = info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return }

        let keyboardFrameValue = keyboardFrame.cgRectValue
        let keyboardSize = keyboardFrameValue.size

        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        print(contentInsets)
    }

    @objc func keyboardWillBeHidden(_ notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func textFieldContentChanged(_ sender: UITextField) {
        if let bill = Double(sender.text!) {
            let total = bill * (1+Double(tipPercentageSlider.value/100))
            tipLabel.text = "$\(String(format: "%.2f", total))"
        } else {
            tipLabel.text = "$\(String(format: "%.2f", 0))"
        }
    }
    
    @objc func textFieldFilter(_ sender: UITextField) {
        if let text = sender.text, let intText = Int(text) {
            sender.text = "\(intText)"
        } else {
            sender.text = ""
        }
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        let step:Float = 1
        let tipPercentage = floor(sender.value/step) * step
        sender.value = tipPercentage
        tipPercentageValueLabel.text = "\(String(Int(tipPercentage)))%"
        
        if let bill = Double(billAmountTextField.text!) {
            let total = bill * Double(100+tipPercentage) / 100
            tipLabel.text = "$\(String(format: "%.2f", total))"
        }
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        
        if (string.rangeOfCharacter(from: invalidCharacters) == nil) {
            if let text = textField.text {
                let str = (text as NSString).replacingCharacters(in: range, with: string)
                if let intText = Int(str) {
                    textField.text = "\(intText)"
                } else {
                    textField.text = ""
                }
                return false
            }
            return true
        }
        return false
    }
}
