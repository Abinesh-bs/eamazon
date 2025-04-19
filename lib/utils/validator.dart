
class Validator {
  static String emailPattern =
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$";
  static RegExp emailRegEx = RegExp(emailPattern);

  static bool isEmail(String value) {
    if (emailRegEx.hasMatch(value.trim())) {
      return true;
    }
    return false;
  }


  static String? validateEmail(String value) {
    String email = value.trim();
    if (email.isEmpty) {
      return 'This field is required';
    }
    if (!isEmail(email)) {
      return 'Enter valid email';
    }
    return null;
  }

  static String? validatePhoneNumber(String value) {
    String number = value.trim();
    if (number.isEmpty) {
      return 'This field is required';
    }
  /*  if (number.length < 7) {
      return 'must_be_at_least_7_numbers'.tr();
    }
    if (int.parse(number) == 0) {
      return 'please_enter_a_valid_phone_number'.tr();
    }*/
    return null;
  }


  static String? requiredField(String value) {
    if (value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? noRequiredField() {
    return null;
  }
}
