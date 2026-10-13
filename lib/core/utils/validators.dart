class Validators {
  // مدققات المصادقة (Authentication)

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    if (value.length > 30) {
      return 'كلمة المرور يجب أن لا تتجاوز 30 حرف';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }
    if (value != password) {
      return 'كلمة المرور غير متطابقة';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال الاسم الكامل';
    }
    if (value.length < 3) {
      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    }
    if (value.length > 50) {
      return 'الاسم يجب أن لا يتجاوز 50 حرف';
    }
    return null;
  }

  // مدققات الملف الشخصي (Profile)

  static String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final year = int.tryParse(value);
    if (year == null || year < 1 || year > 5) {
      return 'السنة الدراسية يجب أن تكون بين 1 و 5';
    }
    return null;
  }

  static String? validateGPA(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final gpa = double.tryParse(value);
    if (gpa == null || gpa < 0 || gpa > 5) {
      return 'المعدل التراكمي يجب أن يكون بين 0 و 5';
    }
    return null;
  }

  // مدققات المشاريع والمهام

  static String? validateProjectName(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال اسم المشروع';
    }
    if (value.length < 3) {
      return 'اسم المشروع يجب أن يكون 3 أحرف على الأقل';
    }
    if (value.length > 100) {
      return 'اسم المشروع يجب أن لا يتجاوز 100 حرف';
    }
    return null;
  }

  static String? validateTaskTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال عنوان المهمة';
    }
    if (value.length < 3) {
      return 'عنوان المهمة يجب أن يكون 3 أحرف على الأقل';
    }
    if (value.length > 100) {
      return 'عنوان المهمة يجب أن لا يتجاوز 100 حرف';
    }
    return null;
  }

  static String? validateTaskDescription(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > 500) {
      return 'وصف المهمة يجب أن لا يتجاوز 500 حرف';
    }
    return null;
  }

  static String? validatePriority(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final priority = int.tryParse(value);
    if (priority == null || priority < 1 || priority > 5) {
      return 'الأولوية يجب أن تكون بين 1 و 5';
    }
    return null;
  }

  // مدققات عامة

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال $fieldName';
    }
    if (value.length < minLength) {
      return 'يجب أن يكون $fieldName $minLength أحرف على الأقل';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > maxLength) {
      return 'يجب أن لا يتجاوز $fieldName $maxLength حرف';
    }
    return null;
  }

  // مدققات التاريخ

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى اختيار تاريخ';
    }
    return null;
  }

  static String? validateFutureDate(DateTime? date) {
    if (date == null) {
      return 'يرجى اختيار تاريخ';
    }
    if (date.isBefore(DateTime.now())) {
      return 'التاريخ يجب أن يكون في المستقبل';
    }
    return null;
  }

  // مدققات الروابط

  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final urlRegex = RegExp(r'^https?://[\w-]+(\.[\w-]+)+([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?$');
    if (!urlRegex.hasMatch(value)) {
      return 'الرابط غير صحيح (يجب أن يبدأ بـ http:// أو https://)';
    }
    return null;
  }

  static String? validateGitHubUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final githubRegex = RegExp(r'^https?://github\.com/[\w-]+/[\w-]+/?$');
    if (!githubRegex.hasMatch(value)) {
      return 'رابط GitHub غير صحيح';
    }
    return null;
  }
}