/**
 * UI string translations for all 8 supported languages.
 * Mirrors the Flutter app's LocalizedStrings.
 */

export interface Strings {
  // Login
  enterPhoneTitle: string
  enterPhoneSubtitle: string
  languageLabel: string
  continueText: string
  privacyNotice: string
  // Home
  tagline: string
  howCanIHelp: string
  howCanIHelpSub: string
  healthCard: string
  healthCardSub: string
  commerceCard: string
  commerceCardSub: string
  voiceAsk: string
  voiceAskSubtitle: string
  quickAccess: string
  nearbyClinicLink: string
  nearbyClinicSub: string
  myOrdersLink: string
  myOrdersSub: string
  myShopLink: string
  myShopSub: string
  settings: string
  changeLanguage: string
  currentlyLabel: string
  signOut: string
  // Health page
  healthTitle: string
  healthSubtitle: string
  typeMessage: string
  healthSuggestions: string[]
  summary: string
  doctorSummaryTitle: string
  doctorSummaryClose: string
  emergencyText: string
  // Shops page
  nearbyShopsTitle: string
  enterPincode: string
  searchButton: string
  searchingShops: string
  noShopsFound: string
  noShopsTryDiff: string
  shopsFound: (n: number) => string
  orderFromShop: string
  // Common
  back: string
  goHome: string
  welcomeBack: string
}

// ── Hindi ─────────────────────────────────────────────────────────────────────
const hi: Strings = {
  enterPhoneTitle: 'अपना नंबर डालें',
  enterPhoneSubtitle: 'शुरू करने के लिए अपना मोबाइल नंबर डालें',
  languageLabel: 'भाषा',
  continueText: 'आगे बढ़ें',
  privacyNotice: 'आगे बढ़ने पर आप हमारी Privacy Policy से सहमत हैं',
  tagline: 'आपका AI सहायक',
  howCanIHelp: 'आज मैं आपकी कैसे मदद करूँ?',
  howCanIHelpSub: 'आवाज़ या लिखकर पूछें',
  healthCard: 'स्वास्थ्य सलाह',
  healthCardSub: 'लक्षण बताएँ',
  commerceCard: 'दुकान से मँगाएँ',
  commerceCardSub: 'खोजें और ऑर्डर करें',
  voiceAsk: 'आवाज़ से पूछें',
  voiceAskSubtitle: 'अपनी भाषा में बोलकर पूछें',
  quickAccess: 'त्वरित सेवाएँ',
  nearbyClinicLink: 'नजदीकी क्लीनिक',
  nearbyClinicSub: 'क्लीनिक और फार्मेसी खोजें',
  myOrdersLink: 'मेरे ऑर्डर',
  myOrdersSub: 'अपने ऑर्डर ट्रैक करें',
  myShopLink: 'मेरी दुकान',
  myShopSub: 'इन्वेंटरी और ऑर्डर',
  settings: 'सेटिंग्स',
  changeLanguage: 'भाषा बदलें',
  currentlyLabel: 'अभी:',
  signOut: 'साइन आउट',
  healthTitle: 'स्वास्थ्य सलाह',
  healthSubtitle: 'अपनी भाषा में पूछें',
  typeMessage: 'यहाँ लिखें...',
  healthSuggestions: ['नजदीकी क्लीनिक', 'मुझे बुखार है', 'पेट में दर्द', 'नजदीकी दवाखाना', 'सिरदर्द'],
  summary: 'सारांश',
  doctorSummaryTitle: 'डॉक्टर सारांश',
  doctorSummaryClose: 'बंद करें',
  emergencyText: '⚠️ गंभीर स्थिति — अभी 108 पर कॉल करें',
  nearbyShopsTitle: 'नजदीकी दुकानें',
  enterPincode: 'पिनकोड डालें',
  searchButton: 'खोजें',
  searchingShops: 'दुकानें खोज रहे हैं...',
  noShopsFound: 'कोई दुकान नहीं मिली',
  noShopsTryDiff: 'दूसरा पिनकोड आज़माएँ',
  shopsFound: (n) => `${n} दुकान${n === 1 ? '' : 'ें'} मिली`,
  orderFromShop: 'ऑर्डर करें',
  back: 'वापस',
  goHome: 'घर जाएँ',
  welcomeBack: 'वापसी पर स्वागत है',
}

