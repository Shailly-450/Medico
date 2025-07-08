import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/ai_symptom_chat.dart';
import 'package:uuid/uuid.dart';

class AISymptomService {
  // Singleton instance
  static final AISymptomService _instance = AISymptomService._internal();
  factory AISymptomService() => _instance;
  AISymptomService._internal();

  final Uuid _uuid = const Uuid();
  final List<AIConsultationSession> _sessions = [];
  final Map<String, List<String>> _symptomDatabase = {};
  final StreamController<AIChatMessage> _messageStream =
      StreamController.broadcast();

  // Getters
  List<AIConsultationSession> get sessions => List.unmodifiable(_sessions);
  Stream<AIChatMessage> get messageStream => _messageStream.stream;

  // Initialize the service with mock symptom database
  void initialize() {
    _initializeSymptomDatabase();
  }

  void _initializeSymptomDatabase() {
    _symptomDatabase.addAll({
      'headache': [
        'tension headache',
        'migraine',
        'cluster headache',
        'sinus headache',
        'dehydration',
      ],
      'fever': [
        'viral infection',
        'bacterial infection',
        'flu',
        'common cold',
        'food poisoning',
      ],
      'cough': [
        'common cold',
        'bronchitis',
        'pneumonia',
        'allergies',
        'asthma',
      ],
      'nausea': [
        'food poisoning',
        'gastroenteritis',
        'motion sickness',
        'pregnancy',
        'medication side effect',
      ],
      'chest pain': [
        'muscle strain',
        'acid reflux',
        'anxiety',
        'heart condition',
        'respiratory infection',
      ],
      'fatigue': [
        'lack of sleep',
        'anemia',
        'depression',
        'thyroid disorder',
        'viral infection',
      ],
    });
  }

  // Create a new consultation session
  Future<AIConsultationSession> startConsultation(String patientId) async {
    final sessionId = _uuid.v4();
    final session = AIConsultationSession(
      id: sessionId,
      patientId: patientId,
      startTime: DateTime.now(),
      messages: [
        AIChatMessage(
          id: _uuid.v4(),
          content:
              "Hello! I'm your AI health assistant. I can help analyze your symptoms and provide preliminary health insights. Please describe what symptoms you're experiencing today.",
          type: MessageType.ai,
          timestamp: DateTime.now(),
        ),
      ],
    );

    _sessions.add(session);
    return session;
  }

  // Send a message in the consultation
  Future<AIChatMessage> sendMessage(String sessionId, String content) async {
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) {
      throw Exception('Session not found');
    }

