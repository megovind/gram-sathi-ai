class AppStrings {
  AppStrings._();

  // App
  static const appName = 'GramSathi';
  static const tagline = 'आपका स्वास्थ्य सहायक';

  // Onboarding
  static const selectLanguage = 'अपनी भाषा चुनें\nSelect your language';
  static const continueText = 'आगे बढ़ें / Continue';
  static const welcomeTitle = 'नमस्ते! 🙏';
  static const welcomeSubtitle = 'मैं GramSathi हूँ – आपका AI सहायक\nI am GramSathi – your AI assistant';
  static const getStarted = 'शुरू करें / Get Started';

  // Home
  static const howCanIHelp = 'आज मैं आपकी कैसे मदद करूँ?';
  static const healthCard = '🏥 स्वास्थ्य सलाह\nHealth Advice';
  static const healthAdviceLabel = 'Health Advice';
  static const orderFromShopLabel = 'Order from Shop';
  static const commerceCard = '🛒 दुकान से मँगाएँ\nOrder from Shop';
  static const recentChats = 'हाल की बातें';

  // Chat / Voice
  static const tapToSpeak = 'बोलने के लिए दबाएँ';
  static const listening = 'सुन रहा हूँ...';
  static const processing = 'सोच रहा हूँ...';
  static const typeMessage = 'यहाँ लिखें...';
  static const send = 'भेजें';
  static const playAudio = 'सुनें';

  // Health
  static const healthTitle = 'स्वास्थ्य सलाह';
  static const describeSymptomsHint = 'अपने लक्षण बताएँ... (जैसे: बुखार, सिरदर्द)';
  static const nearbyClinics = 'नजदीकी क्लीनिक / फार्मेसी';
  static const getDoctorSummary = 'डॉक्टर सारांश बनाएँ';
  static const emergencyBanner = '⚠️ यह गंभीर स्थिति है! तुरंत 108 पर कॉल करें।';

  // Commerce
  static const commerceTitle = 'स्थानीय दुकानें';
  static const nearbyShops = 'नजदीकी दुकानें';
  static const enterPincode = 'अपना पिनकोड डालें';
  static const orderPlaced = 'ऑर्डर हो गया! 🎉';
  static const totalAmount = 'कुल राशि';

  // Shop Owner
  static const shopDashboard = 'दुकान डैशबोर्ड';
  static const newOrders = 'नए ऑर्डर';
  static const inventory = 'सामान की सूची';
  static const todayRevenue = 'आज की कमाई';
  static const addItem = 'सामान जोड़ें';

  // Errors
  static const micPermissionDenied = 'माइक्रोफ़ोन की अनुमति दें';
  static const networkError = 'इंटरनेट की समस्या है। दोबारा कोशिश करें।';
  static const aiErrorPrefix = '⚠️ ';
  static const networkErrorRetry = 'नेटवर्क की समस्या है। बाद में कोशिश करें।';
  static const genericError = 'कुछ गड़बड़ हुई। दोबारा कोशिश करें।';
  static const pincodeError = '6 अंकों का पिनकोड डालें';
  static const phone10DigitsError = '10 अंकों का नंबर डालें';
  static const nameAndPriceRequired = 'नाम और कीमत जरूरी है';
  static const shopInfoNotFound = 'दुकान की जानकारी नहीं मिली';

  // Buttons / Actions
  static const searchButton = 'खोजें';
  static const goBack = 'वापस जाएँ';
  static const retryButton = 'दोबारा कोशिश करें';
  static const goHome = 'घर जाएँ';
  static const addButton = 'जोड़ें';
  static const notAvailable = 'उपलब्ध नहीं';
  static const addToListButton = 'सूची में जोड़ें';
  static const skipButton = 'Skip';
  static const closeButton = 'Close';

  // Home
  static const settingsTooltip = 'Settings';
  static const settingsComingSoon = 'Settings — coming soon';
  static const changeLanguage = 'Change Language';
  static const logoutButton = 'Sign Out';
  static const logoutConfirmTitle = 'Sign Out?';
  static const logoutConfirmMessage = 'Are you sure you want to sign out?';
  static const cancelButton = 'Cancel';
  static const voiceAsk = 'आवाज़ से पूछें';
  static const voiceAskSubtitle = 'Tap to ask by voice';
  static const quickServices = 'त्वरित सेवाएँ';
  static const nearbyClinicLink = 'नजदीकी क्लीनिक';
  static const nearbyClinicSublabel = 'Nearby Clinics';
  static const myOrdersLink = 'मेरे ऑर्डर';
  static const myOrdersSublabel = 'My Orders';
  static const myShopLink = 'मेरी दुकान';
  static const myShopSublabel = 'My Shop Dashboard';

  // Health — extended
  static const nearbyClinicTooltip = 'Nearby Clinics';
  static const doctorSummaryTitle = 'Doctor Summary';
  static const describeSymptoms = 'स्वास्थ्य या नजदीकी क्लीनिक/दुकान पूछें';
  static const describeSymptomsSubtitle = 'लक्षण बताएँ या बोलें/लिखें: नजदीकी क्लीनिक या दुकानें और पिनकोड';
  static const thinkingIndicator = 'सोच रहा हूँ...';
  static const fallbackSymptomText = 'symptoms';
  static const List<String> healthSuggestions = [
    'मुझे बुखार है',
    'सिरदर्द हो रहा है',
    'नजदीकी क्लीनिक 110001',
    'नजदीकी दुकानें 110001',
  ];

  // Nearby
  static const noFacilitiesFound = 'इस पिनकोड में कोई सेवा नहीं मिली';

  // Commerce — extended
  static const orderFromShopTitle = 'दुकान से ऑर्डर करें';
  static const noItemsInShop = 'इस दुकान में अभी कोई सामान नहीं है';
  static const noShopsFound = 'इस क्षेत्र में कोई दुकान नहीं मिली';
  static const nearbyShopsWillShow = 'नजदीकी दुकानें दिखेंगी';

  // Shop Owner — extended
  static const todayOrders = 'आज के ऑर्डर';
  static const totalOrders = 'कुल ऑर्डर';
  static const pendingOrders = 'बाकी ऑर्डर';
  static const noOrders = 'अभी कोई ऑर्डर नहीं है';
  static const shopNotRegistered = 'आपकी दुकान रजिस्टर नहीं है';
  static const registerShopPrompt =
      'अपनी दुकान रजिस्टर करें और GramSathi पर बेचना शुरू करें';
  static const registerShopButton = 'दुकान रजिस्टर करें';

  // Inventory
  static const itemNameHint = 'Item name (English)';
  static const itemNameHindiHint = 'नाम (हिंदी)';
  static const priceHint = 'कीमत (₹)';
  static const unitHint = 'यूनिट (kg, piece...)';
  static const stockHint = 'स्टॉक';
  static const addItemsAbove = 'ऊपर सामान जोड़ें और सेव करें';
  static const inventorySaved = 'इन्वेंटरी सेव हो गई! ✓';

  // Onboarding — Phone input
  static const enterPhoneTitle = 'अपना नंबर डालें';
  static const enterPhoneSubtitle = 'Enter your mobile number to get started';
  static const mobileNumberLabel = 'मोबाइल नंबर';
  static const phoneHint = '9876543210';
  static const nameOptionalLabel = 'आपका नाम (वैकल्पिक)';
  static const nameHint = 'जैसे: Ramesh Kumar';
  static const privacyNotice =
      'आपका नंबर सुरक्षित है। कभी शेयर नहीं किया जाएगा।\nYour number is private and secure.';

  // Welcome screen feature tiles
  static const featureHealthTitle = 'स्वास्थ्य सलाह';
  static const featureHealthSubtitle = 'लक्षण बताएँ, घरेलू उपाय पाएँ';
  static const featureOrderTitle = 'दुकान से मँगाएँ';
  static const featureOrderSubtitle = 'नजदीकी दुकान से सामान ऑर्डर करें';
  static const featureVoiceTitle = 'आवाज़ से बात करें';
  static const featureVoiceSubtitle = 'हिंदी में बोलें, तुरंत जवाब पाएँ';

  // Audio
  static const pauseAudio = 'रुकें';

  // ── Localized strings (UI changes with selected language) ─────────────────
  /// UI is localized for Hindi and English. Other languages use English UI.
  static LocalizedStrings forLanguage(String code) {
    switch (code) {
      case 'hi':
        return _localizedHi;
      case 'en':
      case 'mr':
      case 'ta':
      case 'te':
      case 'kn':
      case 'bn':
      case 'gu':
      default:
        return _localizedEn;
    }
  }

  static final _localizedHi = LocalizedStrings(
    appName: 'GramSathi',
    tagline: 'आपका स्वास्थ्य सहायक',
    selectLanguage: 'अपनी भाषा चुनें',
    continueText: 'आगे बढ़ें',
    welcomeTitle: 'नमस्ते! 🙏',
    welcomeSubtitle: 'मैं GramSathi हूँ – आपका AI सहायक',
    getStarted: 'शुरू करें',
    howCanIHelp: 'आज मैं आपकी कैसे मदद करूँ?',
    healthCard: 'स्वास्थ्य सलाह',
    healthAdviceLabel: 'स्वास्थ्य सलाह',
    commerceCard: 'दुकान से मँगाएँ',
    orderFromShopLabel: 'दुकान से ऑर्डर',
    quickServices: 'त्वरित सेवाएँ',
    nearbyClinicLink: 'नजदीकी क्लीनिक',
    nearbyClinicSublabel: 'नजदीकी क्लीनिक',
    myOrdersLink: 'मेरे ऑर्डर',
    myOrdersSublabel: 'मेरे ऑर्डर',
    myShopLink: 'मेरी दुकान',
    myShopSublabel: 'मेरी दुकान',
    settingsTooltip: 'सेटिंग्स',
    voiceAsk: 'आवाज़ से पूछें',
    voiceAskSubtitle: 'दबाकर आवाज़ से पूछें',
    healthTitle: 'स्वास्थ्य सलाह',
    describeSymptoms: 'स्वास्थ्य या नजदीकी क्लीनिक/दुकान पूछें',
    describeSymptomsSubtitle: 'लक्षण बताएँ या बोलें/लिखें: नजदीकी क्लीनिक या दुकानें और पिनकोड',
    emergencyBanner: '⚠️ यह गंभीर स्थिति है! तुरंत 108 पर कॉल करें।',
    getDoctorSummary: 'डॉक्टर सारांश बनाएँ',
    doctorSummaryTitle: 'डॉक्टर सारांश',
    thinkingIndicator: 'सोच रहा हूँ...',
    typeMessage: 'यहाँ लिखें...',
    playAudio: 'सुनें',
    pauseAudio: 'रुकें',
    send: 'भेजें',
    nearbyClinics: 'नजदीकी क्लीनिक',
    nearbyShops: 'नजदीकी दुकानें',
    enterPincode: 'अपना पिनकोड डालें',
    searchButton: 'खोजें',
    noShopsFound: 'इस क्षेत्र में कोई दुकान नहीं मिली',
    nearbyShopsWillShow: 'नजदीकी दुकानें दिखेंगी',
    noFacilitiesFound: 'इस पिनकोड में कोई सेवा नहीं मिली',
    orderFromShopTitle: 'दुकान से ऑर्डर करें',
    noItemsInShop: 'इस दुकान में अभी कोई सामान नहीं है',
    goBack: 'वापस जाएँ',
    addButton: 'जोड़ें',
    notAvailable: 'उपलब्ध नहीं',
    totalAmount: 'कुल राशि',
    orderPlaced: 'ऑर्डर हो गया! 🎉',
    goHome: 'घर जाएँ',
    shopDashboard: 'दुकान डैशबोर्ड',
    todayRevenue: 'आज की कमाई',
    todayOrders: 'आज के ऑर्डर',
    totalOrders: 'कुल ऑर्डर',
    pendingOrders: 'बाकी ऑर्डर',
    inventory: 'सामान की सूची',
    newOrders: 'नए ऑर्डर',
    noOrders: 'अभी कोई ऑर्डर नहीं है',
    shopNotRegistered: 'आपकी दुकान रजिस्टर नहीं है',
    registerShopPrompt: 'अपनी दुकान रजिस्टर करें और GramSathi पर बेचना शुरू करें',
    registerShopButton: 'दुकान रजिस्टर करें',
    addItem: 'सामान जोड़ें',
    itemNameHint: 'नाम (अंग्रेज़ी)',
    itemNameHindiHint: 'नाम (हिंदी)',
    priceHint: 'कीमत (₹)',
    unitHint: 'यूनिट (kg, piece...)',
    stockHint: 'स्टॉक',
    addToListButton: 'सूची में जोड़ें',
    addItemsAbove: 'ऊपर सामान जोड़ें और सेव करें',
    enterPhoneTitle: 'अपना नंबर डालें',
    enterPhoneSubtitle: 'शुरू करने के लिए अपना मोबाइल नंबर डालें',
    mobileNumberLabel: 'मोबाइल नंबर',
    phoneHint: '9876543210',
    nameOptionalLabel: 'आपका नाम (वैकल्पिक)',
    nameHint: 'जैसे: Ramesh Kumar',
    privacyNotice: 'आपका नंबर सुरक्षित है। कभी शेयर नहीं किया जाएगा।',
    featureHealthTitle: 'स्वास्थ्य सलाह',
    featureHealthSubtitle: 'लक्षण बताएँ, घरेलू उपाय पाएँ',
    featureOrderTitle: 'दुकान से मँगाएँ',
    featureOrderSubtitle: 'नजदीकी दुकान से सामान ऑर्डर करें',
    featureVoiceTitle: 'आवाज़ से बात करें',
    featureVoiceSubtitle: 'हिंदी में बोलें, तुरंत जवाब पाएँ',
    micPermissionDenied: 'माइक्रोफ़ोन की अनुमति दें',
    networkError: 'इंटरनेट की समस्या है। दोबारा कोशिश करें।',
    networkErrorRetry: 'नेटवर्क की समस्या है। बाद में कोशिश करें।',
    aiErrorPrefix: '⚠️ ',
    pincodeError: '6 अंकों का पिनकोड डालें',
    phone10DigitsError: '10 अंकों का नंबर डालें',
    nameAndPriceRequired: 'नाम और कीमत जरूरी है',
    shopInfoNotFound: 'दुकान की जानकारी नहीं मिली',
    retryButton: 'दोबारा कोशिश करें',
    skipButton: 'छोड़ें',
    closeButton: 'बंद करें',
    inventorySaved: 'इन्वेंटरी सेव हो गई! ✓',
    fallbackSymptomText: 'लक्षण',
    healthSuggestions: ['मुझे बुखार है', 'सिरदर्द हो रहा है', 'नजदीकी क्लीनिक', 'मेरे पास दुकानें कहाँ हैं'],
    placeOrderButton: 'ऑर्डर करें',
    stockLabel: 'स्टॉक',
    itemsAvailable: 'आइटम उपलब्ध',
    itemsCount: 'आइटम',
    saveButton: 'सेव करें',
    changeLanguage: 'भाषा बदलें',
    logoutButton: 'साइन आउट',
    logoutConfirmTitle: 'साइन आउट करें?',
    logoutConfirmMessage: 'क्या आप वाकई साइन आउट करना चाहते हैं?',
    cancelButton: 'रद्द करें',
  );

  static final _localizedEn = LocalizedStrings(
    appName: 'GramSathi',
    tagline: 'Your health assistant',
    selectLanguage: 'Select your language',
    continueText: 'Continue',
    welcomeTitle: 'Hello! 🙏',
    welcomeSubtitle: 'I am GramSathi – your AI assistant',
    getStarted: 'Get Started',
    howCanIHelp: 'How can I help you today?',
    healthCard: 'Health Advice',
    healthAdviceLabel: 'Health Advice',
    commerceCard: 'Order from Shop',
    orderFromShopLabel: 'Order from Shop',
    quickServices: 'Quick services',
    nearbyClinicLink: 'Nearby Clinics',
    nearbyClinicSublabel: 'Nearby Clinics',
    myOrdersLink: 'My Orders',
    myOrdersSublabel: 'My Orders',
    myShopLink: 'My Shop',
    myShopSublabel: 'My Shop Dashboard',
    settingsTooltip: 'Settings',
    voiceAsk: 'Ask by voice',
    voiceAskSubtitle: 'Tap to ask by voice',
    healthTitle: 'Health Advice',
    describeSymptoms: 'Ask about health or nearby clinics/shops',
    describeSymptomsSubtitle: 'Describe symptoms or say/write: nearby clinic or shops and pincode',
    emergencyBanner: '⚠️ This is serious! Call 108 immediately.',
    getDoctorSummary: 'Get Doctor Summary',
    doctorSummaryTitle: 'Doctor Summary',
    thinkingIndicator: 'Thinking...',
    typeMessage: 'Type here...',
    playAudio: 'Play',
    pauseAudio: 'Pause',
    send: 'Send',
    nearbyClinics: 'Nearby Clinics',
    nearbyShops: 'Nearby Shops',
    enterPincode: 'Enter your pincode',
    searchButton: 'Search',
    noShopsFound: 'No shops found in this area',
    nearbyShopsWillShow: 'Nearby shops will appear here',
    noFacilitiesFound: 'No facilities found for this pincode',
    orderFromShopTitle: 'Order from Shop',
    noItemsInShop: 'No items in this shop yet',
    goBack: 'Go Back',
    addButton: 'Add',
    notAvailable: 'Not available',
    totalAmount: 'Total',
    orderPlaced: 'Order placed! 🎉',
    goHome: 'Go Home',
    shopDashboard: 'Shop Dashboard',
    todayRevenue: "Today's revenue",
    todayOrders: "Today's orders",
    totalOrders: 'Total orders',
    pendingOrders: 'Pending orders',
    inventory: 'Inventory',
    newOrders: 'New orders',
    noOrders: 'No orders yet',
    shopNotRegistered: 'Your shop is not registered',
    registerShopPrompt: 'Register your shop and start selling on GramSathi',
    registerShopButton: 'Register Shop',
    addItem: 'Add item',
    itemNameHint: 'Item name (English)',
    itemNameHindiHint: 'Name (Hindi)',
    priceHint: 'Price (₹)',
    unitHint: 'Unit (kg, piece...)',
    stockHint: 'Stock',
    addToListButton: 'Add to list',
    addItemsAbove: 'Add items above and save',
    enterPhoneTitle: 'Enter your number',
    enterPhoneSubtitle: 'Enter your mobile number to get started',
    mobileNumberLabel: 'Mobile number',
    phoneHint: '9876543210',
    nameOptionalLabel: 'Your name (optional)',
    nameHint: 'e.g. Ramesh Kumar',
    privacyNotice: 'Your number is private and secure.',
    featureHealthTitle: 'Health Advice',
    featureHealthSubtitle: 'Describe symptoms, get home remedies',
    featureOrderTitle: 'Order from Shop',
    featureOrderSubtitle: 'Order from nearby shop',
    featureVoiceTitle: 'Talk by voice',
    featureVoiceSubtitle: 'Speak in your language, get instant answers',
    micPermissionDenied: 'Allow microphone access',
    networkError: 'Network error. Please try again.',
    networkErrorRetry: 'Network issue. Try again later.',
    aiErrorPrefix: '⚠️ ',
    pincodeError: 'Enter 6-digit pincode',
    phone10DigitsError: 'Enter 10-digit number',
    nameAndPriceRequired: 'Name and price required',
    shopInfoNotFound: 'Shop info not found',
    retryButton: 'Retry',
    skipButton: 'Skip',
    closeButton: 'Close',
    inventorySaved: 'Inventory saved! ✓',
    fallbackSymptomText: 'symptoms',
    healthSuggestions: ['I have fever', 'Headache', 'Nearby clinic', 'Where are shops near me'],
    placeOrderButton: 'Place order',
    stockLabel: 'Stock',
    itemsAvailable: 'items available',
    itemsCount: 'items',
    saveButton: 'Save',
    changeLanguage: 'Change Language',
    logoutButton: 'Sign Out',
    logoutConfirmTitle: 'Sign Out?',
    logoutConfirmMessage: 'Are you sure you want to sign out?',
    cancelButton: 'Cancel',
  );
}

