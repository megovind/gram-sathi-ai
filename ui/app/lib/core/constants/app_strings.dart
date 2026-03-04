class AppStrings {
  AppStrings._();

  // App
  static const appName = 'GramSathi';
  static const tagline = 'आपका AI सहायक';

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

  // Nearby / filter chips
  static const filterAll = 'All';
  static const filterClinics = 'Clinics';
  static const filterPharmacy = 'Pharmacy';
  static const facilitiesFound = 'places found';
  static const phoneCopied = 'Phone number copied';
  static const shopsFoundSuffix = 'shops found';
  static const moreItemsSuffix = 'more';

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
  static LocalizedStrings forLanguage(String code) {
    switch (code) {
      case 'hi':
        return _localizedHi;
      case 'mr':
        return _localizedMr;
      case 'ta':
        return _localizedTa;
      case 'te':
        return _localizedTe;
      case 'kn':
        return _localizedKn;
      case 'bn':
        return _localizedBn;
      case 'gu':
        return _localizedGu;
      case 'en':
      default:
        return _localizedEn;
    }
  }

  static final _localizedHi = LocalizedStrings(
    appName: 'GramSathi',
    tagline: 'आपका AI सहायक',
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
    howCanIHelpSub: 'आवाज़ या लिखकर पूछें',
    searchingShops: 'दुकानें खोज रहे हैं...',
    noShopsTryDiff: 'दूसरा पिनकोड आज़माएँ',
    summary: 'सारांश',
    currentlyLabel: 'अभी:',
    welcomeBack: 'वापसी पर स्वागत है',
    languageLabel: 'भाषा',
    shopsFoundText: (n) => '$n दुकान${n == 1 ? '' : 'ें'} मिली',
  );

  static final _localizedEn = LocalizedStrings(
    appName: 'GramSathi',
    tagline: 'Your AI assistant',
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
    howCanIHelpSub: 'Ask in your language — voice or text',
    searchingShops: 'Searching shops...',
    noShopsTryDiff: 'Try a different pincode',
    summary: 'Summary',
    currentlyLabel: 'Currently:',
    welcomeBack: 'Welcome back',
    languageLabel: 'Language',
    shopsFoundText: (n) => '$n shop${n == 1 ? '' : 's'} found',
  );

  // ── Marathi ──────────────────────────────────────────────────────────────
  static final _localizedMr = LocalizedStrings(
    appName: 'GramSathi',
    tagline: 'तुमचा AI सहाय्यक',
    selectLanguage: 'तुमची भाषा निवडा',
    continueText: 'पुढे जा',
    welcomeTitle: 'नमस्ते! 🙏',
    welcomeSubtitle: 'मी GramSathi आहे – तुमचा AI सहाय्यक',
    getStarted: 'सुरू करा',
    howCanIHelp: 'आज मी तुमची कशी मदत करू?',
    howCanIHelpSub: 'आवाज किंवा लिखाणाने विचारा',
    healthCard: 'आरोग्य सल्ला',
    healthAdviceLabel: 'आरोग्य सल्ला',
    commerceCard: 'दुकानातून मागवा',
    orderFromShopLabel: 'दुकानातून ऑर्डर',
    quickServices: 'जलद सेवा',
    nearbyClinicLink: 'जवळचे क्लिनिक',
    nearbyClinicSublabel: 'जवळचे क्लिनिक',
    myOrdersLink: 'माझे ऑर्डर',
    myOrdersSublabel: 'माझे ऑर्डर',
    myShopLink: 'माझे दुकान',
    myShopSublabel: 'माझे दुकान',
    settingsTooltip: 'सेटिंग्स',
    voiceAsk: 'आवाजाने विचारा',
    voiceAskSubtitle: 'दाबून आवाजाने विचारा',
    healthTitle: 'आरोग्य सल्ला',
    describeSymptoms: 'आरोग्य किंवा जवळच्या क्लिनिक/दुकानाबद्दल विचारा',
    describeSymptomsSubtitle: 'लक्षणे सांगा किंवा बोला/लिहा: जवळचे क्लिनिक किंवा दुकाने आणि पिनकोड',
    emergencyBanner: '⚠️ ही गंभीर स्थिती आहे! लगेच 108 वर कॉल करा.',
    getDoctorSummary: 'डॉक्टर सारांश मिळवा',
    doctorSummaryTitle: 'डॉक्टर सारांश',
    thinkingIndicator: 'विचार करतोय...',
    typeMessage: 'इथे लिहा...',
    playAudio: 'ऐका',
    pauseAudio: 'थांबा',
    send: 'पाठवा',
    nearbyClinics: 'जवळचे क्लिनिक',
    nearbyShops: 'जवळच्या दुकाने',
    enterPincode: 'पिनकोड टाका',
    searchButton: 'शोधा',
    searchingShops: 'दुकाने शोधत आहे...',
    noShopsFound: 'कोणतेही दुकान सापडले नाही',
    noShopsTryDiff: 'वेगळा पिनकोड वापरून पाहा',
    shopsFoundText: (n) => '$n दुकान${n == 1 ? '' : 'े'} सापडली',
    nearbyShopsWillShow: 'जवळच्या दुकाने दिसतील',
    noFacilitiesFound: 'या पिनकोडमध्ये कोणतीही सेवा सापडली नाही',
    orderFromShopTitle: 'दुकानातून ऑर्डर करा',
    noItemsInShop: 'या दुकानात अद्याप कोणताही माल नाही',
    goBack: 'मागे जा',
    addButton: 'जोडा',
    notAvailable: 'उपलब्ध नाही',
    totalAmount: 'एकूण रक्कम',
    orderPlaced: 'ऑर्डर झाला! 🎉',
    goHome: 'घरी जा',
    shopDashboard: 'दुकान डॅशबोर्ड',
    todayRevenue: 'आजचे उत्पन्न',
    todayOrders: 'आजचे ऑर्डर',
    totalOrders: 'एकूण ऑर्डर',
    pendingOrders: 'बाकी ऑर्डर',
    inventory: 'माल यादी',
    newOrders: 'नवे ऑर्डर',
    noOrders: 'अजून कोणतेही ऑर्डर नाही',
    shopNotRegistered: 'तुमचे दुकान नोंदणीकृत नाही',
    registerShopPrompt: 'तुमचे दुकान नोंदवा आणि GramSathi वर विकणे सुरू करा',
    registerShopButton: 'दुकान नोंदवा',
    addItem: 'माल जोडा',
    itemNameHint: 'नाव (इंग्रजी)',
    itemNameHindiHint: 'नाव (हिंदी)',
    priceHint: 'किंमत (₹)',
    unitHint: 'एकक (kg, piece...)',
    stockHint: 'स्टॉक',
    addToListButton: 'यादीत जोडा',
    addItemsAbove: 'वर माल जोडा आणि सेव्ह करा',
    enterPhoneTitle: 'तुमचा नंबर द्या',
    enterPhoneSubtitle: 'सुरू करण्यासाठी तुमचा मोबाइल नंबर द्या',
    mobileNumberLabel: 'मोबाइल नंबर',
    phoneHint: '9876543210',
    nameOptionalLabel: 'तुमचे नाव (पर्यायी)',
    nameHint: 'उदा. Ramesh Kumar',
    privacyNotice: 'तुमचा नंबर सुरक्षित आहे. कधीही शेअर केला जाणार नाही.',
    featureHealthTitle: 'आरोग्य सल्ला',
    featureHealthSubtitle: 'लक्षणे सांगा, घरगुती उपाय मिळवा',
    featureOrderTitle: 'दुकानातून मागवा',
    featureOrderSubtitle: 'जवळच्या दुकानातून सामान ऑर्डर करा',
    featureVoiceTitle: 'आवाजाने बोला',
    featureVoiceSubtitle: 'मराठीत बोला, लगेच उत्तर मिळवा',
    micPermissionDenied: 'मायक्रोफोनला परवानगी द्या',
    networkError: 'इंटरनेट समस्या आहे. पुन्हा प्रयत्न करा.',
    networkErrorRetry: 'नेटवर्क समस्या आहे. नंतर प्रयत्न करा.',
    aiErrorPrefix: '⚠️ ',
    pincodeError: '6 अंकी पिनकोड टाका',
    phone10DigitsError: '10 अंकी नंबर टाका',
    nameAndPriceRequired: 'नाव आणि किंमत आवश्यक आहे',
    shopInfoNotFound: 'दुकानाची माहिती सापडली नाही',
    retryButton: 'पुन्हा प्रयत्न करा',
    skipButton: 'वगळा',
    closeButton: 'बंद करा',
    inventorySaved: 'माल यादी सेव्ह झाली! ✓',
    fallbackSymptomText: 'लक्षणे',
    healthSuggestions: ['मला ताप आहे', 'डोकेदुखी होतेय', 'जवळचे क्लिनिक', 'जवळची दुकाने कुठे आहेत'],
    placeOrderButton: 'ऑर्डर करा',
    stockLabel: 'स्टॉक',
    itemsAvailable: 'माल उपलब्ध',
    itemsCount: 'माल',
    saveButton: 'सेव्ह करा',
    changeLanguage: 'भाषा बदला',
    logoutButton: 'साइन आउट',
    logoutConfirmTitle: 'साइन आउट करायचे?',
    logoutConfirmMessage: 'तुम्हाला खरोखर साइन आउट करायचे आहे का?',
    cancelButton: 'रद्द करा',
    summary: 'सारांश',
    currentlyLabel: 'सध्या:',
    welcomeBack: 'परत स्वागत',
    languageLabel: 'भाषा',
  );

  // ── Tamil ────────────────────────────────────────────────────────────────
  static final _localizedTa = LocalizedStrings(
    appName: 'GramSathi',
    tagline: 'உங்கள் AI உதவியாளர்',
    selectLanguage: 'உங்கள் மொழியை தேர்வு செய்யுங்கள்',
    continueText: 'தொடரவும்',
    welcomeTitle: 'வணக்கம்! 🙏',
    welcomeSubtitle: 'நான் GramSathi – உங்கள் AI உதவியாளர்',
    getStarted: 'தொடங்குங்கள்',
    howCanIHelp: 'இன்று நான் உங்களுக்கு எப்படி உதவலாம்?',
    howCanIHelpSub: 'குரல் அல்லது எழுத்தில் கேளுங்கள்',
    healthCard: 'சுகாதார ஆலோசனை',
    healthAdviceLabel: 'சுகாதார ஆலோசனை',
    commerceCard: 'கடையிலிருந்து வாங்கவும்',
    orderFromShopLabel: 'கடையிலிருந்து ஆர்டர்',
    quickServices: 'விரைவு அணுகல்',
    nearbyClinicLink: 'அருகில் உள்ள கிளினிக்',
    nearbyClinicSublabel: 'அருகில் உள்ள கிளினிக்',
    myOrdersLink: 'என் ஆர்டர்கள்',
    myOrdersSublabel: 'என் ஆர்டர்கள்',
    myShopLink: 'என் கடை',
    myShopSublabel: 'என் கடை',
    settingsTooltip: 'அமைப்புகள்',
    voiceAsk: 'குரலில் கேளுங்கள்',
    voiceAskSubtitle: 'தட்டி குரலில் கேளுங்கள்',
    healthTitle: 'சுகாதார ஆலோசனை',
    describeSymptoms: 'சுகாதாரம் அல்லது அருகில் உள்ள கிளினிக்/கடைகளைப் பற்றி கேளுங்கள்',
    describeSymptomsSubtitle: 'அறிகுறிகளை விவரிக்கவும் அல்லது சொல்லுங்கள்: அருகில் உள்ள கிளினிக் அல்லது கடைகள் மற்றும் பின்கோட்',
    emergencyBanner: '⚠️ இது தீவிரமான நிலை! உடனடியாக 108 ஐ அழைக்கவும்.',
    getDoctorSummary: 'மருத்துவர் சுருக்கம் பெறவும்',
    doctorSummaryTitle: 'மருத்துவர் சுருக்கம்',
    thinkingIndicator: 'யோசிக்கிறேன்...',
    typeMessage: 'இங்கே எழுதுங்கள்...',
    playAudio: 'கேளுங்கள்',
    pauseAudio: 'இடைநிறுத்தவும்',
    send: 'அனுப்பவும்',
    nearbyClinics: 'அருகில் உள்ள கிளினிக்',
    nearbyShops: 'அருகில் உள்ள கடைகள்',
    enterPincode: 'பின்கோடை உள்ளிடவும்',
    searchButton: 'தேடவும்',
    searchingShops: 'கடைகளை தேடுகிறோம்...',
    noShopsFound: 'கடைகள் எதுவும் கிடைக்கவில்லை',
    noShopsTryDiff: 'வேறு பின்கோடை முயற்சிக்கவும்',
    shopsFoundText: (n) => '$n கடை${n == 1 ? '' : 'கள்'} கிடைத்தது',
    nearbyShopsWillShow: 'அருகில் உள்ள கடைகள் இங்கே தெரியும்',
    noFacilitiesFound: 'இந்த பின்கோட்டில் சேவைகள் எதுவும் கிடைக்கவில்லை',
    orderFromShopTitle: 'கடையிலிருந்து ஆர்டர் செய்யுங்கள்',
    noItemsInShop: 'இந்த கடையில் இன்னும் பொருட்கள் இல்லை',
    goBack: 'திரும்பு',
    addButton: 'சேர்க்கவும்',
    notAvailable: 'கிடைக்கவில்லை',
    totalAmount: 'மொத்த தொகை',
    orderPlaced: 'ஆர்டர் வைக்கப்பட்டது! 🎉',
    goHome: 'வீட்டிற்கு செல்லுங்கள்',
    shopDashboard: 'கடை டாஷ்போர்டு',
    todayRevenue: 'இன்றைய வருவாய்',
    todayOrders: 'இன்றைய ஆர்டர்கள்',
    totalOrders: 'மொத்த ஆர்டர்கள்',
    pendingOrders: 'நிலுவையில் உள்ள ஆர்டர்கள்',
    inventory: 'சரக்கு',
    newOrders: 'புதிய ஆர்டர்கள்',
    noOrders: 'இன்னும் ஆர்டர்கள் இல்லை',
    shopNotRegistered: 'உங்கள் கடை பதிவு செய்யப்படவில்லை',
    registerShopPrompt: 'உங்கள் கடையை பதிவு செய்து GramSathi இல் விற்கத் தொடங்குங்கள்',
    registerShopButton: 'கடையை பதிவு செய்யுங்கள்',
    addItem: 'பொருள் சேர்க்கவும்',
    itemNameHint: 'பொருளின் பெயர் (ஆங்கிலம்)',
    itemNameHindiHint: 'பெயர் (ஹிந்தி)',
    priceHint: 'விலை (₹)',
    unitHint: 'அலகு (kg, piece...)',
    stockHint: 'இருப்பு',
    addToListButton: 'பட்டியலில் சேர்க்கவும்',
    addItemsAbove: 'மேலே பொருட்கள் சேர்த்து சேமிக்கவும்',
    enterPhoneTitle: 'உங்கள் எண்ணை உள்ளிடவும்',
    enterPhoneSubtitle: 'தொடங்க உங்கள் மொபைல் எண்ணை உள்ளிடவும்',
    mobileNumberLabel: 'மொபைல் எண்',
    phoneHint: '9876543210',
    nameOptionalLabel: 'உங்கள் பெயர் (விருப்பமானது)',
    nameHint: 'எ.கா. Ramesh Kumar',
    privacyNotice: 'உங்கள் எண் பாதுகாப்பானது. பகிரப்படாது.',
    featureHealthTitle: 'சுகாதார ஆலோசனை',
    featureHealthSubtitle: 'அறிகுறிகளை விவரிக்கவும், வீட்டு வைத்தியம் பெறவும்',
    featureOrderTitle: 'கடையிலிருந்து வாங்கவும்',
    featureOrderSubtitle: 'அருகில் உள்ள கடையிலிருந்து ஆர்டர் செய்யுங்கள்',
    featureVoiceTitle: 'குரலில் பேசுங்கள்',
    featureVoiceSubtitle: 'உங்கள் மொழியில் பேசுங்கள், உடனடி பதில் பெறுங்கள்',
    micPermissionDenied: 'மைக்ரோஃபோன் அணுகலை அனுமதிக்கவும்',
    networkError: 'நெட்வொர்க் பிழை. மீண்டும் முயற்சிக்கவும்.',
    networkErrorRetry: 'நெட்வொர்க் சிக்கல். பின்னர் முயற்சிக்கவும்.',
    aiErrorPrefix: '⚠️ ',
    pincodeError: '6 இலக்க பின்கோட்டை உள்ளிடவும்',
    phone10DigitsError: '10 இலக்க எண்ணை உள்ளிடவும்',
    nameAndPriceRequired: 'பெயர் மற்றும் விலை தேவை',
    shopInfoNotFound: 'கடை தகவல் கிடைக்கவில்லை',
    retryButton: 'மீண்டும் முயற்சிக்கவும்',
    skipButton: 'தவிர்க்கவும்',
    closeButton: 'மூடவும்',
    inventorySaved: 'சரக்கு சேமிக்கப்பட்டது! ✓',
    fallbackSymptomText: 'அறிகுறிகள்',
    healthSuggestions: ['எனக்கு காய்ச்சல் இருக்கிறது', 'தலைவலி', 'அருகில் உள்ள கிளினிக்', 'என் அருகில் கடைகள் எங்கே'],
    placeOrderButton: 'ஆர்டர் செய்யுங்கள்',
    stockLabel: 'இருப்பு',
    itemsAvailable: 'பொருட்கள் கிடைக்கின்றன',
    itemsCount: 'பொருட்கள்',
    saveButton: 'சேமிக்கவும்',
    changeLanguage: 'மொழியை மாற்றவும்',
    logoutButton: 'வெளியேறு',
    logoutConfirmTitle: 'வெளியேற வேண்டுமா?',
    logoutConfirmMessage: 'நீங்கள் வெளியேற விரும்புகிறீர்களா?',
    cancelButton: 'ரத்து செய்யவும்',
    summary: 'சுருக்கம்',
    currentlyLabel: 'தற்போது:',
    welcomeBack: 'மீண்டும் வரவேற்கிறோம்',
    languageLabel: 'மொழி',
  );

  // ── Telugu ───────────────────────────────────────────────────────────────
  static final _localizedTe = LocalizedStrings(
    appName: 'GramSathi',
    tagline: 'మీ AI సహాయకుడు',
    selectLanguage: 'మీ భాషను ఎంచుకోండి',
    continueText: 'కొనసాగించు',
    welcomeTitle: 'నమస్కారం! 🙏',
    welcomeSubtitle: 'నేను GramSathi – మీ AI సహాయకుడు',
    getStarted: 'ప్రారంభించండి',
    howCanIHelp: 'ఈరోజు మీకు ఎలా సహాయపడగలను?',
    howCanIHelpSub: 'వాయిస్ లేదా టెక్స్ట్‌లో అడగండి',
    healthCard: 'ఆరోగ్య సలహా',
    healthAdviceLabel: 'ఆరోగ్య సలహా',
    commerceCard: 'దుకాణం నుండి ఆర్డర్ చేయండి',
    orderFromShopLabel: 'దుకాణం నుండి ఆర్డర్',
    quickServices: 'త్వరిత యాక్సెస్',
    nearbyClinicLink: 'దగ్గర క్లినిక్',
    nearbyClinicSublabel: 'దగ్గర క్లినిక్',
    myOrdersLink: 'నా ఆర్డర్లు',
    myOrdersSublabel: 'నా ఆర్డర్లు',
    myShopLink: 'నా దుకాణం',
    myShopSublabel: 'నా దుకాణం',
    settingsTooltip: 'సెట్టింగులు',
    voiceAsk: 'వాయిస్‌తో అడగండి',
    voiceAskSubtitle: 'నొక్కి వాయిస్‌తో అడగండి',
    healthTitle: 'ఆరోగ్య సహాయకుడు',
    describeSymptoms: 'ఆరోగ్యం లేదా దగ్గర క్లినిక్/దుకాణాల గురించి అడగండి',
    describeSymptomsSubtitle: 'లక్షణాలు చెప్పండి లేదా చెప్పండి/రాయండి: దగ్గర క్లినిక్ లేదా దుకాణాలు మరియు పిన్‌కోడ్',
    emergencyBanner: '⚠️ ఇది తీవ్రమైన పరిస్థితి! వెంటనే 108 కి కాల్ చేయండి.',
    getDoctorSummary: 'డాక్టర్ సారాంశం పొందండి',
    doctorSummaryTitle: 'డాక్టర్ సారాంశం',
    thinkingIndicator: 'ఆలోచిస్తున్నాను...',
    typeMessage: 'ఇక్కడ టైప్ చేయండి...',
    playAudio: 'వినండి',
    pauseAudio: 'ఆపండి',
    send: 'పంపండి',
    nearbyClinics: 'దగ్గర క్లినిక్',
    nearbyShops: 'దగ్గర దుకాణాలు',
    enterPincode: 'పిన్‌కోడ్ నమోదు చేయండి',
    searchButton: 'వెతకండి',
    searchingShops: 'దుకాణాలు వెతుకుతున్నాం...',
    noShopsFound: 'దుకాణాలు కనుగొనబడలేదు',
    noShopsTryDiff: 'వేరే పిన్‌కోడ్ ప్రయత్నించండి',
    shopsFoundText: (n) => '$n దుకాణం${n == 1 ? '' : 'లు'} కనుగొనబడ్డాయి',
    nearbyShopsWillShow: 'దగ్గర దుకాణాలు ఇక్కడ కనిపిస్తాయి',
    noFacilitiesFound: 'ఈ పిన్‌కోడ్‌కి సేవలు కనుగొనబడలేదు',
    orderFromShopTitle: 'దుకాణం నుండి ఆర్డర్ చేయండి',
    noItemsInShop: 'ఈ దుకాణంలో ఇంకా వస్తువులు లేవు',
    goBack: 'వెనక్కి వెళ్ళండి',
    addButton: 'జోడించండి',
    notAvailable: 'అందుబాటులో లేదు',
    totalAmount: 'మొత్తం మొత్తం',
    orderPlaced: 'ఆర్డర్ చేయబడింది! 🎉',
    goHome: 'హోమ్‌కి వెళ్ళండి',
    shopDashboard: 'షాప్ డాష్‌బోర్డ్',
    todayRevenue: 'నేటి ఆదాయం',
    todayOrders: 'నేటి ఆర్డర్లు',
    totalOrders: 'మొత్తం ఆర్డర్లు',
    pendingOrders: 'పెండింగ్ ఆర్డర్లు',
    inventory: 'ఇన్వెంటరీ',
    newOrders: 'కొత్త ఆర్డర్లు',
    noOrders: 'ఇంకా ఆర్డర్లు లేవు',
    shopNotRegistered: 'మీ దుకాణం నమోదు కాలేదు',
    registerShopPrompt: 'మీ దుకాణాన్ని నమోదు చేసి GramSathi లో అమ్మడం ప్రారంభించండి',
    registerShopButton: 'దుకాణం నమోదు చేయండి',
    addItem: 'వస్తువు జోడించండి',
    itemNameHint: 'వస్తువు పేరు (ఆంగ్లం)',
    itemNameHindiHint: 'పేరు (హిందీ)',
    priceHint: 'ధర (₹)',
    unitHint: 'యూనిట్ (kg, piece...)',
    stockHint: 'స్టాక్',
    addToListButton: 'జాబితాకు జోడించండి',
    addItemsAbove: 'పైన వస్తువులు జోడించి సేవ్ చేయండి',
    enterPhoneTitle: 'మీ నంబర్ నమోదు చేయండి',
    enterPhoneSubtitle: 'ప్రారంభించడానికి మీ మొబైల్ నంబర్ నమోదు చేయండి',
    mobileNumberLabel: 'మొబైల్ నంబర్',
    phoneHint: '9876543210',
    nameOptionalLabel: 'మీ పేరు (ఐచ్ఛికం)',
    nameHint: 'ఉదా. Ramesh Kumar',
    privacyNotice: 'మీ నంబర్ సురక్షితం. ఎప్పుడూ షేర్ చేయబడదు.',
    featureHealthTitle: 'ఆరోగ్య సలహా',
    featureHealthSubtitle: 'లక్షణాలు చెప్పండి, గృహ చికిత్సలు పొందండి',
    featureOrderTitle: 'దుకాణం నుండి ఆర్డర్ చేయండి',
    featureOrderSubtitle: 'దగ్గర దుకాణం నుండి వస్తువులు ఆర్డర్ చేయండి',
    featureVoiceTitle: 'వాయిస్‌తో మాట్లాడండి',
    featureVoiceSubtitle: 'మీ భాషలో మాట్లాడండి, తక్షణ సమాధానం పొందండి',
    micPermissionDenied: 'మైక్రోఫోన్ యాక్సెస్ అనుమతించండి',
    networkError: 'నెట్‌వర్క్ లోపం. మళ్ళీ ప్రయత్నించండి.',
    networkErrorRetry: 'నెట్‌వర్క్ సమస్య. తర్వాత ప్రయత్నించండి.',
    aiErrorPrefix: '⚠️ ',
    pincodeError: '6 అంకెల పిన్‌కోడ్ నమోదు చేయండి',
    phone10DigitsError: '10 అంకెల నంబర్ నమోదు చేయండి',
    nameAndPriceRequired: 'పేరు మరియు ధర అవసరం',
    shopInfoNotFound: 'దుకాణం సమాచారం కనుగొనబడలేదు',
    retryButton: 'మళ్ళీ ప్రయత్నించండి',
    skipButton: 'దాటవేయండి',
    closeButton: 'మూసివేయి',
    inventorySaved: 'ఇన్వెంటరీ సేవ్ చేయబడింది! ✓',
    fallbackSymptomText: 'లక్షణాలు',
    healthSuggestions: ['నాకు జ్వరం వచ్చింది', 'తలనొప్పి', 'దగ్గర క్లినిక్', 'నా దగ్గర దుకాణాలు ఎక్కడ'],
    placeOrderButton: 'ఆర్డర్ చేయండి',
    stockLabel: 'స్టాక్',
    itemsAvailable: 'వస్తువులు అందుబాటులో ఉన్నాయి',
    itemsCount: 'వస్తువులు',
    saveButton: 'సేవ్ చేయండి',
    changeLanguage: 'భాష మార్చండి',
    logoutButton: 'సైన్ అవుట్',
    logoutConfirmTitle: 'సైన్ అవుట్ చేయాలా?',
    logoutConfirmMessage: 'మీరు నిజంగా సైన్ అవుట్ చేయాలనుకుంటున్నారా?',
    cancelButton: 'రద్దు చేయండి',
    summary: 'సారాంశం',
    currentlyLabel: 'ప్రస్తుతం:',
    welcomeBack: 'మళ్ళీ స్వాగతం',
    languageLabel: 'భాష',
  );

  // ── Kannada ──────────────────────────────────────────────────────────────
  static final _localizedKn = LocalizedStrings(
    appName: 'GramSathi',
    tagline: 'ನಿಮ್ಮ AI ಸಹಾಯಕ',
    selectLanguage: 'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆ ಮಾಡಿ',
    continueText: 'ಮುಂದುವರಿಯಿರಿ',
    welcomeTitle: 'ನಮಸ್ಕಾರ! 🙏',
    welcomeSubtitle: 'ನಾನು GramSathi – ನಿಮ್ಮ AI ಸಹಾಯಕ',
    getStarted: 'ಪ್ರಾರಂಭಿಸಿ',
    howCanIHelp: 'ಇಂದು ನಾನು ನಿಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಲಿ?',
    howCanIHelpSub: 'ಧ್ವನಿ ಅಥವಾ ಪಠ್ಯದಲ್ಲಿ ಕೇಳಿ',
    healthCard: 'ಆರೋಗ್ಯ ಸಲಹೆ',
    healthAdviceLabel: 'ಆರೋಗ್ಯ ಸಲಹೆ',
    commerceCard: 'ಅಂಗಡಿಯಿಂದ ಆರ್ಡರ್ ಮಾಡಿ',
    orderFromShopLabel: 'ಅಂಗಡಿಯಿಂದ ಆರ್ಡರ್',
    quickServices: 'ತ್ವರಿತ ಪ್ರವೇಶ',
    nearbyClinicLink: 'ಹತ್ತಿರದ ಕ್ಲಿನಿಕ್',
    nearbyClinicSublabel: 'ಹತ್ತಿರದ ಕ್ಲಿನಿಕ್',
    myOrdersLink: 'ನನ್ನ ಆರ್ಡರ್‌ಗಳು',
    myOrdersSublabel: 'ನನ್ನ ಆರ್ಡರ್‌ಗಳು',
    myShopLink: 'ನನ್ನ ಅಂಗಡಿ',
    myShopSublabel: 'ನನ್ನ ಅಂಗಡಿ',
    settingsTooltip: 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
    voiceAsk: 'ಧ್ವನಿಯಲ್ಲಿ ಕೇಳಿ',
    voiceAskSubtitle: 'ಒತ್ತಿ ಧ್ವನಿಯಲ್ಲಿ ಕೇಳಿ',
    healthTitle: 'ಆರೋಗ್ಯ ಸಹಾಯಕ',
    describeSymptoms: 'ಆರೋಗ್ಯ ಅಥವಾ ಹತ್ತಿರದ ಕ್ಲಿನಿಕ್/ಅಂಗಡಿಗಳ ಬಗ್ಗೆ ಕೇಳಿ',
    describeSymptomsSubtitle: 'ಲಕ್ಷಣಗಳನ್ನು ತಿಳಿಸಿ ಅಥವಾ ಹೇಳಿ/ಬರೆಯಿರಿ: ಹತ್ತಿರದ ಕ್ಲಿನಿಕ್ ಅಥವಾ ಅಂಗಡಿಗಳು ಮತ್ತು ಪಿನ್‌ಕೋಡ್',
    emergencyBanner: '⚠️ ಇದು ತೀವ್ರ ಸ್ಥಿತಿ! ತಕ್ಷಣ 108 ಗೆ ಕರೆ ಮಾಡಿ.',
    getDoctorSummary: 'ವೈದ್ಯರ ಸಾರಾಂಶ ಪಡೆಯಿರಿ',
    doctorSummaryTitle: 'ವೈದ್ಯರ ಸಾರಾಂಶ',
    thinkingIndicator: 'ಯೋಚಿಸುತ್ತಿದ್ದೇನೆ...',
    typeMessage: 'ಇಲ್ಲಿ ಟೈಪ್ ಮಾಡಿ...',
    playAudio: 'ಕೇಳಿ',
    pauseAudio: 'ನಿಲ್ಲಿಸಿ',
    send: 'ಕಳುಹಿಸಿ',
    nearbyClinics: 'ಹತ್ತಿರದ ಕ್ಲಿನಿಕ್',
    nearbyShops: 'ಹತ್ತಿರದ ಅಂಗಡಿಗಳು',
    enterPincode: 'ಪಿನ್‌ಕೋಡ್ ನಮೂದಿಸಿ',
    searchButton: 'ಹುಡುಕಿ',
    searchingShops: 'ಅಂಗಡಿಗಳನ್ನು ಹುಡುಕಲಾಗುತ್ತಿದೆ...',
    noShopsFound: 'ಯಾವ ಅಂಗಡಿಗಳೂ ಕಂಡುಬಂದಿಲ್ಲ',
    noShopsTryDiff: 'ಬೇರೆ ಪಿನ್‌ಕೋಡ್ ಪ್ರಯತ್ನಿಸಿ',
    shopsFoundText: (n) => '$n ಅಂಗಡಿ${n == 1 ? '' : 'ಗಳು'} ಕಂಡುಬಂದಿದೆ',
    nearbyShopsWillShow: 'ಹತ್ತಿರದ ಅಂಗಡಿಗಳು ಇಲ್ಲಿ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತವೆ',
    noFacilitiesFound: 'ಈ ಪಿನ್‌ಕೋಡ್‌ಗೆ ಯಾವ ಸೇವೆಗಳೂ ಕಂಡುಬಂದಿಲ್ಲ',
    orderFromShopTitle: 'ಅಂಗಡಿಯಿಂದ ಆರ್ಡರ್ ಮಾಡಿ',
    noItemsInShop: 'ಈ ಅಂಗಡಿಯಲ್ಲಿ ಇನ್ನೂ ಯಾವ ವಸ್ತುಗಳೂ ಇಲ್ಲ',
    goBack: 'ಹಿಂದೆ ಹೋಗಿ',
    addButton: 'ಸೇರಿಸಿ',
    notAvailable: 'ಲಭ್ಯವಿಲ್ಲ',
    totalAmount: 'ಒಟ್ಟು ಮೊತ್ತ',
    orderPlaced: 'ಆರ್ಡರ್ ಮಾಡಲಾಗಿದೆ! 🎉',
    goHome: 'ಮನೆಗೆ ಹೋಗಿ',
    shopDashboard: 'ಅಂಗಡಿ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್',
    todayRevenue: 'ಇಂದಿನ ಆದಾಯ',
    todayOrders: 'ಇಂದಿನ ಆರ್ಡರ್‌ಗಳು',
    totalOrders: 'ಒಟ್ಟು ಆರ್ಡರ್‌ಗಳು',
    pendingOrders: 'ಬಾಕಿ ಆರ್ಡರ್‌ಗಳು',
    inventory: 'ದಾಸ್ತಾನು',
    newOrders: 'ಹೊಸ ಆರ್ಡರ್‌ಗಳು',
    noOrders: 'ಇನ್ನೂ ಯಾವ ಆರ್ಡರ್‌ಗಳೂ ಇಲ್ಲ',
    shopNotRegistered: 'ನಿಮ್ಮ ಅಂಗಡಿ ನೋಂದಾಯಿತವಾಗಿಲ್ಲ',
    registerShopPrompt: 'ನಿಮ್ಮ ಅಂಗಡಿಯನ್ನು ನೋಂದಾಯಿಸಿ ಮತ್ತು GramSathi ನಲ್ಲಿ ಮಾರಾಟ ಪ್ರಾರಂಭಿಸಿ',
    registerShopButton: 'ಅಂಗಡಿ ನೋಂದಾಯಿಸಿ',
    addItem: 'ವಸ್ತು ಸೇರಿಸಿ',
    itemNameHint: 'ವಸ್ತುವಿನ ಹೆಸರು (ಇಂಗ್ಲೀಷ್)',
    itemNameHindiHint: 'ಹೆಸರು (ಹಿಂದಿ)',
    priceHint: 'ಬೆಲೆ (₹)',
    unitHint: 'ಘಟಕ (kg, piece...)',
    stockHint: 'ಸ್ಟಾಕ್',
    addToListButton: 'ಪಟ್ಟಿಗೆ ಸೇರಿಸಿ',
    addItemsAbove: 'ಮೇಲೆ ವಸ್ತುಗಳನ್ನು ಸೇರಿಸಿ ಮತ್ತು ಉಳಿಸಿ',
    enterPhoneTitle: 'ನಿಮ್ಮ ನಂಬರ್ ನಮೂದಿಸಿ',
    enterPhoneSubtitle: 'ಪ್ರಾರಂಭಿಸಲು ನಿಮ್ಮ ಮೊಬೈಲ್ ನಂಬರ್ ನಮೂದಿಸಿ',
    mobileNumberLabel: 'ಮೊಬೈಲ್ ನಂಬರ್',
    phoneHint: '9876543210',
    nameOptionalLabel: 'ನಿಮ್ಮ ಹೆಸರು (ಐಚ್ಛಿಕ)',
    nameHint: 'ಉದಾ. Ramesh Kumar',
    privacyNotice: 'ನಿಮ್ಮ ನಂಬರ್ ಸುರಕ್ಷಿತ. ಎಂದಿಗೂ ಹಂಚಿಕೊಳ್ಳಲಾಗುವುದಿಲ್ಲ.',
    featureHealthTitle: 'ಆರೋಗ್ಯ ಸಲಹೆ',
    featureHealthSubtitle: 'ಲಕ್ಷಣಗಳನ್ನು ತಿಳಿಸಿ, ಮನೆ ಪರಿಹಾರಗಳನ್ನು ಪಡೆಯಿರಿ',
    featureOrderTitle: 'ಅಂಗಡಿಯಿಂದ ಆರ್ಡರ್ ಮಾಡಿ',
    featureOrderSubtitle: 'ಹತ್ತಿರದ ಅಂಗಡಿಯಿಂದ ವಸ್ತುಗಳನ್ನು ಆರ್ಡರ್ ಮಾಡಿ',
    featureVoiceTitle: 'ಧ್ವನಿಯಲ್ಲಿ ಮಾತಾಡಿ',
    featureVoiceSubtitle: 'ನಿಮ್ಮ ಭಾಷೆಯಲ್ಲಿ ಮಾತಾಡಿ, ತಕ್ಷಣ ಉತ್ತರ ಪಡೆಯಿರಿ',
    micPermissionDenied: 'ಮೈಕ್ರೋಫೋನ್ ಪ್ರವೇಶಕ್ಕೆ ಅನುಮತಿಸಿ',
    networkError: 'ನೆಟ್‌ವರ್ಕ್ ದೋಷ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',
    networkErrorRetry: 'ನೆಟ್‌ವರ್ಕ್ ಸಮಸ್ಯೆ. ನಂತರ ಪ್ರಯತ್ನಿಸಿ.',
    aiErrorPrefix: '⚠️ ',
    pincodeError: '6 ಅಂಕಿಯ ಪಿನ್‌ಕೋಡ್ ನಮೂದಿಸಿ',
    phone10DigitsError: '10 ಅಂಕಿಯ ನಂಬರ್ ನಮೂದಿಸಿ',
    nameAndPriceRequired: 'ಹೆಸರು ಮತ್ತು ಬೆಲೆ ಅಗತ್ಯ',
    shopInfoNotFound: 'ಅಂಗಡಿ ಮಾಹಿತಿ ಕಂಡುಬಂದಿಲ್ಲ',
    retryButton: 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ',
    skipButton: 'ಬಿಡಿ',
    closeButton: 'ಮುಚ್ಚಿ',
    inventorySaved: 'ದಾಸ್ತಾನು ಉಳಿಸಲಾಗಿದೆ! ✓',
    fallbackSymptomText: 'ಲಕ್ಷಣಗಳು',
    healthSuggestions: ['ನನಗೆ ಜ್ವರ ಇದೆ', 'ತಲೆನೋವು', 'ಹತ್ತಿರದ ಕ್ಲಿನಿಕ್', 'ನನ್ನ ಹತ್ತಿರ ಅಂಗಡಿಗಳು ಎಲ್ಲಿ'],
    placeOrderButton: 'ಆರ್ಡರ್ ಮಾಡಿ',
    stockLabel: 'ಸ್ಟಾಕ್',
    itemsAvailable: 'ವಸ್ತುಗಳು ಲಭ್ಯವಿದೆ',
    itemsCount: 'ವಸ್ತುಗಳು',
    saveButton: 'ಉಳಿಸಿ',
    changeLanguage: 'ಭಾಷೆ ಬದಲಿಸಿ',
    logoutButton: 'ಸೈನ್ ಔಟ್',
    logoutConfirmTitle: 'ಸೈನ್ ಔಟ್ ಮಾಡಬೇಕೇ?',
    logoutConfirmMessage: 'ನೀವು ನಿಜವಾಗಿಯೂ ಸೈನ್ ಔಟ್ ಮಾಡಲು ಬಯಸುತ್ತೀರಾ?',
    cancelButton: 'ರದ್ದು ಮಾಡಿ',
    summary: 'ಸಾರಾಂಶ',
    currentlyLabel: 'ಪ್ರಸ್ತುತ:',
    welcomeBack: 'ಮತ್ತೆ ಸ್ವಾಗತ',
    languageLabel: 'ಭಾಷೆ',
  );

  // ── Bengali ──────────────────────────────────────────────────────────────
  static final _localizedBn = LocalizedStrings(
    appName: 'GramSathi',
    tagline: 'আপনার AI সহকারী',
    selectLanguage: 'আপনার ভাষা বেছে নিন',
    continueText: 'এগিয়ে যান',
    welcomeTitle: 'নমস্কার! 🙏',
    welcomeSubtitle: 'আমি GramSathi – আপনার AI সহকারী',
    getStarted: 'শুরু করুন',
    howCanIHelp: 'আজ আমি আপনাকে কীভাবে সাহায্য করতে পারি?',
    howCanIHelpSub: 'ভয়েস বা লেখায় জিজ্ঞেস করুন',
    healthCard: 'স্বাস্থ্য পরামর্শ',
    healthAdviceLabel: 'স্বাস্থ্য পরামর্শ',
    commerceCard: 'দোকান থেকে অর্ডার করুন',
    orderFromShopLabel: 'দোকান থেকে অর্ডার',
    quickServices: 'দ্রুত অ্যাক্সেস',
    nearbyClinicLink: 'কাছের ক্লিনিক',
    nearbyClinicSublabel: 'কাছের ক্লিনিক',
    myOrdersLink: 'আমার অর্ডার',
    myOrdersSublabel: 'আমার অর্ডার',
    myShopLink: 'আমার দোকান',
    myShopSublabel: 'আমার দোকান',
    settingsTooltip: 'সেটিংস',
    voiceAsk: 'ভয়েসে জিজ্ঞেস করুন',
    voiceAskSubtitle: 'চাপ দিয়ে ভয়েসে জিজ্ঞেস করুন',
    healthTitle: 'স্বাস্থ্য সহকারী',
    describeSymptoms: 'স্বাস্থ্য বা কাছের ক্লিনিক/দোকান সম্পর্কে জিজ্ঞেস করুন',
    describeSymptomsSubtitle: 'লক্ষণ বলুন বা বলুন/লিখুন: কাছের ক্লিনিক বা দোকান এবং পিনকোড',
    emergencyBanner: '⚠️ এটি গুরুতর অবস্থা! এখনই 108 তে কল করুন।',
    getDoctorSummary: 'ডাক্তার সারাংশ পান',
    doctorSummaryTitle: 'ডাক্তার সারাংশ',
    thinkingIndicator: 'ভাবছি...',
    typeMessage: 'এখানে লিখুন...',
    playAudio: 'শুনুন',
    pauseAudio: 'থামুন',
    send: 'পাঠান',
    nearbyClinics: 'কাছের ক্লিনিক',
    nearbyShops: 'কাছের দোকান',
    enterPincode: 'পিনকোড দিন',
    searchButton: 'খুঁজুন',
    searchingShops: 'দোকান খোঁজা হচ্ছে...',
    noShopsFound: 'কোনো দোকান পাওয়া যায়নি',
    noShopsTryDiff: 'অন্য পিনকোড চেষ্টা করুন',
    shopsFoundText: (n) => '${n}টি দোকান পাওয়া গেছে',
    nearbyShopsWillShow: 'কাছের দোকানগুলি এখানে দেখাবে',
    noFacilitiesFound: 'এই পিনকোডে কোনো সেবা পাওয়া যায়নি',
    orderFromShopTitle: 'দোকান থেকে অর্ডার করুন',
    noItemsInShop: 'এই দোকানে এখনো কোনো পণ্য নেই',
    goBack: 'পিছনে যান',
    addButton: 'যোগ করুন',
    notAvailable: 'পাওয়া যাচ্ছে না',
    totalAmount: 'মোট পরিমাণ',
    orderPlaced: 'অর্ডার হয়ে গেছে! 🎉',
    goHome: 'হোমে যান',
    shopDashboard: 'দোকান ড্যাশবোর্ড',
    todayRevenue: 'আজকের আয়',
    todayOrders: 'আজকের অর্ডার',
    totalOrders: 'মোট অর্ডার',
    pendingOrders: 'বাকি অর্ডার',
    inventory: 'ইনভেন্টরি',
    newOrders: 'নতুন অর্ডার',
    noOrders: 'এখনো কোনো অর্ডার নেই',
    shopNotRegistered: 'আপনার দোকান নিবন্ধিত নয়',
    registerShopPrompt: 'আপনার দোকান নিবন্ধন করুন এবং GramSathi তে বিক্রি শুরু করুন',
    registerShopButton: 'দোকান নিবন্ধন করুন',
    addItem: 'পণ্য যোগ করুন',
    itemNameHint: 'পণ্যের নাম (ইংরেজি)',
    itemNameHindiHint: 'নাম (হিন্দি)',
    priceHint: 'দাম (₹)',
    unitHint: 'একক (kg, piece...)',
    stockHint: 'স্টক',
    addToListButton: 'তালিকায় যোগ করুন',
    addItemsAbove: 'উপরে পণ্য যোগ করুন এবং সেভ করুন',
    enterPhoneTitle: 'আপনার নম্বর দিন',
    enterPhoneSubtitle: 'শুরু করতে আপনার মোবাইল নম্বর দিন',
    mobileNumberLabel: 'মোবাইল নম্বর',
    phoneHint: '9876543210',
    nameOptionalLabel: 'আপনার নাম (ঐচ্ছিক)',
    nameHint: 'যেমন: Ramesh Kumar',
    privacyNotice: 'আপনার নম্বর সুরক্ষিত। কখনো শেয়ার করা হবে না।',
    featureHealthTitle: 'স্বাস্থ্য পরামর্শ',
    featureHealthSubtitle: 'লক্ষণ বলুন, ঘরোয়া প্রতিকার পান',
    featureOrderTitle: 'দোকান থেকে অর্ডার করুন',
    featureOrderSubtitle: 'কাছের দোকান থেকে পণ্য অর্ডার করুন',
    featureVoiceTitle: 'ভয়েসে কথা বলুন',
    featureVoiceSubtitle: 'আপনার ভাষায় বলুন, তাৎক্ষণিক উত্তর পান',
    micPermissionDenied: 'মাইক্রোফোন অ্যাক্সেসের অনুমতি দিন',
    networkError: 'নেটওয়ার্ক ত্রুটি। আবার চেষ্টা করুন।',
    networkErrorRetry: 'নেটওয়ার্ক সমস্যা। পরে চেষ্টা করুন।',
    aiErrorPrefix: '⚠️ ',
    pincodeError: '6 সংখ্যার পিনকোড দিন',
    phone10DigitsError: '10 সংখ্যার নম্বর দিন',
    nameAndPriceRequired: 'নাম এবং দাম প্রয়োজন',
    shopInfoNotFound: 'দোকানের তথ্য পাওয়া যায়নি',
    retryButton: 'আবার চেষ্টা করুন',
    skipButton: 'এড়িয়ে যান',
    closeButton: 'বন্ধ করুন',
    inventorySaved: 'ইনভেন্টরি সেভ হয়েছে! ✓',
    fallbackSymptomText: 'লক্ষণ',
    healthSuggestions: ['আমার জ্বর হয়েছে', 'মাথাব্যথা', 'কাছের ক্লিনিক', 'আমার কাছে দোকান কোথায়'],
    placeOrderButton: 'অর্ডার করুন',
    stockLabel: 'স্টক',
    itemsAvailable: 'পণ্য পাওয়া যাচ্ছে',
    itemsCount: 'পণ্য',
    saveButton: 'সেভ করুন',
    changeLanguage: 'ভাষা পরিবর্তন করুন',
    logoutButton: 'সাইন আউট',
    logoutConfirmTitle: 'সাইন আউট করবেন?',
    logoutConfirmMessage: 'আপনি কি সত্যিই সাইন আউট করতে চান?',
    cancelButton: 'বাতিল করুন',
    summary: 'সারাংশ',
    currentlyLabel: 'বর্তমানে:',
    welcomeBack: 'আবার স্বাগতম',
    languageLabel: 'ভাষা',
  );

  // ── Gujarati ─────────────────────────────────────────────────────────────
  static final _localizedGu = LocalizedStrings(
    appName: 'GramSathi',
    tagline: 'તમારો AI સહાયક',
    selectLanguage: 'તમારી ભાષા પસંદ કરો',
    continueText: 'આગળ વધો',
    welcomeTitle: 'નમસ્તે! 🙏',
    welcomeSubtitle: 'હું GramSathi છું – તમારો AI સહાયક',
    getStarted: 'શરૂ કરો',
    howCanIHelp: 'આજે હું તમને કેવી રીતે મદદ કરી શકું?',
    howCanIHelpSub: 'અવાજ અથવા લખાણ દ્વારા પૂછો',
    healthCard: 'આરોગ્ય સલાહ',
    healthAdviceLabel: 'આરોગ્ય સલાહ',
    commerceCard: 'દુકાનમાંથી ઓર્ડર કરો',
    orderFromShopLabel: 'દુકાનમાંથી ઓર્ડર',
    quickServices: 'ઝડપી ઍક્સેસ',
    nearbyClinicLink: 'નજીકનું ક્લિનિક',
    nearbyClinicSublabel: 'નજીકનું ક્લિનિક',
    myOrdersLink: 'મારા ઓર્ડર',
    myOrdersSublabel: 'મારા ઓર્ડર',
    myShopLink: 'મારી દુકાન',
    myShopSublabel: 'મારી દુકાન',
    settingsTooltip: 'સેટિંગ્સ',
    voiceAsk: 'અવાજ દ્વારા પૂછો',
    voiceAskSubtitle: 'દબાવીને અવાજ દ્વારા પૂછો',
    healthTitle: 'આરોગ્ય સહાયક',
    describeSymptoms: 'આરોગ્ય અથવા નજીકના ક્લિનિક/દુકાન વિશે પૂછો',
    describeSymptomsSubtitle: 'લક્ષણો જણાવો અથવા બોલો/લખો: નજીકનું ક્લિનિક અથવા દુકાનો અને પિનકોડ',
    emergencyBanner: '⚠️ આ ગંભીર સ્થિતિ છે! તરત 108 પર ફોન કરો.',
    getDoctorSummary: 'ડૉક્ટર સારાંશ મેળવો',
    doctorSummaryTitle: 'ડૉક્ટર સારાંશ',
    thinkingIndicator: 'વિચારી રહ્યો છું...',
    typeMessage: 'અહીં ટાઇપ કરો...',
    playAudio: 'સાંભળો',
    pauseAudio: 'રોકો',
    send: 'મોકલો',
    nearbyClinics: 'નજીકનું ક્લિનિક',
    nearbyShops: 'નજીકની દુકાનો',
    enterPincode: 'પિનકોડ દાખલ કરો',
    searchButton: 'શોધો',
    searchingShops: 'દુકાનો શોધી રહ્યા છીએ...',
    noShopsFound: 'કોઈ દુકાન મળી નહીં',
    noShopsTryDiff: 'બીજો પિનકોડ અજમાવો',
    shopsFoundText: (n) => '$n દુકાન${n == 1 ? '' : 'ો'} મળી',
    nearbyShopsWillShow: 'નજીકની દુકાનો અહીં દેખાશે',
    noFacilitiesFound: 'આ પિનકોડ માટે કોઈ સેવા મળી નહીં',
    orderFromShopTitle: 'દુકાનમાંથી ઓર્ડર કરો',
    noItemsInShop: 'આ દુકાનમાં હજુ કોઈ વસ્તુ નથી',
    goBack: 'પાછળ જાઓ',
    addButton: 'ઉમેરો',
    notAvailable: 'ઉપલબ્ધ નથી',
    totalAmount: 'કુલ રકમ',
    orderPlaced: 'ઓર્ડર થઈ ગયો! 🎉',
    goHome: 'ઘરે જાઓ',
    shopDashboard: 'દુકાન ડૅશબોર્ડ',
    todayRevenue: 'આજની કમાણી',
    todayOrders: 'આજના ઓર્ડર',
    totalOrders: 'કુલ ઓર્ડર',
    pendingOrders: 'બાકી ઓર્ડર',
    inventory: 'ઇન્વેન્ટરી',
    newOrders: 'નવા ઓર્ડર',
    noOrders: 'હજુ કોઈ ઓર્ડર નથી',
    shopNotRegistered: 'તમારી દુકાન નોંધાઈ નથી',
    registerShopPrompt: 'તમારી દુકાન નોંધો અને GramSathi પર વેચવાનું શરૂ કરો',
    registerShopButton: 'દુકાન નોંધો',
    addItem: 'વસ્તુ ઉમેરો',
    itemNameHint: 'વસ્તુનું નામ (અંગ્રેજી)',
    itemNameHindiHint: 'નામ (હિન્દી)',
    priceHint: 'કિંમત (₹)',
    unitHint: 'એકમ (kg, piece...)',
    stockHint: 'સ્ટૉક',
    addToListButton: 'સૂચિમાં ઉમેરો',
    addItemsAbove: 'ઉપર વસ્તુ ઉમેરો અને સেવ કરો',
    enterPhoneTitle: 'તમારો નંબર દાખલ કરો',
    enterPhoneSubtitle: 'શરૂ કરવા માટે તમારો મોબાઇલ નંબર દાખલ કરો',
    mobileNumberLabel: 'મોબાઇલ નંબર',
    phoneHint: '9876543210',
    nameOptionalLabel: 'તમારું નામ (વૈકલ્પિક)',
    nameHint: 'દા.ત. Ramesh Kumar',
    privacyNotice: 'તમારો નંબર સુરક્ષિત છે. ક્યારેય શૅર નહીં થાય.',
    featureHealthTitle: 'આરોગ્ય સલાહ',
    featureHealthSubtitle: 'લક્ષણો જણાવો, ઘરેલું ઉપાય મેળવો',
    featureOrderTitle: 'દુકાનમાંથી ઓર્ડર કરો',
    featureOrderSubtitle: 'નજીકની દુકાનમાંથી સામાન ઓર્ડર કરો',
    featureVoiceTitle: 'અવાજ દ્વારા બોલો',
    featureVoiceSubtitle: 'તમારી ભાષામાં બોલો, તાત્કાલિક જવાબ મેળવો',
    micPermissionDenied: 'માઇક્રોફોન ઍક્સેસ અનુમતિ આપો',
    networkError: 'નેટવર્ક ભૂલ. ફરી પ્રયાસ કરો.',
    networkErrorRetry: 'નેટવર્ક સમસ્યા. પછી પ્રયાસ કરો.',
    aiErrorPrefix: '⚠️ ',
    pincodeError: '6 અંકનો પિનકોડ દાખલ કરો',
    phone10DigitsError: '10 અંકનો નંબર દાખલ કરો',
    nameAndPriceRequired: 'નામ અને કિંમત જરૂરી છે',
    shopInfoNotFound: 'દુકાનની માહિતી મળી નહીં',
    retryButton: 'ફરી પ્રયાસ કરો',
    skipButton: 'છોડો',
    closeButton: 'બંધ કરો',
    inventorySaved: 'ઇન્વેન્ટરી સેવ થઈ! ✓',
    fallbackSymptomText: 'લક્ષણો',
    healthSuggestions: ['મને તાવ છે', 'માથું દુઃખે છે', 'નજીકનું ક્લિનિક', 'મારી નજીક દુકાનો ક્યાં છે'],
    placeOrderButton: 'ઓર્ડર કરો',
    stockLabel: 'સ્ટૉક',
    itemsAvailable: 'વસ્તુ ઉપલબ્ધ',
    itemsCount: 'વસ્તુ',
    saveButton: 'સેવ કરો',
    changeLanguage: 'ભાષા બદલો',
    logoutButton: 'સાઇન આઉટ',
    logoutConfirmTitle: 'સાઇન આઉટ?',
    logoutConfirmMessage: 'શું તમે ખરેખર સાઇન આઉટ કરવા માગો છો?',
    cancelButton: 'રદ કરો',
    summary: 'સારાંશ',
    currentlyLabel: 'હાલ:',
    welcomeBack: 'ફરી સ્વાગત છે',
    languageLabel: 'ભાષા',
  );
}

/// Strings that change with app language. Use with [AppStrings.forLanguage].
class LocalizedStrings {
  const LocalizedStrings({
    required this.appName,
    required this.tagline,
    this.howCanIHelpSub = '',
    this.searchingShops = '',
    this.noShopsTryDiff = '',
    this.summary = '',
    this.currentlyLabel = '',
    this.welcomeBack = '',
    this.languageLabel = '',
    this.shopsFoundText,
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
  final String howCanIHelpSub;
  final String searchingShops;
  final String noShopsTryDiff;
  final String summary;
  final String currentlyLabel;
  final String welcomeBack;
  final String languageLabel;
  final String Function(int)? shopsFoundText;
}
