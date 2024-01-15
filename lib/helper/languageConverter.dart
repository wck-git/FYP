import '../model/language.dart';

class LanguageConverterHelper {
  //main
  static String getHirePeopleTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Hire People";
    } else if (language == Language.chinese) {
      textLang = "雇用人员";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Mengupah Kakitangan";
    } else if (language == Language.tamil) {
      textLang = "மனிதர்களை வாடகையிடு";
    }

    return textLang;
  }

  static String getFindJobTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Find Job";
    } else if (language == Language.chinese) {
      textLang = "找工作";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Mencari Kerja";
    } else if (language == Language.tamil) {
      textLang = "வேலை தேடு";
    }

    return textLang;
  }

  // general dialog
  static String getIncreaseAudioTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Increase your phone volume. Try again.";
    } else if (language == Language.chinese) {
      textLang = "调高手机音量。请重试";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Tingkatkan kelantangan telefon anda. Cuba lagi.";
    } else if (language == Language.tamil) {
      textLang =
          "உங்கள் தொலைபேசியின் ஒலியளவை அதிகரிக்கவும். மீண்டும் முயற்சி செய்";
    }

    return textLang;
  }

  static String getTooManyTimesTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Too many times. Try again";
    } else if (language == Language.chinese) {
      textLang = "尝试次数过多。请重试";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Terlalu banyak kali. Cuba lagi";
    } else if (language == Language.tamil) {
      textLang = "மிகக் கூடிய முயற்சிகள். மீண்டும் முயற்சி செய்";
    }

    return textLang;
  }

  static String getNoWifiTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "No WiFi. Try again";
    } else if (language == Language.chinese) {
      textLang = "没有WiFi。请重试";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Tiada WiFi. Cuba lagi";
    } else if (language == Language.tamil) {
      textLang = "வைப்பை இல்லை. மீண்டும் முயற்சி செய்";
    }

    return textLang;
  }

  // page title
  static String getHomeTitleTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "MY JOB POSTS";
    } else if (language == Language.chinese) {
      textLang = "我发布的工作";
    } else if (language == Language.bahasaMelayu) {
      textLang = "IKLAN KERJA SAYA";
    } else if (language == Language.tamil) {
      textLang = "வேலை வெளியிட்டல்கள்";
    }

    return textLang;
  }

  static String getApplicantsListTitleTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "APPLICANTS";
    } else if (language == Language.chinese) {
      textLang = "申请者";
    } else if (language == Language.bahasaMelayu) {
      textLang = "PEMOHON";
    } else if (language == Language.tamil) {
      textLang = "விண்ணப்பர்கள்";
    }

    return textLang;
  }

  static String getNewJobTitleTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "POST JOB";
    } else if (language == Language.chinese) {
      textLang = "发布工作";
    } else if (language == Language.bahasaMelayu) {
      textLang = "LEPAS KERJA";
    } else if (language == Language.tamil) {
      textLang = "பிந்தைய வேலை";
    }

    return textLang;
  }

  // general
  static String getZeroJobsPostedTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "0 Jobs Posted";
    } else if (language == Language.chinese) {
      textLang = "0个职位发布";
    } else if (language == Language.bahasaMelayu) {
      textLang = "0 Kerja Diposkan";
    } else if (language == Language.tamil) {
      textLang = "பதவிகள் தவிர்க்கப்பட்டுள்ளன";
    }

    return textLang;
  }

  static String getZeroApplicantsPostedTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "0 Applicants";
    } else if (language == Language.chinese) {
      textLang = "0个人申请";
    } else if (language == Language.bahasaMelayu) {
      textLang = "0 Pemohon";
    } else if (language == Language.tamil) {
      textLang = "விண்ணப்பங்கள் இல்லை";
    }

    return textLang;
  }

  // login and sign up
  static String getEmailTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Email";
    } else if (language == Language.chinese) {
      textLang = "电子邮件";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Emel";
    } else if (language == Language.tamil) {
      textLang = "மின்னஞ்சல்";
    }

    return textLang;
  }

  static String getPasswordTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Password";
    } else if (language == Language.chinese) {
      textLang = "密码";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Kata Laluan";
    } else if (language == Language.tamil) {
      textLang = "கடவுச்சொல்";
    }

    return textLang;
  }

  static String getMobileNumTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Phone Number";
    } else if (language == Language.chinese) {
      textLang = "电话号码";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Nombor Telefon";
    } else if (language == Language.tamil) {
      textLang = "தொலைபேசி எண்";
    }

    return textLang;
  }

  static String getNameTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Name";
    } else if (language == Language.chinese) {
      textLang = "名字";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Nama";
    } else if (language == Language.tamil) {
      textLang = "பெயர்";
    }

    return textLang;
  }

  static String getGenderTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Gender";
    } else if (language == Language.chinese) {
      textLang = "性别";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Jantina";
    } else if (language == Language.tamil) {
      textLang = "பாலினம் ";
    }

    return textLang;
  }

  static String getBusinessNameTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Shop Name";
    } else if (language == Language.chinese) {
      textLang = "店名";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Nama Kedai";
    } else if (language == Language.tamil) {
      textLang = "பெயர்";
    }

    return textLang;
  }

  static String getAddressTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Shop Address";
    } else if (language == Language.chinese) {
      textLang = "店地址";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Alamat Kedai";
    } else if (language == Language.tamil) {
      textLang = "முகவரி";
    }

    return textLang;
  }

  static String getStatesTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Shop States";
    } else if (language == Language.chinese) {
      textLang = "店州";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Negeri Kedai";
    } else if (language == Language.tamil) {
      textLang = "கடை மாநிலங்கள்";
    }

    return textLang;
  }

  static String getTakePhotoTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Selfie";
    } else if (language == Language.chinese) {
      textLang = "自拍";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Selfie";
    } else if (language == Language.tamil) {
      textLang = "சுவர் பெயர்த்தல்";
    }

    return textLang;
  }

  static String getWrongEmailTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Wrong email";
    } else if (language == Language.chinese) {
      textLang = "电子邮件错误";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Emel salah";
    } else if (language == Language.tamil) {
      textLang = "மின்னஞ்சல் தவறானது";
    }

    return textLang;
  }

  static String getWrongPasswordTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Wrong password";
    } else if (language == Language.chinese) {
      textLang = "密码错误";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Kata laluan salah";
    } else if (language == Language.tamil) {
      textLang = "கடவுச்சொல் தவறு";
    }

    return textLang;
  }

  static String getPasswordLengthTextBelowLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Length must be more than 6";
    } else if (language == Language.chinese) {
      textLang = "长度必须大于6";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Panjang mesti lebih dari 6";
    } else if (language == Language.tamil) {
      textLang = "நீளம் 6 விட அதிகமாக இருக்க வேண்டும்";
    }

    return textLang;
  }

  static String getPasswordLengthTextMoreLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Length cannot be more than 15";
    } else if (language == Language.chinese) {
      textLang = "长度不能超过15";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Panjang tidak boleh melebihi 15";
    } else if (language == Language.tamil) {
      textLang = "நீளம் 15-ஐ மீட்டமைக்க முடியாது";
    }

    return textLang;
  }

  static String getSignUpSuccessTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Register Success";
    } else if (language == Language.chinese) {
      textLang = "注册成功";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Pendaftaran Berjaya";
    } else if (language == Language.tamil) {
      textLang = "பதிவு முடிந்தது";
    }

    return textLang;
  }

  // job
  static String getJobNameLang(String language, String jobName) {
    String textLang = "";

    if (language == Language.english) {
      if (jobName == "Waiter") {
        textLang = "Waiter";
      }
      if (jobName == "Cashier") {
        textLang = "Cashier";
      }
      if (jobName == "Dish Washer") {
        textLang = "Dish Washer";
      }
      if (jobName == "Promoter") {
        textLang = "Promoter";
      }
      if (jobName == "Cleaner") {
        textLang = "Cleaner";
      }
    } else if (language == Language.chinese) {
      if (jobName == "Waiter") {
        textLang = "服务员";
      }
      if (jobName == "Cashier") {
        textLang = "收银员";
      }
      if (jobName == "Dish Washer") {
        textLang = "洗碗员";
      }
      if (jobName == "Promoter") {
        textLang = "推销员";
      }
      if (jobName == "Cleaner") {
        textLang = "清洁工";
      }
    } else if (language == Language.bahasaMelayu) {
      if (jobName == "Waiter") {
        textLang = "Pelayan";
      }
      if (jobName == "Cashier") {
        textLang = "Juruwang";
      }
      if (jobName == "Dish Washer") {
        textLang = "Pembasuh Pinggan";
      }
      if (jobName == "Promoter") {
        textLang = "Jurujual";
      }
      if (jobName == "Cleaner") {
        textLang = "Pembersih";
      }
    } else if (language == Language.tamil) {
      if (jobName == "Waiter") {
        textLang = "காப்பான்";
      }
      if (jobName == "Cashier") {
        textLang = "பணக்காரர்";
      }
      if (jobName == "Dish Washer") {
        textLang = "டிஷ் வாஷர்";
      }
      if (jobName == "Promoter") {
        textLang = "மின்னணுவர்";
      }
      if (jobName == "Cleaner") {
        textLang = "சுத்தமாக்குபவர்";
      }
    }

    return textLang;
  }

  static String getHoursTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "hours";
    } else if (language == Language.chinese) {
      textLang = "小时";
    } else if (language == Language.bahasaMelayu) {
      textLang = "jam";
    } else if (language == Language.tamil) {
      textLang = "மணிநேரம்";
    }

    return textLang;
  }

  static String getAgeTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "years old";
    } else if (language == Language.chinese) {
      textLang = "岁";
    } else if (language == Language.bahasaMelayu) {
      textLang = "tahun";
    } else if (language == Language.tamil) {
      textLang = "வயது";
    }

    return textLang;
  }

  static String getGenderLang(String language, String gender) {
    String textLang = "";

    if (language == Language.english) {
      if (gender == "Boy") {
        textLang = "Boy";
      } else {
        textLang = "Girl";
      }
    } else if (language == Language.chinese) {
      if (gender == "Boy") {
        textLang = "男";
      } else {
        textLang = "女";
      }
    } else if (language == Language.bahasaMelayu) {
      if (gender == "Boy") {
        textLang = "Lelaki";
      } else {
        textLang = "Perempuan";
      }
    } else if (language == Language.tamil) {
      if (gender == "Boy") {
        textLang = "ஆண் பிள்ளை";
      } else {
        textLang = "பெண் பிள்ளை";
      }
    }

    return textLang;
  }

  // new job
  static String getJobTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Job Name";
    } else if (language == Language.chinese) {
      textLang = "工作";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Pekerjaan";
    } else if (language == Language.tamil) {
      textLang = "வேலை";
    }

    return textLang;
  }

  static String getDateTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Date";
    } else if (language == Language.chinese) {
      textLang = "日期";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Tarikh";
    } else if (language == Language.tamil) {
      textLang = "தேதி";
    }

    return textLang;
  }

  static String getStartTimeTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Job Start Time";
    } else if (language == Language.chinese) {
      textLang = "工作开始时间";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Masa mula kerja";
    } else if (language == Language.tamil) {
      textLang = "வேலை தொடக்க நேரம்";
    }

    return textLang;
  }

  static String getEndTimeTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Job End Time";
    } else if (language == Language.chinese) {
      textLang = "工作结束时间";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Masa tamat kerja";
    } else if (language == Language.tamil) {
      textLang = "முடிவு தொடக்க நேரம்";
    }

    return textLang;
  }

  static String getJobPayTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Job Pay";
    } else if (language == Language.chinese) {
      textLang = "工钱";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Gaji kerja";
    } else if (language == Language.tamil) {
      textLang = "வேலை சம்பளம்";
    }

    return textLang;
  }

  static String getJobPayInvalidTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Job Pay cannot more than RM 300";
    } else if (language == Language.chinese) {
      textLang = "工资不能超过 RM300";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Gaji tidak boleh melebihi RM 300";
    } else if (language == Language.tamil) {
      textLang = "RM300 மேல் அதிகமாக இருக்க முடியாது";
    }

    return textLang;
  }

  static String getEndTimeConditionTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "End Time must be Later than Start Time";
    } else if (language == Language.chinese) {
      textLang = "结束时间必须晚于开始时间";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Masa Tamat mesti Lebih Lambat daripada Masa Mula";
    } else if (language == Language.tamil) {
      textLang = "முடிவு நேரம் தொடக்க நேரத்திற்கு பிறகு இருக்க வேண்டும்";
    }

    return textLang;
  }

  static String getAddJobSuccessTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Add Success";
    } else if (language == Language.chinese) {
      textLang = "添加成功";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Ditambah dengan berjaya";
    } else if (language == Language.tamil) {
      textLang = "சேர்த்துக்கொள்ளும் வெற்";
    }

    return textLang;
  }

  // job details
  static String getDeleteSuccessTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Delete Success";
    } else if (language == Language.chinese) {
      textLang = "删除成功";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Padam berjaya";
    } else if (language == Language.tamil) {
      textLang = "நீக்கு வெற்றி";
    }

    return textLang;
  }

  // applicant list
  static String getAcceptFailedTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Accept Failed";
    } else if (language == Language.chinese) {
      textLang = "接受失败";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Gagal menerima";
    } else if (language == Language.tamil) {
      textLang = "ஏற்றமுடியாதது";
    }

    return textLang;
  }

  static String getAcceptSuccessTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Accept Successful";
    } else if (language == Language.chinese) {
      textLang = "接受成功";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Berjaya diterima";
    } else if (language == Language.tamil) {
      textLang = "ஏற்கப்பட்டது வெற்றி";
    }

    return textLang;
  }

  static String getRejectFailedTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Reject Failed";
    } else if (language == Language.chinese) {
      textLang = "拒绝失败";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Gagal menolak";
    } else if (language == Language.tamil) {
      textLang = "மறுக்கப்படாதது";
    }

    return textLang;
  }

  static String getRejectSuccessTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Reject Success";
    } else if (language == Language.chinese) {
      textLang = "拒绝成功";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Berjaya ditolak";
    } else if (language == Language.tamil) {
      textLang = "மறுக்கப்பட்டது வெற்றி";
    }

    return textLang;
  }

  // edit profile
  static String getEditProfileSuccessTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Edit Success";
    } else if (language == Language.chinese) {
      textLang = "更改成功";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Perubahan berjaya";
    } else if (language == Language.tamil) {
      textLang = "மாற்றம் வெற்றி";
    }

    return textLang;
  }

  //
  static String getLoginTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Login";
    } else if (language == Language.chinese) {
      textLang = "登录";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Log Masuk";
    } else if (language == Language.tamil) {
      textLang = "உள்நுழைய";
    }

    return textLang;
  }

  static String getSignUpTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Register";
    } else if (language == Language.chinese) {
      textLang = "报名";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Daftar";
    } else if (language == Language.tamil) {
      textLang = "பதிவு";
    }

    return textLang;
  }

  static String getLogoutTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Logout";
    } else if (language == Language.chinese) {
      textLang = "登出";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Log Keluar";
    } else if (language == Language.tamil) {
      textLang = "வெளியேறு";
    }

    return textLang;
  }

  static String getDeleteTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Delete";
    } else if (language == Language.chinese) {
      textLang = "删除";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Padam";
    } else if (language == Language.tamil) {
      textLang = "அழி";
    }

    return textLang;
  }

  static String getEditProfileTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Change Profile";
    } else if (language == Language.chinese) {
      textLang = "更改个人资料";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Tukar profil";
    } else if (language == Language.tamil) {
      textLang = "சுயவிவரத்தை மாற்றவும்";
    }

    return textLang;
  }

  static String getApplicantTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Applicant";
    } else if (language == Language.chinese) {
      textLang = "申请人";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Pemohon";
    } else if (language == Language.tamil) {
      textLang = "விண்ணப்பதாரர்";
    }

    return textLang;
  }

  static String getEmployeeTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Worker";
    } else if (language == Language.chinese) {
      textLang = "工人";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Pekerja";
    } else if (language == Language.tamil) {
      textLang = "தொழிலாளி";
    }

    return textLang;
  }

  static String getNewJobTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Post Job";
    } else if (language == Language.chinese) {
      textLang = "发布工作";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Lepas Kerja";
    } else if (language == Language.tamil) {
      textLang = "பிந்தைய வேலை";
    }

    return textLang;
  }

  static String getAcceptTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Accept";
    } else if (language == Language.chinese) {
      textLang = "接受";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Terima";
    } else if (language == Language.tamil) {
      textLang = "ஏற்றுக்கொள்";
    }

    return textLang;
  }

  static String getRejectTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Reject";
    } else if (language == Language.chinese) {
      textLang = "拒绝";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Menolak";
    } else if (language == Language.tamil) {
      textLang = "நிராகரி";
    }

    return textLang;
  }

  static String getHomeTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Home";
    } else if (language == Language.chinese) {
      textLang = "主页";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Utama";
    } else if (language == Language.tamil) {
      textLang = "முகப்பு";
    }

    return textLang;
  }

  static String getBackTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Back";
    } else if (language == Language.chinese) {
      textLang = "返回";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Kembali";
    } else if (language == Language.tamil) {
      textLang = "முன்";
    }

    return textLang;
  }

  static String getHelpTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Help";
    } else if (language == Language.chinese) {
      textLang = "帮助";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Bantuan";
    } else if (language == Language.tamil) {
      textLang = "உதவி";
    }

    return textLang;
  }

  static String getProfileTextLang(String language) {
    String textLang = "";

    if (language == Language.english) {
      textLang = "Profile";
    } else if (language == Language.chinese) {
      textLang = "个人资料";
    } else if (language == Language.bahasaMelayu) {
      textLang = "Profil";
    } else if (language == Language.tamil) {
      textLang = "பத்தியம்";
    }

    return textLang;
  }
}