// ── Marathi ───────────────────────────────────────────────────────────────────
const mr: Strings = {
  enterPhoneTitle: 'तुमचा नंबर द्या',
  enterPhoneSubtitle: 'सुरू करण्यासाठी तुमचा मोबाइल नंबर द्या',
  languageLabel: 'भाषा',
  continueText: 'पुढे जा',
  privacyNotice: 'पुढे जाऊन तुम्ही आमच्या Privacy Policy शी सहमत आहात',
  tagline: 'तुमचा AI सहाय्यक',
  howCanIHelp: 'आज मी तुमची कशी मदत करू?',
  howCanIHelpSub: 'आवाज किंवा लिखाणाने विचारा',
  healthCard: 'आरोग्य सल्ला',
  healthCardSub: 'लक्षणे सांगा',
  commerceCard: 'दुकानातून मागवा',
  commerceCardSub: 'शोधा आणि ऑर्डर करा',
  voiceAsk: 'आवाजाने विचारा',
  voiceAskSubtitle: 'तुमच्या भाषेत बोलून विचारा',
  quickAccess: 'जलद सेवा',
  nearbyClinicLink: 'जवळचे क्लिनिक',
  nearbyClinicSub: 'क्लिनिक आणि फार्मसी शोधा',
  myOrdersLink: 'माझे ऑर्डर',
  myOrdersSub: 'ऑर्डर ट्रॅक करा',
  myShopLink: 'माझे दुकान',
  myShopSub: 'इन्व्हेंटरी आणि ऑर्डर',
  settings: 'सेटिंग्स',
  changeLanguage: 'भाषा बदला',
  currentlyLabel: 'सध्या:',
  signOut: 'साइन आउट',
  healthTitle: 'आरोग्य सल्ला',
  healthSubtitle: 'तुमच्या भाषेत विचारा',
  typeMessage: 'इथे लिहा...',
  healthSuggestions: ['जवळचे क्लिनिक', 'मला ताप आहे', 'पोटात दुखतेय', 'जवळची फार्मसी', 'डोकेदुखी'],
  summary: 'सारांश',
  doctorSummaryTitle: 'डॉक्टर सारांश',
  doctorSummaryClose: 'बंद करा',
  emergencyText: '⚠️ गंभीर स्थिती — आत्ताच 108 वर कॉल करा',
  nearbyShopsTitle: 'जवळच्या दुकाने',
  enterPincode: 'पिनकोड टाका',
  searchButton: 'शोधा',
  searchingShops: 'दुकाने शोधत आहे...',
  noShopsFound: 'कोणतेही दुकान सापडले नाही',
  noShopsTryDiff: 'वेगळा पिनकोड वापरून पाहा',
  shopsFound: (n) => `${n} दुकान${n === 1 ? '' : 'े'} सापडली`,
  orderFromShop: 'ऑर्डर करा',
  back: 'मागे',
  goHome: 'घरी जा',
  welcomeBack: 'परत स्वागत',
}