/// Strings that change with app language. Use with [AppStrings.forLanguage].
class LocalizedStrings {
  const LocalizedStrings({
    required this.appName,
    required this.tagline,
    required this.selectLanguage,
    required this.continueText,
    required this.welcomeTitle,
    required this.welcomeSubtitle,
    required this.getStarted,
    required this.howCanIHelp,
    required this.healthCard,
    required this.healthAdviceLabel,
    required this.commerceCard,
    required this.orderFromShopLabel,
    required this.quickServices,
    required this.nearbyClinicLink,
    required this.nearbyClinicSublabel,
    required this.myOrdersLink,
    required this.myOrdersSublabel,
    required this.myShopLink,
    required this.myShopSublabel,
    required this.settingsTooltip,
    required this.voiceAsk,
    required this.voiceAskSubtitle,
    required this.healthTitle,
    required this.describeSymptoms,
    required this.describeSymptomsSubtitle,
    required this.emergencyBanner,
    required this.getDoctorSummary,
    required this.doctorSummaryTitle,
    required this.thinkingIndicator,
    required this.typeMessage,
    required this.playAudio,
    required this.pauseAudio,
    required this.send,
    required this.nearbyClinics,
    required this.nearbyShops,
    required this.enterPincode,
    required this.searchButton,
    required this.noShopsFound,
    required this.nearbyShopsWillShow,
    required this.noFacilitiesFound,
    required this.orderFromShopTitle,
    required this.noItemsInShop,
    required this.goBack,
    required this.addButton,
    required this.notAvailable,
    required this.totalAmount,
    required this.orderPlaced,
    required this.goHome,
    required this.shopDashboard,
    required this.todayRevenue,
    required this.todayOrders,
    required this.totalOrders,
    required this.pendingOrders,
    required this.inventory,
    required this.newOrders,
    required this.noOrders,
    required this.shopNotRegistered,
    required this.registerShopPrompt,
    required this.registerShopButton,
    required this.addItem,
    required this.itemNameHint,
    required this.itemNameHindiHint,
    required this.priceHint,
    required this.unitHint,
    required this.stockHint,
    required this.addToListButton,
    required this.addItemsAbove,
    required this.enterPhoneTitle,
    required this.enterPhoneSubtitle,
    required this.mobileNumberLabel,
    required this.phoneHint,
    required this.nameOptionalLabel,
    required this.nameHint,
    required this.privacyNotice,
    required this.featureHealthTitle,
    required this.featureHealthSubtitle,
    required this.featureOrderTitle,
    required this.featureOrderSubtitle,
    required this.featureVoiceTitle,
    required this.featureVoiceSubtitle,
    required this.micPermissionDenied,
    required this.networkError,
    required this.networkErrorRetry,
    required this.aiErrorPrefix,
    required this.pincodeError,
    required this.phone10DigitsError,
    required this.nameAndPriceRequired,
    required this.shopInfoNotFound,
    required this.retryButton,
    required this.skipButton,
    required this.closeButton,
    required this.inventorySaved,
    required this.fallbackSymptomText,
    required this.healthSuggestions,
    required this.placeOrderButton,
    required this.stockLabel,
    required this.itemsAvailable,
    required this.itemsCount,
    required this.saveButton,
    required this.changeLanguage,
    required this.logoutButton,
    required this.logoutConfirmTitle,
    required this.logoutConfirmMessage,
    required this.cancelButton,
  });
  final String appName;
  final String tagline;
  final String selectLanguage;
  final String continueText;
  final String welcomeTitle;
  final String welcomeSubtitle;
  final String getStarted;
  final String howCanIHelp;
  final String healthCard;
  final String healthAdviceLabel;
  final String commerceCard;
  final String orderFromShopLabel;
  final String quickServices;
  final String nearbyClinicLink;
  final String nearbyClinicSublabel;
  final String myOrdersLink;
  final String myOrdersSublabel;
  final String myShopLink;
  final String myShopSublabel;
  final String settingsTooltip;
  final String voiceAsk;
  final String voiceAskSubtitle;
  final String healthTitle;
  final String describeSymptoms;
  final String describeSymptomsSubtitle;
  final String emergencyBanner;
  final String getDoctorSummary;
  final String doctorSummaryTitle;
  final String thinkingIndicator;
  final String typeMessage;
  final String playAudio;
  final String pauseAudio;
  final String send;
  final String nearbyClinics;
  final String nearbyShops;
  final String enterPincode;
  final String searchButton;
  final String noShopsFound;
  final String nearbyShopsWillShow;
  final String noFacilitiesFound;
  final String orderFromShopTitle;
  final String noItemsInShop;
  final String goBack;
  final String addButton;
  final String notAvailable;
  final String totalAmount;
  final String orderPlaced;
  final String goHome;
  final String shopDashboard;
  final String todayRevenue;
  final String todayOrders;
  final String totalOrders;
  final String pendingOrders;
  final String inventory;
  final String newOrders;
  final String noOrders;
  final String shopNotRegistered;
  final String registerShopPrompt;
  final String registerShopButton;
  final String addItem;
  final String itemNameHint;
  final String itemNameHindiHint;
  final String priceHint;
  final String unitHint;
  final String stockHint;
  final String addToListButton;
  final String addItemsAbove;
  final String enterPhoneTitle;
  final String enterPhoneSubtitle;
  final String mobileNumberLabel;
  final String phoneHint;
  final String nameOptionalLabel;
  final String nameHint;
  final String privacyNotice;
  final String featureHealthTitle;
  final String featureHealthSubtitle;
  final String featureOrderTitle;
  final String featureOrderSubtitle;
  final String featureVoiceTitle;
  final String featureVoiceSubtitle;
  final String micPermissionDenied;
  final String networkError;
  final String networkErrorRetry;
  final String aiErrorPrefix;
  final String pincodeError;
  final String phone10DigitsError;
  final String nameAndPriceRequired;
  final String shopInfoNotFound;
  final String retryButton;
  final String skipButton;
  final String closeButton;
  final String inventorySaved;
  final String fallbackSymptomText;
  final List<String> healthSuggestions;
  final String placeOrderButton;
  final String stockLabel;
  final String itemsAvailable;
  final String itemsCount;
  final String saveButton;
  final String changeLanguage;
  final String logoutButton;
  final String logoutConfirmTitle;
  final String logoutConfirmMessage;
  final String cancelButton;
}
