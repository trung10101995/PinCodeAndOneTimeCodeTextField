# PinCodeAndOneTimeCodeTextField

# @IBOutlet
@IBOutlet weak var tf: CustomOneTimeCodeTextField!

# Congif
tf.configView(customOneTimeCodeTextFieldDelegate: self)
 
# Delegate
func didEnterLastTextField(code: String) {
  print("didEnterLastTextField")
}