// ── Tamil ─────────────────────────────────────────────────────────────────────
const ta: Strings = {
  enterPhoneTitle: 'உங்கள் எண்ணை உள்ளிடவும்',
  enterPhoneSubtitle: 'தொடங்க உங்கள் மொபைல் எண்ணை உள்ளிடவும்',
  languageLabel: 'மொழி',
  continueText: 'தொடரவும்',
  privacyNotice: 'தொடர்வதன் மூலம் எங்கள் Privacy Policy-ஐ ஏற்கிறீர்கள்',
  tagline: 'உங்கள் AI உதவியாளர்',
  howCanIHelp: 'இன்று நான் உங்களுக்கு எப்படி உதவலாம்?',
  howCanIHelpSub: 'குரல் அல்லது எழுத்தில் கேளுங்கள்',
  healthCard: 'சுகாதார ஆலோசனை',
  healthCardSub: 'அறிகுறிகளை சொல்லுங்கள்',
  commerceCard: 'கடையிலிருந்து வாங்கவும்',
  commerceCardSub: 'தேடி ஆர்டர் செய்யுங்கள்',
  voiceAsk: 'குரலில் கேளுங்கள்',
  voiceAskSubtitle: 'உங்கள் மொழியில் பேசி கேளுங்கள்',
  quickAccess: 'விரைவு அணுகல்',
  nearbyClinicLink: 'அருகில் உள்ள கிளினிக்',
  nearbyClinicSub: 'கிளினிக் மற்றும் மருந்தகங்களை கண்டறியுங்கள்',
  myOrdersLink: 'என் ஆர்டர்கள்',
  myOrdersSub: 'உங்கள் ஆர்டர்களை கண்காணியுங்கள்',
  myShopLink: 'என் கடை',
  myShopSub: 'சரக்கு மற்றும் ஆர்டர்கள்',
  settings: 'அமைப்புகள்',
  changeLanguage: 'மொழியை மாற்றவும்',
  currentlyLabel: 'தற்போது:',
  signOut: 'வெளியேறு',
  healthTitle: 'சுகாதார உதவியாளர்',
  healthSubtitle: 'உங்கள் மொழியில் கேளுங்கள்',
  typeMessage: 'இங்கே எழுதுங்கள்...',
  healthSuggestions: ['அருகில் உள்ள கிளினிக்', 'எனக்கு காய்ச்சல் இருக்கிறது', 'வயிற்று வலி', 'அருகில் உள்ள மருந்தகம்', 'தலைவலி'],
  summary: 'சுருக்கம்',
  doctorSummaryTitle: 'மருத்துவர் சுருக்கம்',
  doctorSummaryClose: 'மூடவும்',
  emergencyText: '⚠️ அவசரநிலை — இப்போதே 108 ஐ அழைக்கவும்',
  nearbyShopsTitle: 'அருகில் உள்ள கடைகள்',
  enterPincode: 'பின்கோடை உள்ளிடவும்',
  searchButton: 'தேடவும்',
  searchingShops: 'கடைகளை தேடுகிறோம்...',
  noShopsFound: 'கடைகள் எதுவும் கிடைக்கவில்லை',
  noShopsTryDiff: 'வேறு பின்கோடை முயற்சிக்கவும்',
  shopsFound: (n) => `${n} கடை${n === 1 ? '' : 'கள்'} கிடைத்தது`,
  orderFromShop: 'கடையிலிருந்து ஆர்டர் செய்யவும்',
  back: 'திரும்பு',
  goHome: 'வீட்டிற்கு செல்லவும்',
  welcomeBack: 'மீண்டும் வரவேற்கிறோம்',
}

