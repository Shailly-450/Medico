import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/prescription.dart';

class PrescriptionsViewModel extends BaseViewModel {
  List<Prescription> _prescriptions = [];
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  List<Prescription> get prescriptions => _getFilteredPrescriptions();
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  final List<String> _filterOptions = [
    'All',
    'Active',
    'Completed',
    'Expired',
    'Pending',
  ];

  List<String> get filterOptions => _filterOptions;

  @override
  void init() {
    print('DEBUG: PrescriptionsViewModel init called');
    _loadPrescriptions();
  }

  void _loadPrescriptions() {
    print('DEBUG: Loading prescriptions...');
    _setLoading(true);

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _prescriptions = _getMockPrescriptions();
      print('DEBUG: Loaded ${_prescriptions.length} prescriptions');
      _setLoading(false);
      notifyListeners();
    });
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void refreshPrescriptions() {
    _loadPrescriptions();
  }

  List<Prescription> _getFilteredPrescriptions() {
    List<Prescription> filtered = _prescriptions;

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((prescription) {
        switch (_selectedFilter) {
          case 'Active':
            return prescription.status == PrescriptionStatus.active;
          case 'Completed':
            return prescription.status == PrescriptionStatus.completed;
          case 'Expired':
            return prescription.status == PrescriptionStatus.expired;
          case 'Pending':
            return prescription.status == PrescriptionStatus.pending;
          default:
            return true;
        }
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((prescription) {
        return prescription.doctorName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            prescription.diagnosis
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            prescription.medications.any((med) =>
                med.name.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.prescriptionDate.compareTo(a.prescriptionDate));

    return filtered;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color getStatusColor(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.active:
        return Colors.green;
      case PrescriptionStatus.completed:
        return Colors.blue;
      case PrescriptionStatus.expired:
        return Colors.red;
      case PrescriptionStatus.cancelled:
        return Colors.grey;
      case PrescriptionStatus.pending:
        return Colors.orange;
    }
  }

  IconData getStatusIcon(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.active:
        return Icons.check_circle;
      case PrescriptionStatus.completed:
        return Icons.done_all;
      case PrescriptionStatus.expired:
        return Icons.warning;
      case PrescriptionStatus.cancelled:
        return Icons.cancel;
      case PrescriptionStatus.pending:
        return Icons.schedule;
    }
  }

  List<Prescription> _getMockPrescriptions() {
    return [
      Prescription(
        id: '1',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. Sarah Johnson',
        doctorSpecialty: 'Cardiology',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 2)),
        expiryDate: DateTime.now().add(const Duration(days: 28)),
        diagnosis: 'Hypertension',
        status: PrescriptionStatus.active,
        medications: [
          PrescriptionMedication(
            name: 'Amlodipine',
            dosage: '5mg',
            frequency: 'Once daily',
            duration: '30 days',
            instructions: 'Take with food',
            quantity: 30,
            refills: '2',
            isActive: true,
            startDate: DateTime.now().subtract(const Duration(days: 2)),
            endDate: DateTime.now().add(const Duration(days: 28)),
          ),
          PrescriptionMedication(
            name: 'Lisinopril',
            dosage: '10mg',
            frequency: 'Once daily',
            duration: '30 days',
            instructions: 'Take in the morning',
            quantity: 30,
            refills: '2',
            isActive: true,
            startDate: DateTime.now().subtract(const Duration(days: 2)),
            endDate: DateTime.now().add(const Duration(days: 28)),
          ),
        ],
        notes: 'Monitor blood pressure weekly. Follow up in 4 weeks.',
      ),
      Prescription(
        id: '2',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. Michael Chen',
        doctorSpecialty: 'Endocrinology',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 15)),
        expiryDate: DateTime.now().add(const Duration(days: 15)),
        diagnosis: 'Type 2 Diabetes',
        status: PrescriptionStatus.active,
        medications: [
          PrescriptionMedication(
            name: 'Metformin',
            dosage: '500mg',
            frequency: 'Twice daily',
            duration: '30 days',
            instructions: 'Take with meals',
            quantity: 60,
            refills: '3',
            isActive: true,
            startDate: DateTime.now().subtract(const Duration(days: 15)),
            endDate: DateTime.now().add(const Duration(days: 45)),
          ),
        ],
        notes:
            'Monitor blood glucose levels. Low carbohydrate diet recommended.',
      ),
      Prescription(
        id: '3',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. Emily Rodriguez',
        doctorSpecialty: 'Dermatology',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 30)),
        expiryDate: DateTime.now().subtract(const Duration(days: 5)),
        diagnosis: 'Acne vulgaris',
        status: PrescriptionStatus.completed,
        medications: [
          PrescriptionMedication(
            name: 'Tretinoin',
            dosage: '0.025%',
            frequency: 'Once daily at night',
            duration: '60 days',
            instructions: 'Apply to clean, dry skin',
            quantity: 30,
            refills: '1',
            isActive: false,
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            endDate: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ],
        notes: 'Treatment completed successfully. Skin condition improved.',
      ),
      Prescription(
        id: '4',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. James Wilson',
        doctorSpecialty: 'Orthopedics',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 45)),
        expiryDate: DateTime.now().subtract(const Duration(days: 15)),
        diagnosis: 'Lower back pain',
        status: PrescriptionStatus.expired,
        medications: [
          PrescriptionMedication(
            name: 'Ibuprofen',
            dosage: '400mg',
            frequency: 'Every 6 hours as needed',
            duration: '14 days',
            instructions: 'Take with food to avoid stomach upset',
            quantity: 56,
            refills: '0',
            isActive: false,
            startDate: DateTime.now().subtract(const Duration(days: 45)),
            endDate: DateTime.now().subtract(const Duration(days: 15)),
          ),
        ],
        notes: 'Prescription expired. Contact doctor if pain persists.',
      ),
      Prescription(
        id: '5',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. Lisa Thompson',
        doctorSpecialty: 'Psychiatry',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 5)),
        diagnosis: 'Anxiety disorder',
        status: PrescriptionStatus.pending,
        medications: [
          PrescriptionMedication(
            name: 'Sertraline',
            dosage: '50mg',
            frequency: 'Once daily',
            duration: '30 days',
            instructions: 'Take in the morning',
            quantity: 30,
            refills: '2',
            isActive: false,
            startDate: null,
            endDate: null,
          ),
        ],
        notes: 'Awaiting insurance approval. Will be notified when ready.',
      ),
      Prescription(
        id: '6',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. Robert Martinez',
        doctorSpecialty: 'Pulmonology',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 8)),
        expiryDate: DateTime.now().add(const Duration(days: 22)),
        diagnosis: 'Asthma',
        status: PrescriptionStatus.active,
        medications: [
          PrescriptionMedication(
            name: 'Albuterol',
            dosage: '90mcg',
            frequency: '2 puffs every 4-6 hours as needed',
            duration: '30 days',
            instructions: 'Shake well before use. Rinse mouth after inhalation',
            quantity: 1,
            refills: '2',
            isActive: true,
            startDate: DateTime.now().subtract(const Duration(days: 8)),
            endDate: DateTime.now().add(const Duration(days: 22)),
          ),
          PrescriptionMedication(
            name: 'Fluticasone',
            dosage: '250mcg',
            frequency: '2 puffs twice daily',
            duration: '30 days',
            instructions: 'Use regularly, not for acute attacks',
            quantity: 1,
            refills: '2',
            isActive: true,
            startDate: DateTime.now().subtract(const Duration(days: 8)),
            endDate: DateTime.now().add(const Duration(days: 22)),
          ),
        ],
        notes: 'Avoid triggers like dust and smoke. Keep rescue inhaler handy.',
      ),
      Prescription(
        id: '7',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. Jennifer Lee',
        doctorSpecialty: 'Gastroenterology',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 12)),
        expiryDate: DateTime.now().add(const Duration(days: 18)),
        diagnosis: 'Gastroesophageal Reflux Disease (GERD)',
        status: PrescriptionStatus.active,
        medications: [
          PrescriptionMedication(
            name: 'Omeprazole',
            dosage: '20mg',
            frequency: 'Once daily before breakfast',
            duration: '30 days',
            instructions: 'Take on empty stomach 30 minutes before eating',
            quantity: 30,
            refills: '2',
            isActive: true,
            startDate: DateTime.now().subtract(const Duration(days: 12)),
            endDate: DateTime.now().add(const Duration(days: 18)),
          ),
        ],
        notes: 'Avoid spicy foods, caffeine, and lying down after meals.',
      ),
      Prescription(
        id: '8',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. David Kim',
        doctorSpecialty: 'Neurology',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 25)),
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        diagnosis: 'Migraine',
        status: PrescriptionStatus.active,
        medications: [
          PrescriptionMedication(
            name: 'Sumatriptan',
            dosage: '50mg',
            frequency: 'As needed for migraine attacks',
            duration: '30 days',
            instructions:
                'Take at first sign of migraine. Maximum 2 tablets per day',
            quantity: 9,
            refills: '1',
            isActive: true,
            startDate: DateTime.now().subtract(const Duration(days: 25)),
            endDate: DateTime.now().add(const Duration(days: 5)),
          ),
        ],
        notes: 'Keep track of migraine frequency. Avoid known triggers.',
      ),
      Prescription(
        id: '9',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. Amanda Foster',
        doctorSpecialty: 'Rheumatology',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 40)),
        expiryDate: DateTime.now().subtract(const Duration(days: 10)),
        diagnosis: 'Rheumatoid Arthritis',
        status: PrescriptionStatus.completed,
        medications: [
          PrescriptionMedication(
            name: 'Methotrexate',
            dosage: '10mg',
            frequency: 'Once weekly',
            duration: '12 weeks',
            instructions: 'Take on same day each week. Avoid alcohol',
            quantity: 12,
            refills: '0',
            isActive: false,
            startDate: DateTime.now().subtract(const Duration(days: 40)),
            endDate: DateTime.now().subtract(const Duration(days: 10)),
          ),
          PrescriptionMedication(
            name: 'Folic Acid',
            dosage: '5mg',
            frequency: 'Once daily',
            duration: '12 weeks',
            instructions: 'Take daily except on methotrexate day',
            quantity: 84,
            refills: '0',
            isActive: false,
            startDate: DateTime.now().subtract(const Duration(days: 40)),
            endDate: DateTime.now().subtract(const Duration(days: 10)),
          ),
        ],
        notes: 'Treatment course completed. Schedule follow-up for evaluation.',
      ),
      Prescription(
        id: '10',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. Thomas Anderson',
        doctorSpecialty: 'Urology',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 60)),
        expiryDate: DateTime.now().subtract(const Duration(days: 30)),
        diagnosis: 'Urinary Tract Infection',
        status: PrescriptionStatus.completed,
        medications: [
          PrescriptionMedication(
            name: 'Ciprofloxacin',
            dosage: '500mg',
            frequency: 'Twice daily',
            duration: '7 days',
            instructions: 'Take with plenty of water. Complete full course',
            quantity: 14,
            refills: '0',
            isActive: false,
            startDate: DateTime.now().subtract(const Duration(days: 60)),
            endDate: DateTime.now().subtract(const Duration(days: 53)),
          ),
        ],
        notes: 'Antibiotic course completed. Infection resolved.',
      ),
      Prescription(
        id: '11',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. Rachel Green',
        doctorSpecialty: 'Ophthalmology',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 3)),
        expiryDate: DateTime.now().add(const Duration(days: 27)),
        diagnosis: 'Allergic Conjunctivitis',
        status: PrescriptionStatus.active,
        medications: [
          PrescriptionMedication(
            name: 'Olopatadine',
            dosage: '0.1%',
            frequency: '1 drop in each eye twice daily',
            duration: '30 days',
            instructions: 'Wash hands before use. Do not touch dropper tip',
            quantity: 1,
            refills: '1',
            isActive: true,
            startDate: DateTime.now().subtract(const Duration(days: 3)),
            endDate: DateTime.now().add(const Duration(days: 27)),
          ),
        ],
        notes: 'Avoid rubbing eyes. Use cool compresses for relief.',
      ),
      Prescription(
        id: '12',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. Christopher Brown',
        doctorSpecialty: 'Infectious Disease',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 1)),
        diagnosis: 'Seasonal Influenza',
        status: PrescriptionStatus.pending,
        medications: [
          PrescriptionMedication(
            name: 'Oseltamivir',
            dosage: '75mg',
            frequency: 'Twice daily',
            duration: '5 days',
            instructions: 'Take with food to reduce nausea',
            quantity: 10,
            refills: '0',
            isActive: false,
            startDate: null,
            endDate: null,
          ),
        ],
        notes:
            'Prescription pending lab confirmation. Start within 48 hours of symptoms.',
      ),
      Prescription(
        id: '13',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. Maria Garcia',
        doctorSpecialty: 'Hematology',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 20)),
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        diagnosis: 'Iron Deficiency Anemia',
        status: PrescriptionStatus.active,
        medications: [
          PrescriptionMedication(
            name: 'Ferrous Sulfate',
            dosage: '325mg',
            frequency: 'Three times daily',
            duration: '30 days',
            instructions:
                'Take on empty stomach with vitamin C for better absorption',
            quantity: 90,
            refills: '2',
            isActive: true,
            startDate: DateTime.now().subtract(const Duration(days: 20)),
            endDate: DateTime.now().add(const Duration(days: 10)),
          ),
        ],
        notes:
            'May cause dark stools. Take with orange juice for better absorption.',
      ),
      Prescription(
        id: '14',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. Kevin Patel',
        doctorSpecialty: 'Cardiology',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 35)),
        expiryDate: DateTime.now().subtract(const Duration(days: 5)),
        diagnosis: 'Atrial Fibrillation',
        status: PrescriptionStatus.cancelled,
        medications: [
          PrescriptionMedication(
            name: 'Warfarin',
            dosage: '5mg',
            frequency: 'Once daily',
            duration: '30 days',
            instructions: 'Take at same time daily. Monitor INR regularly',
            quantity: 30,
            refills: '0',
            isActive: false,
            startDate: null,
            endDate: null,
          ),
        ],
        notes:
            'Prescription cancelled due to patient preference for alternative treatment.',
      ),
      Prescription(
        id: '15',
        patientName: 'Abdullah Alshahrani',
        doctorName: 'Dr. Stephanie White',
        doctorSpecialty: 'Endocrinology',
        prescriptionDate: DateTime.now().subtract(const Duration(days: 7)),
        expiryDate: DateTime.now().add(const Duration(days: 23)),
        diagnosis: 'Hypothyroidism',
        status: PrescriptionStatus.active,
        medications: [
          PrescriptionMedication(
            name: 'Levothyroxine',
            dosage: '50mcg',
            frequency: 'Once daily',
            duration: '30 days',
            instructions: 'Take on empty stomach 30 minutes before breakfast',
            quantity: 30,
            refills: '3',
            isActive: true,
            startDate: DateTime.now().subtract(const Duration(days: 7)),
            endDate: DateTime.now().add(const Duration(days: 23)),
          ),
        ],
        notes: 'Take consistently at same time daily. Blood test in 6 weeks.',
      ),
    ];
  }

  int getPrescriptionCount(String filter) {
    if (filter == 'All') {
      return _prescriptions.length;
    }

    return _prescriptions.where((prescription) {
      switch (filter) {
        case 'Active':
          return prescription.status == PrescriptionStatus.active;
        case 'Completed':
          return prescription.status == PrescriptionStatus.completed;
        case 'Expired':
          return prescription.status == PrescriptionStatus.expired;
        case 'Pending':
          return prescription.status == PrescriptionStatus.pending;
        default:
          return true;
      }
    }).length;
  }
}
