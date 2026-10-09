enum Region { arab, asia, africa, europe, americas, oceania }

const regionNames = {
  Region.arab: 'الدول العربية',
  Region.asia: 'آسيا',
  Region.africa: 'أفريقيا',
  Region.europe: 'أوروبا',
  Region.americas: 'الأمريكتان',
  Region.oceania: 'أوقيانوسيا',
};

class Country {
  final String code;
  final String name;
  final String capital;
  final Region region;
  final bool arab;

  const Country(this.code, this.name, this.capital, this.region,
      {this.arab = false});

  /// علم الدولة كرمز تعبيري (Emoji) مبني من رمز ISO، فلا نحتاج صوراً.
  String get flag => String.fromCharCodes(
      code.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 65));

  bool inRegion(Region r) => r == Region.arab ? arab : region == r;
}

const countries = <Country>[
  // الدول العربية
  Country('SA', 'السعودية', 'الرياض', Region.asia, arab: true),
  Country('AE', 'الإمارات', 'أبوظبي', Region.asia, arab: true),
  Country('KW', 'الكويت', 'مدينة الكويت', Region.asia, arab: true),
  Country('QA', 'قطر', 'الدوحة', Region.asia, arab: true),
  Country('BH', 'البحرين', 'المنامة', Region.asia, arab: true),
  Country('OM', 'عُمان', 'مسقط', Region.asia, arab: true),
  Country('YE', 'اليمن', 'صنعاء', Region.asia, arab: true),
  Country('IQ', 'العراق', 'بغداد', Region.asia, arab: true),
  Country('SY', 'سوريا', 'دمشق', Region.asia, arab: true),
  Country('JO', 'الأردن', 'عمّان', Region.asia, arab: true),
  Country('LB', 'لبنان', 'بيروت', Region.asia, arab: true),
  Country('PS', 'فلسطين', 'القدس', Region.asia, arab: true),
  Country('EG', 'مصر', 'القاهرة', Region.africa, arab: true),
  Country('SD', 'السودان', 'الخرطوم', Region.africa, arab: true),
  Country('LY', 'ليبيا', 'طرابلس', Region.africa, arab: true),
  Country('TN', 'تونس', 'تونس', Region.africa, arab: true),
  Country('DZ', 'الجزائر', 'الجزائر', Region.africa, arab: true),
  Country('MA', 'المغرب', 'الرباط', Region.africa, arab: true),
  Country('MR', 'موريتانيا', 'نواكشوط', Region.africa, arab: true),
  Country('SO', 'الصومال', 'مقديشو', Region.africa, arab: true),
  Country('DJ', 'جيبوتي', 'جيبوتي', Region.africa, arab: true),
  Country('KM', 'جزر القمر', 'موروني', Region.africa, arab: true),
  // آسيا
  Country('TR', 'تركيا', 'أنقرة', Region.asia),
  Country('IR', 'إيران', 'طهران', Region.asia),
  Country('PK', 'باكستان', 'إسلام آباد', Region.asia),
  Country('AF', 'أفغانستان', 'كابل', Region.asia),
  Country('IN', 'الهند', 'نيودلهي', Region.asia),
  Country('BD', 'بنغلاديش', 'دكا', Region.asia),
  Country('CN', 'الصين', 'بكين', Region.asia),
  Country('JP', 'اليابان', 'طوكيو', Region.asia),
  Country('KR', 'كوريا الجنوبية', 'سيول', Region.asia),
  Country('KP', 'كوريا الشمالية', 'بيونغ يانغ', Region.asia),
  Country('ID', 'إندونيسيا', 'جاكرتا', Region.asia),
  Country('MY', 'ماليزيا', 'كوالالمبور', Region.asia),
  Country('TH', 'تايلاند', 'بانكوك', Region.asia),
  Country('VN', 'فيتنام', 'هانوي', Region.asia),
  Country('PH', 'الفلبين', 'مانيلا', Region.asia),
  Country('SG', 'سنغافورة', 'سنغافورة', Region.asia),
  Country('KZ', 'كازاخستان', 'أستانا', Region.asia),
  Country('UZ', 'أوزبكستان', 'طشقند', Region.asia),
  Country('AZ', 'أذربيجان', 'باكو', Region.asia),
  Country('NP', 'نيبال', 'كاتماندو', Region.asia),
  Country('LK', 'سريلانكا', 'كولومبو', Region.asia),
  Country('MV', 'جزر المالديف', 'ماليه', Region.asia),
  Country('MN', 'منغوليا', 'أولان باتور', Region.asia),
  // أفريقيا
  Country('NG', 'نيجيريا', 'أبوجا', Region.africa),
  Country('ET', 'إثيوبيا', 'أديس أبابا', Region.africa),
  Country('KE', 'كينيا', 'نيروبي', Region.africa),
  Country('ZA', 'جنوب أفريقيا', 'بريتوريا', Region.africa),
  Country('GH', 'غانا', 'أكرا', Region.africa),
  Country('SN', 'السنغال', 'داكار', Region.africa),
  Country('TZ', 'تنزانيا', 'دودوما', Region.africa),
  Country('UG', 'أوغندا', 'كمبالا', Region.africa),
  Country('CM', 'الكاميرون', 'ياوندي', Region.africa),
  Country('ML', 'مالي', 'باماكو', Region.africa),
  Country('NE', 'النيجر', 'نيامي', Region.africa),
  Country('TD', 'تشاد', 'نجامينا', Region.africa),
  Country('ER', 'إريتريا', 'أسمرة', Region.africa),
  Country('AO', 'أنغولا', 'لواندا', Region.africa),
  Country('CI', 'ساحل العاج', 'ياموسوكرو', Region.africa),
  Country('RW', 'رواندا', 'كيغالي', Region.africa),
  Country('ZW', 'زيمبابوي', 'هراري', Region.africa),
  Country('MG', 'مدغشقر', 'أنتاناناريفو', Region.africa),
  // أوروبا
  Country('GB', 'المملكة المتحدة', 'لندن', Region.europe),
  Country('FR', 'فرنسا', 'باريس', Region.europe),
  Country('DE', 'ألمانيا', 'برلين', Region.europe),
  Country('IT', 'إيطاليا', 'روما', Region.europe),
  Country('ES', 'إسبانيا', 'مدريد', Region.europe),
  Country('PT', 'البرتغال', 'لشبونة', Region.europe),
  Country('NL', 'هولندا', 'أمستردام', Region.europe),
  Country('BE', 'بلجيكا', 'بروكسل', Region.europe),
  Country('CH', 'سويسرا', 'برن', Region.europe),
  Country('AT', 'النمسا', 'فيينا', Region.europe),
  Country('SE', 'السويد', 'ستوكهولم', Region.europe),
  Country('NO', 'النرويج', 'أوسلو', Region.europe),
  Country('DK', 'الدنمارك', 'كوبنهاغن', Region.europe),
  Country('FI', 'فنلندا', 'هلسنكي', Region.europe),
  Country('PL', 'بولندا', 'وارسو', Region.europe),
  Country('GR', 'اليونان', 'أثينا', Region.europe),
  Country('IE', 'أيرلندا', 'دبلن', Region.europe),
  Country('UA', 'أوكرانيا', 'كييف', Region.europe),
  Country('RU', 'روسيا', 'موسكو', Region.europe),
  Country('RO', 'رومانيا', 'بوخارست', Region.europe),
  Country('HU', 'المجر', 'بودابست', Region.europe),
  Country('CZ', 'التشيك', 'براغ', Region.europe),
  Country('BA', 'البوسنة والهرسك', 'سراييفو', Region.europe),
  Country('AL', 'ألبانيا', 'تيرانا', Region.europe),
  Country('HR', 'كرواتيا', 'زغرب', Region.europe),
  Country('RS', 'صربيا', 'بلغراد', Region.europe),
  Country('IS', 'آيسلندا', 'ريكيافيك', Region.europe),
  // الأمريكتان
  Country('US', 'الولايات المتحدة', 'واشنطن', Region.americas),
  Country('CA', 'كندا', 'أوتاوا', Region.americas),
  Country('MX', 'المكسيك', 'مكسيكو سيتي', Region.americas),
  Country('BR', 'البرازيل', 'برازيليا', Region.americas),
  Country('AR', 'الأرجنتين', 'بوينس آيرس', Region.americas),
  Country('CL', 'تشيلي', 'سانتياغو', Region.americas),
  Country('CO', 'كولومبيا', 'بوغوتا', Region.americas),
  Country('PE', 'بيرو', 'ليما', Region.americas),
  Country('VE', 'فنزويلا', 'كاراكاس', Region.americas),
  Country('CU', 'كوبا', 'هافانا', Region.americas),
  Country('EC', 'الإكوادور', 'كيتو', Region.americas),
  Country('UY', 'الأوروغواي', 'مونتيفيديو', Region.americas),
  Country('PY', 'باراغواي', 'أسونسيون', Region.americas),
  Country('BO', 'بوليفيا', 'سوكري', Region.americas),
  Country('JM', 'جامايكا', 'كينغستون', Region.americas),
  Country('PA', 'بنما', 'بنما', Region.americas),
  // أوقيانوسيا
  Country('AU', 'أستراليا', 'كانبرا', Region.oceania),
  Country('NZ', 'نيوزيلندا', 'ويلينغتون', Region.oceania),
  Country('FJ', 'فيجي', 'سوفا', Region.oceania),
  Country('PG', 'بابوا غينيا الجديدة', 'بورت مورسبي', Region.oceania),
  Country('WS', 'ساموا', 'أبيا', Region.oceania),
  Country('TO', 'تونغا', 'نوكوالوفا', Region.oceania),
];