// ── Telugu ────────────────────────────────────────────────────────────────────
const te: Strings = {
  enterPhoneTitle: 'మీ నంబర్ నమోదు చేయండి',
  enterPhoneSubtitle: 'ప్రారంభించడానికి మీ మొబైల్ నంబర్ నమోదు చేయండి',
  languageLabel: 'భాష',
  continueText: 'కొనసాగించు',
  privacyNotice: 'కొనసాగించడం ద్వారా మీరు మా Privacy Policy కి అంగీకరిస్తున్నారు',
  tagline: 'మీ AI సహాయకుడు',
  howCanIHelp: 'ఈరోజు మీకు ఎలా సహాయపడగలను?',
  howCanIHelpSub: 'వాయిస్ లేదా టెక్స్ట్‌లో అడగండి',
  healthCard: 'ఆరోగ్య సలహా',
  healthCardSub: 'లక్షణాలు చెప్పండి',
  commerceCard: 'దుకాణం నుండి ఆర్డర్ చేయండి',
  commerceCardSub: 'వెతకండి & ఆర్డర్ చేయండి',
  voiceAsk: 'వాయిస్‌తో అడగండి',
  voiceAskSubtitle: 'మీ భాషలో మాట్లాడి అడగండి',
  quickAccess: 'త్వరిత యాక్సెస్',
  nearbyClinicLink: 'దగ్గర క్లినిక్',
  nearbyClinicSub: 'క్లినిక్ & ఫార్మసీలు కనుగొనండి',
  myOrdersLink: 'నా ఆర్డర్లు',
  myOrdersSub: 'మీ ఆర్డర్లను ట్రాక్ చేయండి',
  myShopLink: 'నా దుకాణం',
  myShopSub: 'ఇన్వెంటరీ & ఆర్డర్లు',
  settings: 'సెట్టింగులు',
  changeLanguage: 'భాష మార్చండి',
  currentlyLabel: 'ప్రస్తుతం:',
  signOut: 'సైన్ అవుట్',
  healthTitle: 'ఆరోగ్య సహాయకుడు',
  healthSubtitle: 'మీ భాషలో అడగండి',
  typeMessage: 'ఇక్కడ టైప్ చేయండి...',
  healthSuggestions: ['దగ్గర క్లినిక్', 'నాకు జ్వరం వచ్చింది', 'కడుపు నొప్పి', 'దగ్గర ఫార్మసీ', 'తలనొప్పి'],
  summary: 'సారాంశం',
  doctorSummaryTitle: 'డాక్టర్ సారాంశం',
  doctorSummaryClose: 'మూసివేయి',
  emergencyText: '⚠️ అత్యవసరం — ఇప్పుడే 108 కి కాల్ చేయండి',
  nearbyShopsTitle: 'దగ్గర దుకాణాలు',
  enterPincode: 'పిన్‌కోడ్ నమోదు చేయండి',
  searchButton: 'వెతకండి',
  searchingShops: 'దుకాణాలు వెతుకుతున్నాం...',
  noShopsFound: 'దుకాణాలు కనుగొనబడలేదు',
  noShopsTryDiff: 'వేరే పిన్‌కోడ్ ప్రయత్నించండి',
  shopsFound: (n) => `${n} దుకాణం${n === 1 ? '' : 'లు'} కనుగొనబడ్డాయి`,
  orderFromShop: 'దుకాణం నుండి ఆర్డర్ చేయండి',
  back: 'వెనక్కి',
  goHome: 'హోమ్‌కి వెళ్ళండి',
  welcomeBack: 'మళ్ళీ స్వాగతం',
}

