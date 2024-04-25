class AppValidator {
  //validate username
  String? validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a username";
    }
    return null;
  }

  //validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an email";
    }

    // Regular expression pattern for validating email addresses
    RegExp emailRegExp = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
      multiLine: false,
    );

    if (!emailRegExp.hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }

  // Number phone verification
  String? validateAge(String? value) {
    if (value!.isEmpty) {
      return "Please enter age";
    }
    if (value.length != 2 && value.length != 1) {
      return "Please enter a valid age";
    }

    return null;
  }

  //validate username
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a password";
    }
    return null;
  }

//validate checkbox empty
  String? isEmptyCheck(value) {
    if (value!.isEmpty) {
      return "Please fill details";
    }
    return null;
  }
}