    final session = _sessions[sessionIndex];
    final userMessage = AIChatMessage(
      id: _uuid.v4(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    // Add user message
    final updatedMessages = List<AIChatMessage>.from(session.messages)
      ..add(userMessage);

    // Generate AI response
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate thinking time
    final aiResponse = await _generateAIResponse(content, session);

    final finalMessages = List<AIChatMessage>.from(updatedMessages)
      ..add(aiResponse);

    // Update session with new prediction if available
    AIPrediction? updatedPrediction = session.currentPrediction;
    if (aiResponse.metadata?['prediction'] != null) {
      updatedPrediction =
          AIPrediction.fromJson(aiResponse.metadata!['prediction']);
    }

    _sessions[sessionIndex] = session.copyWith(
      messages: finalMessages,
      currentPrediction: updatedPrediction,
    );

    // Emit messages to stream
    _messageStream.add(userMessage);
    _messageStream.add(aiResponse);

    return aiResponse;
  }

  // Generate AI response based on user input
  Future<AIChatMessage> _generateAIResponse(
      String userInput, AIConsultationSession session) async {
    final symptoms = _extractSymptoms(userInput);
    final severity = _assessSeverity(userInput);

    // Check if this is a follow-up question about health topics
    final followUpResponse = _handleFollowUpQuestion(userInput, session);
    if (followUpResponse != null) {
      return AIChatMessage(
        id: _uuid.v4(),
        content: followUpResponse,
        type: MessageType.ai,
        timestamp: DateTime.now(),
        metadata: null,
      );
    }

    final prediction = _generatePrediction(symptoms, severity);
    String response = _generateResponseText(symptoms, severity, prediction);

    // Add metadata with prediction if available
    Map<String, dynamic>? metadata;
    if (prediction != null) {
      metadata = {
        'prediction': prediction.toJson(),
      };
    }

    return AIChatMessage(
      id: _uuid.v4(),
      content: response,
      type: MessageType.ai,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
  }

  // Handle follow-up questions about health topics
  String? _handleFollowUpQuestion(
      String userInput, AIConsultationSession session) {
    final inputLower = userInput.toLowerCase();

    // Get the most recent AI diagnosis from the session
    String? lastDiagnosis;
    for (var message in session.messages.reversed) {
      if (message.type == MessageType.ai &&
          message.metadata?['prediction'] != null) {
        final prediction =
            AIPrediction.fromJson(message.metadata!['prediction']);
        lastDiagnosis = prediction.diagnosis;
        break;
      }
    }

    // Handle questions about causes
    if (_isQuestionAbout(inputLower, [
      'cause',
      'causes',
      'why',
      'reason',
      'trigger',
      'source',
      'origin',
      'root cause'
    ])) {
      if (lastDiagnosis != null) {
        return _getConditionCauses(lastDiagnosis);
      }
      return _getGeneralCausesResponse(inputLower);
    }

    // Handle questions about duration/timeline
    if (_isQuestionAbout(inputLower, [
      'long',
      'duration',
      'time',
      'last',
      'heal',
      'recover',
      'persist',
      'continue',
      'end',
      'finish',
      'resolve'
    ])) {
      if (lastDiagnosis != null) {
        return _getConditionDuration(lastDiagnosis);
      }
      return "Recovery time varies depending on the specific condition, severity, and individual factors. Most minor conditions resolve within a few days to weeks with proper care.";
    }

    // Handle questions about treatment
    if (_isQuestionAbout(inputLower, [
      'treat',
      'treatment',
      'cure',
      'medicine',
      'medication',
      'help',
      'therapy',
      'remedy',
      'solution',
      'fix',
      'heal',
      'manage'
    ])) {
      if (lastDiagnosis != null) {
        return _getConditionTreatment(lastDiagnosis);
      }
      return _getGeneralTreatmentResponse(inputLower);
    }

    // Handle questions about prevention
    if (_isQuestionAbout(inputLower, [
      'prevent',
      'prevention',
      'avoid',
      'stop',
      'protect',
      'shield',
      'guard',
      'defend',
      'ward off'
    ])) {
      if (lastDiagnosis != null) {
        return _getConditionPrevention(lastDiagnosis);
      }
      return _getGeneralPreventionResponse(inputLower);
    }

    // Handle questions about when to see doctor
    if (_isQuestionAbout(inputLower, [
      'doctor',
      'hospital',
      'emergency',
      'urgent',
      'serious',
      'medical',
      'physician',
      'clinic',
      'healthcare',
      'professional'
    ])) {
      return _getWhenToSeeDoctorResponse(lastDiagnosis);
    }

    // Handle questions about complications
    if (_isQuestionAbout(inputLower, [
      'complication',
      'dangerous',
      'risk',
      'worse',
      'bad',
      'harmful',
      'threat',
      'danger',
      'problem',
      'side effect'
    ])) {
      if (lastDiagnosis != null) {
        return _getConditionComplications(lastDiagnosis);
      }
      return "While most conditions are manageable, potential complications can occur if symptoms worsen or proper treatment isn't followed. Watch for severe symptoms and consult a healthcare provider if concerned.";
    }

    // Handle questions about symptoms
    if (_isQuestionAbout(inputLower, [
      'symptom',
      'sign',
      'indication',
      'manifestation',
      'presentation',
      'appearance',
      'feeling',
      'sensation'
    ])) {
      if (lastDiagnosis != null) {
        return _getConditionSymptoms(lastDiagnosis);
      }
      return "Symptoms can vary widely depending on the condition. Common symptoms include pain, fever, fatigue, nausea, and changes in appetite or sleep patterns. For specific symptom information, consult with a healthcare provider.";
    }

    // Handle questions about diagnosis
    if (_isQuestionAbout(inputLower, [
      'diagnose',
      'diagnosis',
      'test',
      'examination',
      'check',
      'evaluate',
      'assess',
      'identify',
      'detect'
    ])) {
      if (lastDiagnosis != null) {
        return _getConditionDiagnosis(lastDiagnosis);
      }
      return "Diagnosis typically involves a medical history review, physical examination, and may include laboratory tests, imaging studies, or other diagnostic procedures. Always consult with healthcare professionals for proper diagnosis.";
    }

    // Handle questions about medications
    if (_isQuestionAbout(inputLower, [
      'drug',
      'pill',
      'prescription',
      'over the counter',
      'otc',
      'antibiotic',
      'painkiller',
      'anti-inflammatory'
    ])) {
      if (lastDiagnosis != null) {
        return _getConditionMedication(lastDiagnosis);
      }
      return "Medication recommendations depend on the specific condition, severity, and individual factors. Always consult with healthcare providers for appropriate medication advice and avoid self-medication.";
    }

    // Handle questions about lifestyle
    if (_isQuestionAbout(inputLower, [
      'lifestyle',
      'daily',
      'routine',
      'activity',
      'rest',
      'work',
      'exercise',
      'diet',
      'sleep',
      'stress'
    ])) {
      return _getLifestyleAdvice(lastDiagnosis);
    }

    // Handle questions about age/gender specific concerns
    if (_isQuestionAbout(inputLower, [
      'age',
      'elderly',
      'senior',
      'child',
      'baby',
      'pregnant',
      'women',
      'men',
      'adult',
      'teen'
    ])) {
      return _getAgeGenderSpecificAdvice(inputLower, lastDiagnosis);
    }

    // Handle questions about seasonal/weather effects
    if (_isQuestionAbout(inputLower, [
      'season',
      'weather',
      'cold',
      'hot',
      'humid',
      'dry',
      'winter',
      'summer',
      'climate'
    ])) {
      return _getSeasonalAdvice(lastDiagnosis);
    }

    // Handle questions about contagiousness
    if (_isQuestionAbout(inputLower, [
      'contagious',
      'infectious',
      'spread',
      'transmit',
      'catch',
      'pass on',
      'communicable'
    ])) {
      if (lastDiagnosis != null) {
        return _getConditionContagiousness(lastDiagnosis);
      }
      return "Contagiousness varies by condition. Some conditions spread through direct contact, airborne transmission, or contaminated surfaces. Practice good hygiene and follow medical advice to prevent spread.";
    }

    // Handle questions about chronic vs acute
    if (_isQuestionAbout(inputLower, [
      'chronic',
      'acute',
      'long term',
      'short term',
      'temporary',
      'permanent',
      'recurring'
    ])) {
      return _getChronicAcuteInfo(lastDiagnosis);
    }

    // Handle questions about immunity
    if (_isQuestionAbout(inputLower, [
      'immune',
      'immunity',
      'resistance',
      'susceptible',
      'vulnerable',
      'defense'
    ])) {
      return _getImmunityInfo(lastDiagnosis);
    }

    // Handle questions about mental health
    if (_isQuestionAbout(inputLower, [
      'mental',
      'psychological',
      'emotional',
      'anxiety',
      'depression',
      'stress',
      'mood',
      'mind'
    ])) {
      return _getMentalHealthAdvice(inputLower);
    }

    // Handle questions about nutrition
    if (_isQuestionAbout(inputLower, [
      'nutrition',
      'vitamin',
      'mineral',
      'supplement',
      'food',
      'eating',
      'dietary',
      'nutrient'
    ])) {
      return _getNutritionAdvice(inputLower, lastDiagnosis);
    }

    // Handle questions about alternative medicine
    if (_isQuestionAbout(inputLower, [
      'alternative',
      'natural',
      'herbal',
      'homeopathic',
      'traditional',
      'holistic',
      'complementary'
    ])) {
      return _getAlternativeMedicineAdvice(lastDiagnosis);
    }

    // Handle questions about cost/insurance
    if (_isQuestionAbout(inputLower, [
      'cost',
      'expensive',
      'cheap',
      'insurance',
      'payment',
      'afford',
      'price',
      'financial'
    ])) {
      return _getCostInsuranceInfo();
    }

    // Handle questions about second opinions
    if (_isQuestionAbout(inputLower, [
      'second opinion',
      'another doctor',
      'different doctor',
      'specialist',
      'expert'
    ])) {
      return _getSecondOpinionAdvice();
    }

    // Handle questions about emergency situations
    if (_isQuestionAbout(inputLower, [
      'emergency',
      'urgent',
      'immediate',
      'critical',
      'severe',
      'life threatening',
      'call 911'
    ])) {
      return _getEmergencyAdvice();
    }

    // Handle questions about recovery/rehabilitation
    if (_isQuestionAbout(inputLower, [
      'recovery',
      'rehabilitation',
      'rehab',
      'healing',
      'improvement',
      'progress',
      'better'
    ])) {
      return _getRecoveryAdvice(lastDiagnosis);
    }

    // Handle questions about support groups/resources
    if (_isQuestionAbout(inputLower, [
      'support',
      'group',
      'community',
      'resource',
      'help',
      'assistance',
      'guidance'
    ])) {
      return _getSupportResources(lastDiagnosis);
    }

    // Handle questions about research/studies
    if (_isQuestionAbout(inputLower, [
      'research',
      'study',
      'clinical trial',
      'evidence',
      'scientific',
      'latest',
      'new'
    ])) {
      return _getResearchInfo(lastDiagnosis);
    }

    // Handle general health questions
    if (_isGeneralHealthQuestion(inputLower)) {
      return _handleGeneralHealthQuestion(inputLower);
    }

    return null; // Not a follow-up question, proceed with normal symptom analysis
  }

  // Check if input contains question keywords
  bool _isQuestionAbout(String input, List<String> keywords) {
    return keywords.any((keyword) => input.contains(keyword));
  }

  // Check if it's a general health question
  bool _isGeneralHealthQuestion(String input) {
    final healthKeywords = [
      'health',
      'healthy',
      'diet',
      'exercise',
      'sleep',
      'stress',
      'mental',
      'nutrition',
      'vitamin',
      'supplement',
      'lifestyle',
      'wellness'
    ];
    return healthKeywords.any((keyword) => input.contains(keyword));
  }

  // Get causes for specific conditions
  String _getConditionCauses(String condition) {
    final causes = {
      'Common Cold':
          'Common colds are caused by viral infections, most commonly rhinoviruses. They spread through airborne droplets, contaminated surfaces, and direct contact with infected persons.',
      'Flu':
          'Influenza is caused by influenza viruses (types A, B, C). It spreads through respiratory droplets when infected people cough, sneeze, or talk.',
      'Headache':
          'Headaches can be caused by stress, dehydration, lack of sleep, eye strain, hunger, hormonal changes, certain foods, or underlying conditions.',
      'Fever':
          'Fever is usually caused by infections (viral or bacterial), but can also result from heat exhaustion, medications, or inflammatory conditions.',
      'Stomach Flu':
          'Gastroenteritis is typically caused by viral infections (norovirus, rotavirus), bacterial infections, or contaminated food and water.',
      'Food Poisoning':
          'Food poisoning results from consuming contaminated food or water containing harmful bacteria, viruses, parasites, or toxins.',
      'Allergic Reaction':
          'Allergic reactions occur when the immune system overreacts to normally harmless substances like foods, medications, or environmental allergens.',
    };

    return causes[condition] ??
        'The causes of $condition can vary, but common factors include infections, genetic predisposition, environmental triggers, lifestyle factors, or underlying health conditions. For specific information about your condition, consult with a healthcare provider.';
  }

  // Get duration information for conditions
  String _getConditionDuration(String condition) {
    final durations = {
      'Common Cold':
          'Common colds typically last 7-10 days. Symptoms usually peak around day 3-4 and gradually improve.',
      'Flu':
          'Flu symptoms usually last 3-7 days, but fatigue and weakness can persist for several weeks.',
      'Headache':
          'Tension headaches typically last 30 minutes to several hours. Migraines can last 4-72 hours if untreated.',
      'Fever':
          'Fever duration depends on the underlying cause. Viral fevers usually last 2-3 days, while bacterial infections may require treatment.',
      'Stomach Flu':
          'Viral gastroenteritis typically resolves within 1-3 days, though some symptoms may persist up to a week.',
      'Food Poisoning':
          'Most cases resolve within 2-6 days, depending on the type of contamination and individual response.',
    };

    return durations[condition] ??
        'The duration of $condition varies depending on severity and individual factors. Most acute conditions resolve within a few days to weeks with proper care. If symptoms persist or worsen, consult a healthcare provider.';
  }

  // Get treatment information for conditions
  String _getConditionTreatment(String condition) {
    final treatments = {
      'Common Cold':
          'Rest, stay hydrated, use saline nasal sprays, consider pain relievers for discomfort. Antibiotics are not effective against viral colds.',
      'Flu':
          'Rest, fluids, antiviral medications if started early, pain relievers for symptoms. Annual flu vaccination is the best prevention.',
      'Headache':
          'Rest in quiet, dark room. Apply cold compress. Stay hydrated. Over-the-counter pain relievers may help. Identify and avoid triggers.',
      'Fever':
          'Rest, increase fluid intake, use fever reducers if uncomfortable. Seek medical care if fever is very high or persistent.',
      'Stomach Flu':
          'Rest, clear fluids, BRAT diet (bananas, rice, applesauce, toast), avoid dairy and fatty foods until recovered.',
      'Food Poisoning':
          'Stay hydrated, rest, avoid solid foods initially. Most cases resolve without treatment. Seek care if severe symptoms occur.',
    };

    return treatments[condition] ??
        'Treatment for $condition should be guided by a healthcare provider. General supportive care includes rest, proper hydration, and symptom management. Avoid self-medication without professional guidance.';
  }

  // Get prevention information
  String _getConditionPrevention(String condition) {
    final prevention = {
      'Common Cold':
          'Wash hands frequently, avoid close contact with sick people, don\'t touch face with unwashed hands, maintain good hygiene.',
      'Flu':
          'Get annual flu vaccination, wash hands regularly, avoid crowded places during flu season, maintain healthy lifestyle.',
      'Headache':
          'Maintain regular sleep schedule, stay hydrated, manage stress, avoid known triggers, take regular breaks from screens.',
      'Food Poisoning':
          'Practice food safety: wash hands, cook foods thoroughly, refrigerate promptly, avoid cross-contamination.',
    };

    return prevention[condition] ??
        'Prevention strategies for $condition may include maintaining good hygiene, healthy lifestyle choices, avoiding known triggers, and following medical recommendations. Consult healthcare providers for specific prevention guidelines.';
  }

  // Get complications information
  String _getConditionComplications(String condition) {
    final complications = {
      'Common Cold':
          'Rare complications include sinus infections, ear infections, or worsening of asthma. Most colds resolve without complications.',
      'Flu':
          'Possible complications include pneumonia, bronchitis, sinus infections, or worsening of chronic conditions like asthma.',
      'Headache':
          'Chronic headaches can affect quality of life. Severe headaches may indicate serious underlying conditions requiring medical evaluation.',
    };

    return complications[condition] ??
        'While most cases of $condition resolve without complications, it\'s important to monitor symptoms and seek medical care if they worsen or new concerning symptoms develop.';
  }

  // Handle general health questions
  String _handleGeneralHealthQuestion(String input) {
    if (input.contains('diet') || input.contains('nutrition')) {
      return 'A balanced diet includes fruits, vegetables, whole grains, lean proteins, and healthy fats. Stay hydrated and limit processed foods, excess sugar, and sodium.';
    }
    if (input.contains('exercise')) {
      return 'Regular physical activity is important for health. Aim for at least 150 minutes of moderate exercise weekly, including cardiovascular and strength training activities.';
    }
    if (input.contains('sleep')) {
      return 'Adults should aim for 7-9 hours of quality sleep nightly. Maintain consistent sleep schedule, create relaxing bedtime routine, and avoid screens before bed.';
    }
    if (input.contains('stress')) {
      return 'Manage stress through regular exercise, adequate sleep, healthy diet, relaxation techniques, social support, and professional help when needed.';
    }

    return 'For general health questions, it\'s best to consult with healthcare professionals who can provide personalized advice based on your individual health needs and circumstances.';
  }

  // Get when to see doctor response
  String _getWhenToSeeDoctorResponse(String? condition) {
    if (condition != null) {
      return 'For $condition, see a doctor if symptoms worsen, persist beyond expected timeframe, or if you develop concerning symptoms like difficulty breathing, severe pain, persistent high fever, or signs of dehydration. Trust your instincts - if you\'re worried, seek medical care.';
    }

    return 'See a healthcare provider if you experience severe symptoms, symptoms that worsen or don\'t improve, persistent high fever, difficulty breathing, severe pain, or if you\'re concerned about your condition. When in doubt, it\'s better to seek professional medical advice.';
  }

  // Get general causes response
  String _getGeneralCausesResponse(String input) {
    return 'Many health conditions can have various causes including infections, genetic factors, environmental triggers, lifestyle choices, or underlying health issues. For specific information about your symptoms, it\'s best to consult with a healthcare provider who can evaluate your individual situation.';
  }

  // Get general treatment response
  String _getGeneralTreatmentResponse(String input) {
    return 'Treatment approaches vary depending on the specific condition and individual factors. General supportive care often includes rest, proper hydration, and symptom management. Always consult with healthcare professionals for appropriate treatment recommendations for your specific situation.';
  }

  // Get general prevention response
  String _getGeneralPreventionResponse(String input) {
    return 'Prevention strategies typically include maintaining good hygiene, healthy lifestyle choices, regular exercise, balanced diet, adequate sleep, stress management, and following recommended health screenings and vaccinations.';
  }

  // Get symptoms for specific conditions
  String _getConditionSymptoms(String condition) {
    final symptoms = {
      'Common Cold':
          'Typical symptoms include runny or stuffy nose, sore throat, cough, mild fever, sneezing, and mild body aches. Symptoms usually develop 1-3 days after exposure.',
      'Flu':
          'Symptoms include high fever, severe body aches, fatigue, headache, cough, sore throat, and sometimes nausea. Symptoms come on suddenly and are more severe than a cold.',
      'Headache':
          'Symptoms vary by type. Tension headaches: dull, aching pain around forehead. Migraines: throbbing pain on one side, nausea, sensitivity to light/sound.',
      'Fever':
          'Elevated body temperature (above 100.4°F/38°C), chills, sweating, headache, muscle aches, fatigue, and loss of appetite.',
      'Stomach Flu':
          'Nausea, vomiting, diarrhea, abdominal cramps, fever, and sometimes headache and body aches.',
      'Food Poisoning':
          'Nausea, vomiting, diarrhea, abdominal pain, fever, and sometimes headache and muscle aches.',
      'Allergic Reaction':
          'Sneezing, runny nose, itchy eyes, skin rash, hives, swelling, and in severe cases, difficulty breathing.',
    };

    return symptoms[condition] ??
        'Symptoms of $condition can vary from person to person. Common symptoms may include pain, fever, fatigue, nausea, and changes in normal bodily functions. Consult a healthcare provider for specific symptom information.';
  }

  // Get diagnosis information for conditions
  String _getConditionDiagnosis(String condition) {
    final diagnosis = {
      'Common Cold':
          'Diagnosis is usually based on symptoms and physical examination. No specific tests are typically needed unless complications are suspected.',
      'Flu':
          'Diagnosis may include rapid flu tests, PCR tests, or viral culture. Clinical diagnosis based on symptoms and seasonal patterns is also common.',
      'Headache':
          'Diagnosis involves medical history, physical examination, and may include imaging tests (CT/MRI) to rule out serious causes.',
      'Fever':
          'Diagnosis focuses on finding the underlying cause through medical history, physical examination, and possibly blood tests or cultures.',
      'Stomach Flu':
          'Diagnosis is usually clinical based on symptoms. Stool tests may be done if symptoms are severe or persistent.',
      'Food Poisoning':
          'Diagnosis is typically clinical. Stool cultures may be performed to identify the specific organism in severe cases.',
      'Allergic Reaction':
          'Diagnosis may include skin tests, blood tests for specific antibodies, and elimination diets to identify triggers.',
    };

    return diagnosis[condition] ??
        'Diagnosis of $condition typically involves a medical history review, physical examination, and may include laboratory tests, imaging studies, or other diagnostic procedures. Always consult healthcare professionals for proper diagnosis.';
  }

  // Get medication information for conditions
  String _getConditionMedication(String condition) {
    final medications = {
      'Common Cold':
          'Over-the-counter decongestants, pain relievers, and cough suppressants. No antibiotics are effective against viral colds.',
      'Flu':
          'Antiviral medications (if started early), pain relievers, fever reducers, and rest. Annual flu vaccination is recommended.',
      'Headache':
          'Over-the-counter pain relievers (acetaminophen, ibuprofen), prescription medications for migraines, and preventive medications for chronic cases.',
      'Fever':
          'Fever reducers like acetaminophen or ibuprofen if uncomfortable. Focus on treating the underlying cause.',
      'Stomach Flu':
          'Anti-nausea medications, anti-diarrheal medications (consult doctor), and rehydration solutions.',
      'Food Poisoning':
          'Usually no specific medication needed. Focus on hydration and rest. Anti-diarrheal medications may be used with medical guidance.',
      'Allergic Reaction':
          'Antihistamines, decongestants, and in severe cases, epinephrine for anaphylaxis.',
    };

    return medications[condition] ??
        'Medication recommendations for $condition depend on the specific condition, severity, and individual factors. Always consult with healthcare providers for appropriate medication advice and avoid self-medication.';
  }

  // Get lifestyle advice
  String _getLifestyleAdvice(String? condition) {
    if (condition != null) {
      return 'For $condition, lifestyle modifications may include adequate rest, proper hydration, stress management, regular exercise (as tolerated), and maintaining a balanced diet. Follow your healthcare provider\'s specific recommendations.';
    }

    return 'General healthy lifestyle recommendations include regular exercise, balanced nutrition, adequate sleep (7-9 hours), stress management, avoiding smoking and excessive alcohol, and maintaining regular health check-ups.';
  }

  // Get age/gender specific advice
  String _getAgeGenderSpecificAdvice(String input, String? condition) {
    if (input.contains('elderly') || input.contains('senior')) {
      return 'Elderly individuals may experience different symptoms and may be more susceptible to complications. They often need more careful monitoring and may require adjusted treatment approaches. Consult healthcare providers for age-appropriate care.';
    }
    if (input.contains('child') || input.contains('baby')) {
      return 'Children may have different symptoms and treatment needs. Always consult pediatricians for proper diagnosis and treatment. Children may need different medication dosages and monitoring.';
    }
    if (input.contains('pregnant')) {
      return 'Pregnancy can affect symptoms and treatment options. Many medications may not be safe during pregnancy. Always consult obstetricians for pregnancy-safe treatment recommendations.';
    }
    if (input.contains('women')) {
      return 'Women may experience different symptoms due to hormonal factors. Some conditions are more common in women. Consult healthcare providers for gender-specific considerations.';
    }
    if (input.contains('men')) {
      return 'Men may have different risk factors and symptom presentations for certain conditions. Regular health screenings are important for early detection and prevention.';
    }

    return 'Age and gender can influence how conditions present and respond to treatment. Consult healthcare providers for personalized advice based on your specific demographic factors.';
  }

  // Get seasonal advice
  String _getSeasonalAdvice(String? condition) {
    if (condition != null) {
      return 'Seasonal factors can affect $condition. Some conditions are more common in certain seasons, and weather changes can influence symptoms. Consider seasonal prevention strategies and symptom management approaches.';
    }

    return 'Seasonal changes can affect various health conditions. Winter often brings respiratory infections, while summer may increase heat-related issues. Adapt your health practices to seasonal conditions and maintain preventive measures year-round.';
  }

  // Get contagiousness information
  String _getConditionContagiousness(String condition) {
    final contagiousness = {
      'Common Cold':
          'Highly contagious, spreads through airborne droplets and direct contact. Most contagious in the first 2-3 days of symptoms.',
      'Flu':
          'Very contagious, spreads through respiratory droplets. Contagious from 1 day before symptoms to 5-7 days after.',
      'Headache':
          'Not contagious. Headaches are not transmitted between people.',
      'Fever':
          'Fever itself is not contagious, but the underlying cause may be. Depends on the specific condition causing the fever.',
      'Stomach Flu':
          'Highly contagious, spreads through contaminated food/water and person-to-person contact. Contagious while symptoms persist.',
      'Food Poisoning':
          'Not directly contagious, but the contaminated food can affect multiple people who consume it.',
      'Allergic Reaction':
          'Not contagious. Allergic reactions are individual immune responses to specific triggers.',
    };

    return contagiousness[condition] ??
        'Contagiousness varies by condition. Some conditions spread through direct contact, airborne transmission, or contaminated surfaces. Practice good hygiene and follow medical advice to prevent spread when applicable.';
  }

  // Get chronic vs acute information
  String _getChronicAcuteInfo(String? condition) {
    if (condition != null) {
      return '$condition can be acute (short-term) or chronic (long-term), depending on the specific case and underlying factors. Acute cases typically resolve quickly, while chronic cases may require ongoing management.';
    }

    return 'Acute conditions develop suddenly and are typically short-term, while chronic conditions persist over time and may require long-term management. The classification depends on the specific condition and individual factors.';
  }

  // Get immunity information
  String _getImmunityInfo(String? condition) {
    if (condition != null) {
      return 'Immunity to $condition varies. Some conditions provide temporary immunity after recovery, while others may not provide lasting protection. Vaccination may be available for some conditions to boost immunity.';
    }

    return 'Immunity can be natural (from previous infection) or acquired (from vaccination). The strength and duration of immunity varies by condition. Maintaining a healthy lifestyle supports overall immune function.';
  }

  // Get mental health advice
  String _getMentalHealthAdvice(String input) {
    if (input.contains('anxiety')) {
      return 'Anxiety can manifest as excessive worry, restlessness, difficulty concentrating, and physical symptoms. Management includes therapy, stress reduction techniques, and sometimes medication. Seek professional help for persistent anxiety.';
    }
    if (input.contains('depression')) {
      return 'Depression symptoms include persistent sadness, loss of interest, changes in sleep/appetite, and feelings of hopelessness. Treatment includes therapy, medication, and lifestyle changes. Professional help is essential for depression.';
    }
    if (input.contains('stress')) {
      return 'Stress management includes regular exercise, relaxation techniques, adequate sleep, time management, and seeking support. Chronic stress can affect physical health and should be addressed.';
    }

    return 'Mental health is as important as physical health. Symptoms of mental health conditions can include changes in mood, behavior, thinking, or functioning. Professional mental health support is available and effective.';
  }

  // Get nutrition advice
  String _getNutritionAdvice(String input, String? condition) {
    if (input.contains('vitamin')) {
      return 'Vitamins are essential nutrients. A balanced diet usually provides adequate vitamins, but supplements may be needed in certain situations. Consult healthcare providers before taking supplements.';
    }
    if (input.contains('supplement')) {
      return 'Supplements can support health but should not replace a balanced diet. Some supplements may interact with medications. Always consult healthcare providers before starting supplements.';
    }

    if (condition != null) {
      return 'Nutrition for $condition may include specific dietary recommendations. Some conditions benefit from particular nutrients or dietary modifications. Consult healthcare providers for condition-specific nutrition advice.';
    }

    return 'Good nutrition supports overall health and can help prevent and manage many conditions. Focus on a balanced diet with fruits, vegetables, whole grains, lean proteins, and healthy fats.';
  }

  // Get alternative medicine advice
  String _getAlternativeMedicineAdvice(String? condition) {
    if (condition != null) {
      return 'Alternative medicine approaches for $condition may include herbal remedies, acupuncture, or other complementary therapies. Always discuss alternative treatments with healthcare providers, as they may interact with conventional treatments.';
    }

    return 'Alternative medicine includes various approaches like herbal medicine, acupuncture, and traditional healing methods. While some may be beneficial, always consult healthcare providers before using alternative treatments, especially alongside conventional medicine.';
  }

  // Get cost/insurance information
  String _getCostInsuranceInfo() {
    return 'Healthcare costs vary widely depending on the condition, treatment required, and insurance coverage. Many conditions can be managed cost-effectively with early intervention. Check with your insurance provider about coverage and consider discussing cost concerns with healthcare providers.';
  }

  // Get second opinion advice
  String _getSecondOpinionAdvice() {
    return 'Seeking a second opinion is often a good idea for serious conditions, complex diagnoses, or when you have concerns about your treatment plan. Many healthcare providers encourage second opinions. Specialists may provide additional expertise for specific conditions.';
  }

  // Get emergency advice
  String _getEmergencyAdvice() {
    return 'Seek immediate emergency care for severe symptoms like difficulty breathing, chest pain, severe bleeding, loss of consciousness, or signs of stroke. When in doubt about whether symptoms are an emergency, it\'s better to seek immediate medical attention.';
  }

  // Get recovery advice
  String _getRecoveryAdvice(String? condition) {
    if (condition != null) {
      return 'Recovery from $condition typically involves rest, proper nutrition, hydration, and following medical recommendations. Recovery time varies by individual and condition severity. Monitor progress and consult healthcare providers if recovery is slower than expected.';
    }

    return 'Recovery involves allowing the body time to heal, following medical advice, maintaining good nutrition and hydration, and gradually returning to normal activities. Recovery timelines vary by condition and individual factors.';
  }

  // Get support resources
  String _getSupportResources(String? condition) {
    if (condition != null) {
      return 'Support for $condition may include patient support groups, educational resources, and community organizations. Many conditions have dedicated support networks that provide information, emotional support, and practical advice.';
    }

    return 'Support resources include patient advocacy groups, online communities, educational materials, and healthcare provider networks. These resources can provide information, emotional support, and practical guidance for managing health conditions.';
  }

  // Get research information
  String _getResearchInfo(String? condition) {
    if (condition != null) {
      return 'Ongoing research continues to improve understanding and treatment of $condition. New studies may lead to better diagnostic methods, treatments, or prevention strategies. Stay informed through reliable medical sources and discuss new developments with healthcare providers.';
    }

    return 'Medical research continuously advances our understanding of health conditions and treatments. New studies may provide insights into causes, prevention, and improved treatment approaches. Always discuss new research findings with healthcare providers.';
  }

  // Legacy method - no longer used
  // Generate disease-specific response
  Future<AIChatMessage> _generateDiseaseSpecificResponse(
      String disease, AIConsultationSession session) async {
    final inputLower = session.messages.last.content.toLowerCase();
    String response = '';

    if (inputLower.contains('what causes')) {
      response = _getDiseaseCauses(disease);
    } else if (inputLower.contains('how long')) {
      response = _getDiseaseDuration(disease);
    } else if (inputLower.contains('treatments') ||
        inputLower.contains('treatment')) {
      response = _getDiseaseTreatments(disease);
    } else if (inputLower.contains('prevent')) {
      response = _getDiseasePrevention(disease);
    } else if (inputLower.contains('complications')) {
      response = _getDiseaseComplications(disease);
    } else if (inputLower.contains('when should')) {
      response = _getWhenToSeeDoctor(disease);
    } else if (inputLower.contains('symptoms')) {
      response = _getDiseaseSymptoms(disease);
    } else if (inputLower.contains('risk factors')) {
      response = _getDiseaseRiskFactors(disease);
    } else if (inputLower.contains('diagnosis')) {
      response = _getDiseaseDiagnosis(disease);
    } else if (inputLower.contains('medication')) {
      response = _getDiseaseMedication(disease);
    } else if (inputLower.contains('recovery')) {
      response = _getDiseaseRecovery(disease);
    } else if (inputLower.contains('contagious')) {
      response = _getDiseaseContagious(disease);
    } else {
      response = _getGeneralDiseaseInfo(disease);
    }

    return AIChatMessage(
      id: _uuid.v4(),
      content: response,
      type: MessageType.ai,
      timestamp: DateTime.now(),
      metadata: {
        'disease_info': disease,
        'question_type': 'disease_specific',
      },
    );
  }

  String _getDiseaseCauses(String disease) {
    final causes = {
      'tension headache':
          'Tension headaches are typically caused by:\n• Stress and anxiety\n• Poor posture\n• Eye strain from screen time\n• Lack of sleep\n• Dehydration\n• Muscle tension in neck and shoulders\n• Caffeine withdrawal',
      'migraine':
          'Migraines can be triggered by:\n• Hormonal changes\n• Certain foods (chocolate, cheese, alcohol)\n• Stress and anxiety\n• Bright lights or loud sounds\n• Changes in sleep patterns\n• Weather changes\n• Genetic factors',
      'viral infection':
          'Viral infections are caused by:\n• Direct contact with infected individuals\n• Airborne transmission\n• Contaminated surfaces\n• Weakened immune system\n• Poor hygiene practices\n• Seasonal factors',
      'common cold':
          'The common cold is caused by:\n• Rhinoviruses (most common)\n• Coronavirus\n• Respiratory syncytial virus\n• Direct contact with infected people\n• Touching contaminated surfaces\n• Weakened immune system',
      'food poisoning':
          'Food poisoning is caused by:\n• Bacteria (Salmonella, E. coli)\n• Viruses (Norovirus)\n• Parasites\n• Contaminated food or water\n• Improper food handling\n• Undercooked food',
    };

    return causes[disease] ??
        'The exact causes of $disease can vary. It\'s best to consult with a healthcare provider for a proper diagnosis and understanding of the underlying causes.';
  }

  String _getDiseaseDuration(String disease) {
    final durations = {
      'tension headache':
          'Tension headaches typically last:\n• 30 minutes to several hours\n• Can persist for days in chronic cases\n• Usually resolves with rest and stress management',
      'migraine':
          'Migraine attacks typically last:\n• 4-72 hours if untreated\n• Can be shorter with proper medication\n• May have prodrome and postdrome phases',
      'viral infection':
          'Viral infections typically last:\n• 7-14 days for most cases\n• Can be longer in severe cases\n• Depends on the specific virus and immune response',
      'common cold':
          'The common cold typically lasts:\n• 7-10 days\n• Symptoms peak around day 3-5\n• Can linger for up to 2 weeks',
      'food poisoning':
          'Food poisoning typically lasts:\n• 1-3 days for most cases\n• Can be longer for severe cases\n• Depends on the causative organism',
    };

    return durations[disease] ??
        'The duration of $disease can vary significantly depending on the individual, severity, and treatment. Consult your healthcare provider for personalized information.';
  }

  String _getDiseaseTreatments(String disease) {
    final treatments = {
      'tension headache':
          'Treatment options for tension headaches:\n• Over-the-counter pain relievers (acetaminophen, ibuprofen)\n• Stress management techniques\n• Regular exercise and stretching\n• Proper posture and ergonomics\n• Relaxation techniques (meditation, deep breathing)\n• Prescription medications for chronic cases',
      'migraine':
          'Migraine treatment options:\n• Triptans (prescription medications)\n• Over-the-counter pain relievers\n• Anti-nausea medications\n• Rest in a quiet, dark room\n• Cold or warm compresses\n• Preventive medications for frequent migraines',
      'viral infection':
          'Treatment for viral infections:\n• Rest and adequate sleep\n• Hydration with fluids\n• Over-the-counter symptom relief\n• Fever management\n• Good nutrition\n• Time (most viral infections resolve on their own)',
      'common cold':
          'Cold treatment options:\n• Rest and hydration\n• Over-the-counter decongestants\n• Saline nasal sprays\n• Honey for cough relief\n• Vitamin C and zinc supplements\n• Humidifier use',
      'food poisoning':
          'Food poisoning treatment:\n• Rest and hydration\n• Clear liquids initially\n• Gradual return to normal diet\n• Anti-diarrheal medications (consult doctor)\n• Probiotics\n• Medical attention for severe cases',
    };

    return treatments[disease] ??
        'Treatment for $disease should be discussed with your healthcare provider for personalized recommendations based on your specific condition and medical history.';
  }

  String _getDiseasePrevention(String disease) {
    final prevention = {
      'tension headache':
          'Prevention strategies:\n• Regular stress management\n• Good posture and ergonomics\n• Regular exercise and stretching\n• Adequate sleep\n• Regular eye check-ups\n• Limit screen time\n• Stay hydrated',
      'migraine':
          'Migraine prevention:\n• Identify and avoid triggers\n• Regular sleep schedule\n• Stress management\n• Regular exercise\n• Avoid skipping meals\n• Limit caffeine and alcohol\n• Consider preventive medications',
      'viral infection':
          'Prevention measures:\n• Frequent hand washing\n• Avoid close contact with sick individuals\n• Maintain good hygiene\n• Get adequate sleep\n• Eat a balanced diet\n• Consider vaccinations when available',
      'common cold':
          'Cold prevention:\n• Frequent hand washing\n• Avoid touching face\n• Stay away from sick people\n• Maintain good hygiene\n• Adequate sleep and nutrition\n• Consider vitamin C and zinc supplements',
      'food poisoning':
          'Food safety prevention:\n• Proper food handling and cooking\n• Wash hands before eating\n• Avoid raw or undercooked foods\n• Refrigerate food properly\n• Avoid cross-contamination\n• Choose reputable food sources',
    };

    return prevention[disease] ??
        'Prevention strategies for $disease should be discussed with your healthcare provider for personalized recommendations.';
  }

  String _getDiseaseComplications(String disease) {
    final complications = {
      'tension headache':
          'Potential complications:\n• Chronic daily headaches\n• Medication overuse headaches\n• Impact on quality of life\n• Depression and anxiety\n• Sleep disturbances',
      'migraine':
          'Migraine complications:\n• Chronic migraines\n• Medication overuse headaches\n• Status migrainosus (severe, prolonged attack)\n• Migrainous infarction (rare)\n• Impact on daily activities',
      'viral infection':
          'Possible complications:\n• Secondary bacterial infections\n• Dehydration\n• Worsening of existing conditions\n• Pneumonia (in severe cases)\n• Prolonged recovery',
      'common cold':
          'Cold complications:\n• Sinus infections\n• Ear infections\n• Bronchitis\n• Pneumonia (rare)\n• Exacerbation of asthma',
      'food poisoning':
          'Complications:\n• Dehydration\n• Electrolyte imbalances\n• Kidney problems\n• Reactive arthritis\n• Guillain-Barré syndrome (rare)',
    };

    return complications[disease] ??
        'Complications of $disease can vary. It\'s important to monitor your symptoms and seek medical attention if they worsen or persist.';
  }

  String _getWhenToSeeDoctor(String disease) {
    final whenToSeeDoctor = {
      'tension headache':
          'Seek medical attention if:\n• Headaches become more frequent or severe\n• Headache with fever and stiff neck\n• Headache after head injury\n• Headache with vision changes\n• Headache that doesn\'t respond to treatment',
      'migraine':
          'See a doctor if:\n• Migraines are frequent or severe\n• New or different headache pattern\n• Headache with neurological symptoms\n• Migraine with fever\n• Headache after head injury',
      'viral infection':
          'Seek medical care if:\n• High fever (above 103°F)\n• Difficulty breathing\n• Severe dehydration\n• Symptoms lasting more than 10 days\n• Worsening symptoms',
      'common cold':
          'See a doctor if:\n• Symptoms lasting more than 10 days\n• High fever\n• Severe sinus pain\n• Difficulty breathing\n• Symptoms that improve then worsen',
      'food poisoning':
          'Seek immediate medical attention if:\n• Blood in stool\n• Severe abdominal pain\n• Signs of dehydration\n• High fever\n• Symptoms lasting more than 3 days',
    };

    return whenToSeeDoctor[disease] ??
        'For $disease, consult your healthcare provider if symptoms are severe, persistent, or concerning. Always seek immediate medical attention for emergency symptoms.';
  }

  String _getDiseaseSymptoms(String disease) {
    final symptoms = {
      'tension headache':
          'Common symptoms:\n• Dull, aching head pain\n• Pressure around forehead\n• Tenderness in scalp, neck, and shoulders\n• Mild to moderate pain intensity\n• Pain on both sides of head\n• No nausea or vomiting',
      'migraine':
          'Typical symptoms:\n• Moderate to severe throbbing pain\n• Pain on one side of head\n• Nausea and vomiting\n• Sensitivity to light and sound\n• Aura (visual disturbances)\n• Dizziness',
      'viral infection':
          'Common symptoms:\n• Fever and chills\n• Fatigue and weakness\n• Body aches\n• Cough and sore throat\n• Runny nose\n• Loss of appetite',
      'common cold':
          'Typical symptoms:\n• Runny or stuffy nose\n• Sore throat\n• Cough\n• Mild fever\n• Sneezing\n• Mild body aches',
      'food poisoning':
          'Common symptoms:\n• Nausea and vomiting\n• Diarrhea\n• Abdominal cramps\n• Fever\n• Loss of appetite\n• Fatigue',
    };

    return symptoms[disease] ??
        'Symptoms of $disease can vary from person to person. Consult your healthcare provider for a proper diagnosis.';
  }

  String _getDiseaseRiskFactors(String disease) {
    final riskFactors = {
      'tension headache':
          'Risk factors:\n• Stress and anxiety\n• Poor posture\n• Eye strain\n• Lack of sleep\n• Dehydration\n• Caffeine withdrawal\n• Depression',
      'migraine':
          'Risk factors:\n• Family history\n• Hormonal changes\n• Stress\n• Certain foods and drinks\n• Sleep disturbances\n• Weather changes\n• Medications',
      'viral infection':
          'Risk factors:\n• Weakened immune system\n• Close contact with sick individuals\n• Poor hygiene\n• Seasonal factors\n• Chronic health conditions\n• Age (very young or elderly)',
      'common cold':
          'Risk factors:\n• Weakened immune system\n• Smoking\n• Lack of sleep\n• Stress\n• Seasonal changes\n• Close contact with others',
      'food poisoning':
          'Risk factors:\n• Eating contaminated food\n• Poor food handling\n• Weakened immune system\n• Travel to developing countries\n• Certain medications\n• Age (very young or elderly)',
    };

    return riskFactors[disease] ??
        'Risk factors for $disease can vary. Discuss your specific risk factors with your healthcare provider.';
  }

  String _getDiseaseDiagnosis(String disease) {
    final diagnosis = {
      'tension headache':
          'Diagnosis typically involves:\n• Medical history and symptom review\n• Physical examination\n• Neurological examination\n• Imaging tests (if needed)\n• Ruling out other conditions\n• Headache diary tracking',
      'migraine':
          'Diagnosis includes:\n• Detailed medical history\n• Symptom pattern analysis\n• Neurological examination\n• Imaging tests (CT/MRI)\n• Blood tests (if needed)\n• Headache diary',
      'viral infection':
          'Diagnosis methods:\n• Medical history and symptoms\n• Physical examination\n• Blood tests\n• Viral culture or PCR tests\n• Imaging (if complications suspected)\n• Ruling out bacterial infection',
      'common cold':
          'Diagnosis involves:\n• Symptom assessment\n• Physical examination\n• Ruling out other conditions\n• Usually clinical diagnosis\n• No specific tests needed\n• Monitoring symptom progression',
      'food poisoning':
          'Diagnosis includes:\n• Medical history and symptoms\n• Physical examination\n• Stool culture tests\n• Blood tests\n• Identifying food source\n• Timeline of symptoms',
    };

    return diagnosis[disease] ??
        'Diagnosis of $disease should be performed by a qualified healthcare provider using appropriate medical tests and examinations.';
  }

  String _getDiseaseMedication(String disease) {
    final medication = {
      'tension headache':
          'Medication options:\n• Over-the-counter pain relievers\n• Acetaminophen\n• Ibuprofen\n• Aspirin\n• Prescription muscle relaxants\n• Antidepressants (for chronic cases)\n• Anti-anxiety medications',
      'migraine':
          'Medication treatments:\n• Triptans (sumatriptan, rizatriptan)\n• NSAIDs\n• Anti-nausea medications\n• Preventive medications\n• Beta-blockers\n• Antidepressants\n• Anti-seizure medications',
      'viral infection':
          'Medication options:\n• Symptom relief medications\n• Fever reducers\n• Decongestants\n• Cough suppressants\n• Antiviral medications (for specific viruses)\n• Supportive care medications',
      'common cold':
          'Medication options:\n• Decongestants\n• Cough suppressants\n• Pain relievers\n• Saline nasal sprays\n• Zinc supplements\n• Vitamin C\n• Honey for cough',
      'food poisoning':
          'Medication options:\n• Anti-diarrheal medications\n• Anti-nausea medications\n• Pain relievers\n• Probiotics\n• Rehydration solutions\n• Antibiotics (if bacterial)',
    };

    return medication[disease] ??
        'Medication for $disease should be prescribed by your healthcare provider based on your specific condition and medical history.';
  }

  String _getDiseaseRecovery(String disease) {
    final recovery = {
      'tension headache':
          'Recovery typically involves:\n• Rest and relaxation\n• Stress management\n• Proper posture\n• Regular exercise\n• Adequate sleep\n• Hydration\n• Time for symptoms to resolve',
      'migraine':
          'Recovery process:\n• Rest in quiet, dark environment\n• Hydration\n• Gradual return to normal activities\n• Postdrome phase management\n• Preventive measures for future attacks\n• Medication as prescribed',
      'viral infection':
          'Recovery includes:\n• Rest and adequate sleep\n• Hydration\n• Good nutrition\n• Gradual return to activities\n• Monitoring for complications\n• Time for immune system to fight virus',
      'common cold':
          'Recovery process:\n• Rest and hydration\n• Symptom management\n• Gradual return to normal activities\n• Good nutrition\n• Time for natural resolution\n• Prevention of spread to others',
      'food poisoning':
          'Recovery involves:\n• Rest and hydration\n• Gradual return to normal diet\n• Monitoring for complications\n• Good hygiene practices\n• Time for digestive system to heal\n• Prevention of future episodes',
    };

    return recovery[disease] ??
        'Recovery from $disease varies by individual. Follow your healthcare provider\'s recommendations for optimal recovery.';
  }

  String _getDiseaseContagious(String disease) {
    final contagious = {
      'tension headache':
          'Tension headaches are not contagious. They are caused by stress, muscle tension, and other non-infectious factors.',
      'migraine':
          'Migraines are not contagious. They are neurological conditions that are not spread from person to person.',
      'viral infection':
          'Viral infections are typically contagious:\n• Through direct contact\n• Airborne transmission\n• Contaminated surfaces\n• Duration varies by virus\n• Take precautions to prevent spread',
      'common cold':
          'The common cold is contagious:\n• Spread through respiratory droplets\n• Contagious 1-2 days before symptoms\n• Remains contagious for 7-10 days\n• Take precautions to prevent spread',
      'food poisoning':
          'Food poisoning is not contagious between people, but:\n• Caused by contaminated food\n• Can affect multiple people who ate same food\n• Good hygiene prevents spread\n• Focus on food safety',
    };

    return contagious[disease] ??
        'The contagiousness of $disease varies. Consult your healthcare provider for specific information about transmission and prevention.';
  }

  String _getGeneralDiseaseInfo(String disease) {
    return 'I can provide information about $disease including causes, symptoms, treatments, prevention, and when to see a doctor. What specific aspect would you like to know more about?';
  }

  // Extract symptoms from user input using simple keyword matching
  List<String> _extractSymptoms(String input) {
    final inputLower = input.toLowerCase();
    final foundSymptoms = <String>[];

    // Check for predefined symptoms first
    for (final symptom in _symptomDatabase.keys) {
      if (inputLower.contains(symptom) ||
          inputLower.contains('${symptom}s') ||
          inputLower.contains('${symptom}ing')) {
        foundSymptoms.add(symptom);
      }
    }

    // Additional keyword matching for common variations
    final symptomKeywords = {
      'head': 'headache',
      'sick': 'nausea',
      'tired': 'fatigue',
      'hot': 'fever',
      'temperature': 'fever',
      'throat': 'cough',
      'breathing': 'cough',
      'stomach': 'nausea',
      'dizzy': 'dizziness',
      'vomit': 'nausea',
      'throw up': 'nausea',
      'pain': 'pain',
      'ache': 'pain',
      'hurt': 'pain',
      'swelling': 'inflammation',
      'red': 'inflammation',
      'itchy': 'itching',
      'rash': 'skin condition',
      'bleeding': 'bleeding',
      'numb': 'numbness',
      'tingling': 'numbness',
      'weak': 'weakness',
      'trembling': 'tremor',
      'shaking': 'tremor',
      'confused': 'confusion',
      'memory': 'memory issues',
      'sleep': 'sleep problems',
      'insomnia': 'sleep problems',
      'appetite': 'appetite changes',
      'weight': 'weight changes',
      'mood': 'mood changes',
      'anxiety': 'anxiety',
      'depression': 'depression',
      'heart': 'heart issues',
      'chest': 'chest issues',
      'lung': 'respiratory issues',
      'kidney': 'kidney issues',
      'liver': 'liver issues',
      'bladder': 'urinary issues',
      'urination': 'urinary issues',
      'bowel': 'digestive issues',
      'diarrhea': 'digestive issues',
      'constipation': 'digestive issues',
      'gas': 'digestive issues',
      'bloating': 'digestive issues',
      'vision': 'vision problems',
      'eye': 'eye problems',
      'ear': 'ear problems',
      'hearing': 'hearing problems',
      'nose': 'nasal problems',
      'smell': 'smell problems',
      'taste': 'taste problems',
      'mouth': 'oral problems',
      'tooth': 'dental problems',
      'gum': 'dental problems',
      'throat': 'throat problems',
      'voice': 'voice problems',
      'swallow': 'swallowing problems',
      'joint': 'joint problems',
      'muscle': 'muscle problems',
      'bone': 'bone problems',
      'skin': 'skin problems',
      'hair': 'hair problems',
      'nail': 'nail problems',
    };

    for (final entry in symptomKeywords.entries) {
      if (inputLower.contains(entry.key) &&
          !foundSymptoms.contains(entry.value)) {
        foundSymptoms.add(entry.value);
      }
    }

    return foundSymptoms;
  }

  // Assess symptom severity from user input
  SymptomSeverity _assessSeverity(String input) {
    final inputLower = input.toLowerCase();

    if (inputLower.contains('severe') ||
        inputLower.contains('terrible') ||
        inputLower.contains('worst') ||
        inputLower.contains('unbearable') ||
        inputLower.contains('emergency') ||
        inputLower.contains('can\'t')) {
      return SymptomSeverity.severe;
    }

    if (inputLower.contains('moderate') ||
        inputLower.contains('bad') ||
        inputLower.contains('worse') ||
        inputLower.contains('concerning') ||
        inputLower.contains('difficult')) {
      return SymptomSeverity.moderate;
    }

    if (inputLower.contains('mild') ||
        inputLower.contains('slight') ||
        inputLower.contains('little') ||
        inputLower.contains('minor')) {
      return SymptomSeverity.mild;
    }

    return SymptomSeverity.mild; // Default to mild
  }

  // Generate prediction based on symptoms and severity
  AIPrediction? _generatePrediction(
      List<String> symptoms, SymptomSeverity severity) {
    if (symptoms.isEmpty) return null;

    final random = Random();
    final primarySymptom = symptoms.first;
    final possibleDiagnoses =
        _symptomDatabase[primarySymptom] ?? ['General condition'];
    final diagnosis =
        possibleDiagnoses[random.nextInt(possibleDiagnoses.length)];

    // Determine confidence based on symptom clarity and severity
    PredictionConfidence confidence;
    if (symptoms.length >= 3) {
      confidence = PredictionConfidence.high;
    } else if (symptoms.length == 2) {
      confidence = PredictionConfidence.medium;
    } else {
      confidence = PredictionConfidence.low;
    }

    // Generate recommendations
    final recommendations = _generateRecommendations(symptoms, severity);
    final warningFlags = _generateWarningFlags(symptoms, severity);

    return AIPrediction(
      id: _uuid.v4(),
      diagnosis: diagnosis,
      description: _getConditionDescription(diagnosis),
      confidence: confidence,
      recommendedActions: recommendations,
      warningFlags: warningFlags,
      requiresImmediateAttention: severity == SymptomSeverity.severe,
      specialty: _getSpecialty(symptoms),
      createdAt: DateTime.now(),
    );
  }

  // Generate response text
  String _generateResponseText(List<String> symptoms, SymptomSeverity severity,
      AIPrediction? prediction) {
    if (symptoms.isEmpty) {
      return "I understand you're not feeling well. Could you please describe your specific symptoms? For example, do you have pain, fever, nausea, or any other discomfort?";
    }

    String response = "Based on your symptoms (${symptoms.join(', ')}), ";

    if (prediction != null) {
      response +=
          "I believe you might be experiencing ${prediction.diagnosis}. ";
      response += "${prediction.description}\n\n";

      if (prediction.recommendedActions.isNotEmpty) {
        response += "Recommendations:\n";
        for (int i = 0; i < prediction.recommendedActions.length; i++) {
          response += "${i + 1}. ${prediction.recommendedActions[i]}\n";
        }
      }

      if (prediction.warningFlags.isNotEmpty) {
        response += "\n⚠️ Warning signs to watch for:\n";
        for (final warning in prediction.warningFlags) {
          response += "• $warning\n";
        }
      }

      if (prediction.requiresImmediateAttention) {
        response +=
            "\n🚨 This appears to be a serious condition. Please seek immediate medical attention.";
      } else {
        response +=
            "\nConsider scheduling an appointment with a ${prediction.specialty} specialist if symptoms persist or worsen.";
      }
    }

    response +=
        "\n\nIs there anything else you'd like to tell me about your symptoms?";
    return response;
  }

  List<String> _generateRecommendations(
      List<String> symptoms, SymptomSeverity severity) {
    final recommendations = <String>[];

    for (final symptom in symptoms) {
      switch (symptom) {
        case 'headache':
          recommendations.addAll([
            'Stay hydrated by drinking plenty of water',
            'Rest in a quiet, dark room',
            'Apply a cold compress to your forehead',
          ]);
          break;
        case 'fever':
          recommendations.addAll([
            'Get plenty of rest',
            'Stay hydrated with fluids',
            'Monitor your temperature regularly',
          ]);
          break;
        case 'cough':
          recommendations.addAll([
            'Stay hydrated to thin mucus',
            'Use a humidifier or breathe steam',
            'Avoid irritants like smoke',
          ]);
          break;
        case 'nausea':
          recommendations.addAll([
            'Eat small, frequent meals',
            'Avoid spicy or fatty foods',
            'Try ginger tea or crackers',
          ]);
          break;
      }
    }

    if (severity == SymptomSeverity.severe) {
      recommendations.insert(0, 'Seek immediate medical attention');
    }

    return recommendations.take(5).toList(); // Limit to 5 recommendations
  }

  List<String> _generateWarningFlags(
      List<String> symptoms, SymptomSeverity severity) {
    final warnings = <String>[];

    for (final symptom in symptoms) {
      switch (symptom) {
        case 'headache':
          warnings.addAll([
            'Sudden, severe headache unlike any before',
            'Headache with fever and stiff neck',
            'Headache with vision changes',
          ]);
          break;
        case 'fever':
          warnings.addAll([
            'Temperature above 103°F (39.4°C)',
            'Fever lasting more than 3 days',
            'Difficulty breathing with fever',
          ]);
          break;
        case 'chest pain':
          warnings.addAll([
            'Crushing chest pain',
            'Pain spreading to arm or jaw',
            'Shortness of breath with chest pain',
          ]);
          break;
      }
    }

    return warnings.take(3).toList(); // Limit to 3 warnings
  }

  String _getConditionDescription(String diagnosis) {
    final descriptions = {
      'tension headache':
          'A common type of headache often caused by stress, muscle tension, or poor posture.',
      'migraine':
          'A neurological condition that causes severe headaches, often with nausea and light sensitivity.',
      'viral infection':
          'An infection caused by a virus, typically resolving on its own with rest and supportive care.',
      'common cold':
          'A mild viral infection of the upper respiratory tract with symptoms like runny nose and cough.',
      'food poisoning':
          'Illness caused by consuming contaminated food, typically causing nausea and digestive issues.',
    };

    return descriptions[diagnosis] ??
        'A medical condition that may require professional evaluation.';
  }

  String _getSpecialty(List<String> symptoms) {
    if (symptoms.contains('chest pain')) return 'Cardiologist';
    if (symptoms.contains('headache')) return 'Neurologist';
    if (symptoms.contains('cough')) return 'Pulmonologist';
    if (symptoms.contains('nausea')) return 'Gastroenterologist';
    return 'General Practitioner';
  }

  // End consultation session
  Future<void> endConsultation(String sessionId) async {
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex != -1) {
      _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
        endTime: DateTime.now(),
        isActive: false,
      );
    }
  }

  // Get session by ID
  AIConsultationSession? getSession(String sessionId) {
    try {
      return _sessions.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  // Get sessions by patient ID
  List<AIConsultationSession> getSessionsByPatient(String patientId) {
    return _sessions.where((s) => s.patientId == patientId).toList();
  }

  // Clear all sessions (for testing)
  void clearSessions() {
    _sessions.clear();
  }

  // Dispose resources
  void dispose() {
    _messageStream.close();
  }
}