// ── Kannada ───────────────────────────────────────────────────────────────────
const kn: Strings = {
  enterPhoneTitle: 'ನಿಮ್ಮ ನಂಬರ್ ನಮೂದಿಸಿ',
  enterPhoneSubtitle: 'ಪ್ರಾರಂಭಿಸಲು ನಿಮ್ಮ ಮೊಬೈಲ್ ನಂಬರ್ ನಮೂದಿಸಿ',
  languageLabel: 'ಭಾಷೆ',
  continueText: 'ಮುಂದುವರಿಯಿರಿ',
  privacyNotice: 'ಮುಂದುವರಿಯುವ ಮೂಲಕ ನೀವು ನಮ್ಮ Privacy Policy ಗೆ ಒಪ್ಪುತ್ತೀರಿ',
  tagline: 'ನಿಮ್ಮ AI ಸಹಾಯಕ',
  howCanIHelp: 'ಇಂದು ನಾನು ನಿಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಲಿ?',
  howCanIHelpSub: 'ಧ್ವನಿ ಅಥವಾ ಪಠ್ಯದಲ್ಲಿ ಕೇಳಿ',
  healthCard: 'ಆರೋಗ್ಯ ಸಲಹೆ',
  healthCardSub: 'ಲಕ್ಷಣಗಳನ್ನು ತಿಳಿಸಿ',
  commerceCard: 'ಅಂಗಡಿಯಿಂದ ಆರ್ಡರ್ ಮಾಡಿ',
  commerceCardSub: 'ಹುಡುಕಿ ಮತ್ತು ಆರ್ಡರ್ ಮಾಡಿ',
  voiceAsk: 'ಧ್ವನಿಯಲ್ಲಿ ಕೇಳಿ',
  voiceAskSubtitle: 'ನಿಮ್ಮ ಭಾಷೆಯಲ್ಲಿ ಮಾತನಾಡಿ ಕೇಳಿ',
  quickAccess: 'ತ್ವರಿತ ಪ್ರವೇಶ',
  nearbyClinicLink: 'ಹತ್ತಿರದ ಕ್ಲಿನಿಕ್',
  nearbyClinicSub: 'ಕ್ಲಿನಿಕ್ ಮತ್ತು ಫಾರ್ಮಸಿ ಹುಡುಕಿ',
  myOrdersLink: 'ನನ್ನ ಆರ್ಡರ್‌ಗಳು',
  myOrdersSub: 'ನಿಮ್ಮ ಆರ್ಡರ್‌ಗಳನ್ನು ಟ್ರ್ಯಾಕ್ ಮಾಡಿ',
  myShopLink: 'ನನ್ನ ಅಂಗಡಿ',
  myShopSub: 'ದಾಸ್ತಾನು ಮತ್ತು ಆರ್ಡರ್‌ಗಳು',
  settings: 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
  changeLanguage: 'ಭಾಷೆ ಬದಲಿಸಿ',
  currentlyLabel: 'ಪ್ರಸ್ತುತ:',
  signOut: 'ಸೈನ್ ಔಟ್',
  healthTitle: 'ಆರೋಗ್ಯ ಸಹಾಯಕ',
  healthSubtitle: 'ನಿಮ್ಮ ಭಾಷೆಯಲ್ಲಿ ಕೇಳಿ',
  typeMessage: 'ಇಲ್ಲಿ ಟೈಪ್ ಮಾಡಿ...',
  healthSuggestions: ['ಹತ್ತಿರದ ಕ್ಲಿನಿಕ್', 'ನನಗೆ ಜ್ವರ ಇದೆ', 'ಹೊಟ್ಟೆ ನೋವು', 'ಹತ್ತಿರದ ಔಷಧಾಲಯ', 'ತಲೆನೋವು'],
  summary: 'ಸಾರಾಂಶ',
  doctorSummaryTitle: 'ವೈದ್ಯರ ಸಾರಾಂಶ',
  doctorSummaryClose: 'ಮುಚ್ಚಿ',
  emergencyText: '⚠️ ತುರ್ತು — ಈಗಲೇ 108 ಗೆ ಕರೆ ಮಾಡಿ',
  nearbyShopsTitle: 'ಹತ್ತಿರದ ಅಂಗಡಿಗಳು',
  enterPincode: 'ಪಿನ್‌ಕೋಡ್ ನಮೂದಿಸಿ',
  searchButton: 'ಹುಡುಕಿ',
  searchingShops: 'ಅಂಗಡಿಗಳನ್ನು ಹುಡುಕಲಾಗುತ್ತಿದೆ...',
  noShopsFound: 'ಯಾವ ಅಂಗಡಿಗಳೂ ಕಂಡುಬಂದಿಲ್ಲ',
  noShopsTryDiff: 'ಬೇರೆ ಪಿನ್‌ಕೋಡ್ ಪ್ರಯತ್ನಿಸಿ',
  shopsFound: (n) => `${n} ಅಂಗಡಿ${n === 1 ? '' : 'ಗಳು'} ಕಂಡುಬಂದಿದೆ`,
  orderFromShop: 'ಅಂಗಡಿಯಿಂದ ಆರ್ಡರ್ ಮಾಡಿ',
  back: 'ಹಿಂದೆ',
  goHome: 'ಮನೆಗೆ ಹೋಗಿ',
  welcomeBack: 'ಮತ್ತೆ ಸ್ವಾಗತ',
}

