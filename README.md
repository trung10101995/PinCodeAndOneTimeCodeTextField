# PinCodeAndOneTimeCodeTextField

# @IBOutlet
@IBOutlet weak var tf: CustomOneTimeCodeTextField!

# Config
tf.configView(customOneTimeCodeTextFieldDelegate: self)
 
# Delegate
func didEnterLastTextField(code: String) {
  print("didEnterLastTextField")
}