// ── Bengali ───────────────────────────────────────────────────────────────────
const bn: Strings = {
  enterPhoneTitle: 'আপনার নম্বর দিন',
  enterPhoneSubtitle: 'শুরু করতে আপনার মোবাইল নম্বর দিন',
  languageLabel: 'ভাষা',
  continueText: 'এগিয়ে যান',
  privacyNotice: 'এগিয়ে যাওয়ার মাধ্যমে আপনি আমাদের Privacy Policy মেনে নিচ্ছেন',
  tagline: 'আপনার AI সহকারী',
  howCanIHelp: 'আজ আমি আপনাকে কীভাবে সাহায্য করতে পারি?',
  howCanIHelpSub: 'ভয়েস বা লেখায় জিজ্ঞেস করুন',
  healthCard: 'স্বাস্থ্য পরামর্শ',
  healthCardSub: 'লক্ষণ বলুন',
  commerceCard: 'দোকান থেকে অর্ডার করুন',
  commerceCardSub: 'খুঁজুন ও অর্ডার করুন',
  voiceAsk: 'ভয়েসে জিজ্ঞেস করুন',
  voiceAskSubtitle: 'আপনার ভাষায় বলে জিজ্ঞেস করুন',
  quickAccess: 'দ্রুত অ্যাক্সেস',
  nearbyClinicLink: 'কাছের ক্লিনিক',
  nearbyClinicSub: 'ক্লিনিক ও ফার্মেসি খুঁজুন',
  myOrdersLink: 'আমার অর্ডার',
  myOrdersSub: 'অর্ডার ট্র্যাক করুন',
  myShopLink: 'আমার দোকান',
  myShopSub: 'ইনভেন্টরি ও অর্ডার',
  settings: 'সেটিংস',
  changeLanguage: 'ভাষা পরিবর্তন করুন',
  currentlyLabel: 'বর্তমানে:',
  signOut: 'সাইন আউট',
  healthTitle: 'স্বাস্থ্য সহকারী',
  healthSubtitle: 'আপনার ভাষায় জিজ্ঞেস করুন',
  typeMessage: 'এখানে লিখুন...',
  healthSuggestions: ['কাছের ক্লিনিক', 'আমার জ্বর হয়েছে', 'পেটে ব্যথা', 'কাছের ফার্মেসি', 'মাথাব্যথা'],
  summary: 'সারাংশ',
  doctorSummaryTitle: 'ডাক্তার সারাংশ',
  doctorSummaryClose: 'বন্ধ করুন',
  emergencyText: '⚠️ জরুরি অবস্থা — এখনই 108 তে কল করুন',
  nearbyShopsTitle: 'কাছের দোকান',
  enterPincode: 'পিনকোড দিন',
  searchButton: 'খুঁজুন',
  searchingShops: 'দোকান খোঁজা হচ্ছে...',
  noShopsFound: 'কোনো দোকান পাওয়া যায়নি',
  noShopsTryDiff: 'অন্য পিনকোড চেষ্টা করুন',
  shopsFound: (n) => `${n}টি দোকান পাওয়া গেছে`,
  orderFromShop: 'দোকান থেকে অর্ডার করুন',
  back: 'পিছনে',
  goHome: 'হোমে যান',
  welcomeBack: 'আবার স্বাগতম',
}

// ── Gujarati ──────────────────────────────────────────────────────────────────
const gu: Strings = {
  enterPhoneTitle: 'તમારો નંબર દાખલ કરો',
  enterPhoneSubtitle: 'શરૂ કરવા માટે તમારો મોબાઇલ નંબર દાખલ કરો',
  languageLabel: 'ભાષા',
  continueText: 'આગળ વધો',
  privacyNotice: 'આગળ વધવાથી તમે અમારી Privacy Policy સ્વીકારો છો',
  tagline: 'તમારો AI સહાયક',
  howCanIHelp: 'આજે હું તમને કેવી રીતે મદદ કરી શકું?',
  howCanIHelpSub: 'અવાજ અથવા લખાણ દ્વારા પૂછો',
  healthCard: 'આરોગ્ય સલાહ',
  healthCardSub: 'લક્ષણો જણાવો',
  commerceCard: 'દુકાનમાંથી ઓર્ડર કરો',
  commerceCardSub: 'શોધો અને ઓર્ડર કરો',
  voiceAsk: 'અવાજ દ્વારા પૂછો',
  voiceAskSubtitle: 'તમારી ભાષામાં બોલીને પૂછો',
  quickAccess: 'ઝડપી ઍક્સેસ',
  nearbyClinicLink: 'નજીકનું ક્લિનિક',
  nearbyClinicSub: 'ક્લિનિક અને ફાર્મસી શોધો',
  myOrdersLink: 'મારા ઓર્ડર',
  myOrdersSub: 'ઓર્ડર ટ્રૅક કરો',
  myShopLink: 'મારી દુકાન',
  myShopSub: 'ઇન્વેન્ટરી અને ઓર્ડર',
  settings: 'સેટિંગ્સ',
  changeLanguage: 'ભાષા બદલો',
  currentlyLabel: 'હાલ:',
  signOut: 'સાઇન આઉટ',
  healthTitle: 'આરોગ્ય સહાયક',
  healthSubtitle: 'તમારી ભાષામાં પૂછો',
  typeMessage: 'અહીં ટાઇપ કરો...',
  healthSuggestions: ['નજીકનું ક્લિનિક', 'મને તાવ છે', 'પેટ દુઃખે છે', 'નજીકની ફાર્મસી', 'માથું દુઃખે છે'],
  summary: 'સારાંશ',
  doctorSummaryTitle: 'ડૉક્ટર સારાંશ',
  doctorSummaryClose: 'બંધ કરો',
  emergencyText: '⚠️ કટોકટી — હમણાં 108 પર ફોન કરો',
  nearbyShopsTitle: 'નજીકની દુકાનો',
  enterPincode: 'પિનકોડ દાખલ કરો',
  searchButton: 'શોધો',
  searchingShops: 'દુકાનો શોધી રહ્યા છીએ...',
  noShopsFound: 'કોઈ દુકાન મળી નહીં',
  noShopsTryDiff: 'બીજો પિનકોડ અજમાવો',
  shopsFound: (n) => `${n} દુકાન${n === 1 ? '' : 'ો'} મળી`,
  orderFromShop: 'દુકાનમાંથી ઓર્ડર કરો',
  back: 'પાછળ',
  goHome: 'ઘરે જાઓ',
  welcomeBack: 'ફરી સ્વાગત છે',
}

// ── English (default) ─────────────────────────────────────────────────────────
const en: Strings = {
  enterPhoneTitle: 'Enter your mobile number',
  enterPhoneSubtitle: "We'll use this to save your preferences",
  languageLabel: 'Language',
  continueText: 'Continue',
  privacyNotice: 'By continuing you agree to our Privacy Policy',
  tagline: 'Your AI assistant',
  howCanIHelp: 'How can I help you today?',
  howCanIHelpSub: 'Ask in your language — voice or text',
  healthCard: 'Health Advice',
  healthCardSub: 'Ask about symptoms',
  commerceCard: 'Local Shops',
  commerceCardSub: 'Browse & order',
  voiceAsk: 'Ask by Voice',
  voiceAskSubtitle: 'Speak your question in your language',
  quickAccess: 'Quick Access',
  nearbyClinicLink: 'Nearby Clinics',
  nearbyClinicSub: 'Find clinics & pharmacies',
  myOrdersLink: 'My Orders',
  myOrdersSub: 'Track your orders',
  myShopLink: 'My Shop',
  myShopSub: 'Manage inventory & orders',
  settings: 'Settings',
  changeLanguage: 'Change Language',
  currentlyLabel: 'Currently:',
  signOut: 'Sign Out',
  healthTitle: 'Health Assistant',
  healthSubtitle: 'Ask in your language',
  typeMessage: 'Ask about your health…',
  healthSuggestions: ['Nearby clinics', 'I have fever', 'Stomach pain', 'Nearby pharmacy', 'Headache remedy'],
  summary: 'Summary',
  doctorSummaryTitle: 'Doctor Summary',
  doctorSummaryClose: 'Close',
  emergencyText: '⚠️ Emergency detected — please call 108 immediately',
  nearbyShopsTitle: 'Nearby Shops',
  enterPincode: 'Enter pincode',
  searchButton: 'Search',
  searchingShops: 'Searching shops...',
  noShopsFound: 'No shops found',
  noShopsTryDiff: 'Try a different pincode',
  shopsFound: (n) => `${n} shop${n === 1 ? '' : 's'} found`,
  orderFromShop: 'Order from Shop',
  back: 'Back',
  goHome: 'Go Home',
  welcomeBack: 'Welcome back',
}

const STRINGS_MAP: Record<string, Strings> = { hi, mr, ta, te, kn, bn, gu, en }

export function getStrings(language: string): Strings {
  return STRINGS_MAP[language] ?? en
}
