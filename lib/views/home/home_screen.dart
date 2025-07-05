import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/home_view_model.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/category_card.dart';
import 'widgets/appointment_card.dart';
import 'widgets/doctor_card.dart';
import 'widgets/offer_card.dart';
import 'widgets/hospital_card.dart';
import '../shared/profile_header.dart';
import '../notifications/notification_screen.dart';
import 'offers_screen.dart';
import 'hospitals_screen.dart';
import 'hospital_detail_screen.dart';
import 'hospital_map_screen.dart';
import '../doctors/doctors_screen.dart';
import '../doctors/doctor_detail_screen.dart';
import 'package:medico/views/home/hospital_detail_screen.dart';
import 'find_hospitals_screen.dart';
import 'package:medico/views/schedule/schedule_screen.dart';
import '../appointments/all_appointments_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.paleBackground,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar with Profile
              SliverToBoxAdapter(
                child: _buildAppBar(context, model),
              ),
              
              // Search Section
              SliverToBoxAdapter(
                child: _buildSearchSection(context),
              ),
              
              // Quick Actions
              SliverToBoxAdapter(
                child: _buildQuickActions(context, model),
              ),
              
              // Categories Grid
              SliverToBoxAdapter(
                child: _buildCategoriesSection(context, model),
              ),
              
              // Upcoming Appointments
              if (model.upcomingAppointments.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildAppointmentsSection(context, model),
                ),
              
              // Offers Section
              if (model.offers.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildOffersSection(context, model),
                ),
              
              // Doctors Section
              SliverToBoxAdapter(
                child: _buildDoctorsSection(context, model),
              ),
              
              // Hospitals Section
              SliverToBoxAdapter(
                child: _buildHospitalsSection(context, model),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, HomeViewModel model) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                      ),
                const SizedBox(height: 2),
                            Text(
                              model.userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
                            ),
          
          // Location & Notifications
                            Row(
                              children: [
              // Location
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                                Text(
                                  model.userLocation,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                            ),
                          ],
                        ),
                      ),
              
              const SizedBox(width: 12),
              
              // Notifications
                      Stack(
                        children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_none,
                      color: AppColors.primary,
                      size: 20,
                                ),
                          ),
                          if (model.unreadCount > 0)
                            Positioned(
                      right: 0,
                      top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${model.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                            fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
        ],
      ),
    );
  }

    Widget _buildSearchSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Search doctors, hospitals, or symptoms...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                          ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.tune,
                  color: AppColors.primary,
                  size: 16,
                ),
                        ),
            ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildQuickActions(BuildContext context, HomeViewModel model) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
                            Expanded(
                child: _buildQuickActionCard(
                  context,
                  imagePath: 'assets/images/hospital.png',
                  title: 'Find Hospitals',
                  subtitle: 'On Map',
                  color: AppColors.primary,
                  onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                        builder: (_) => const FindHospitalsScreen(),
                      ),
                        );
                      },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  imagePath: 'assets/images/appointment.png',
                  title: 'Book',
                  subtitle: 'Appointment',
                  color: AppColors.accent,
                  onTap: () {
                    Navigator.pushNamed(context, '/schedule');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

    Widget _buildQuickActionCard(
    BuildContext context, {
    required String imagePath,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 6,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, HomeViewModel model) {
    return Container(
      margin: const EdgeInsets.all(10),
                  child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
          Text(
            'Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
                      ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: model.categories.length,
            itemBuilder: (context, index) {
              final category = model.categories[index];
                          final isActive = model.selectedCategory == category['name'];
              
              return _buildCategoryCard(
                context,
                                icon: category['icon'],
                                label: category['name'],
                                isActive: isActive,
                                onTap: () {
                                  model.setCategory(category['name']);
                                  Navigator.pushNamed(
                                    context,
                                    '/category',
                                    arguments: category['name'],
                                  );
                                },
                                  );
                                },
                              ),
        ],
                            ),
                          );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular Avatar with Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive 
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isActive ? Colors.white : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              // Category Name
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.primary : AppColors.textBlack,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildAppointmentsSection(BuildContext context, HomeViewModel model) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                      builder: (context) => AllAppointmentsScreen(),
                    ),
                          );
                        },
                child: Text(
                          'See All',
                          style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
                    ],
                  ),
          const SizedBox(height: 16),
                  SizedBox(
            height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: model.upcomingAppointments.length,
                      itemBuilder: (context, index) {
                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
                            child: AppointmentCard(
                              appointment: model.upcomingAppointments[index],
                          ),
                        );
                      },
                    ),
                  ),
        ],
      ),
    );
  }

  Widget _buildOffersSection(BuildContext context, HomeViewModel model) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                'Special Offers',
                style: TextStyle(
                  fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const OffersScreen(),
                            ),
                          );
                        },
                child: Text(
                          'View All',
                          style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
          const SizedBox(height: 16),
                  SizedBox(
            height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: model.offers.length,
                      itemBuilder: (context, index) {
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  child: OfferCard(
                          offer: model.offers[index],
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                          content: Text('Booking ${model.offers[index].title}...'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                  ),
                        );
                      },
                    ),
                  ),
        ],
      ),
    );
  }

  Widget _buildDoctorsSection(BuildContext context, HomeViewModel model) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                'Top Doctors',
                style: TextStyle(
                  fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DoctorsScreen(),
                            ),
                          );
                        },
                child: Text(
                          'See All',
                          style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
          const SizedBox(height: 16),

          // Specialties Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: model.specialties.length,
                    itemBuilder: (context, index) {
                      final specialty = model.specialties[index];
                      final isSelected = model.selectedSpecialty == specialty;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            specialty,
                            style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                    backgroundColor: AppColors.secondary.withOpacity(0.2),
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                    side: BorderSide.none,
                          onSelected: (selected) {
                            if (selected) {
                              model.setSpecialty(specialty);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
          
          const SizedBox(height: 16),

                // Doctor Cards
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: model.doctors.length,
                  itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DoctorDetailScreen(
                              doctor: model.doctors[index],
                            ),
                          ),
                        );
                      },
                      child: DoctorCard(
                        doctor: model.doctors[index],
                  ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

    Widget _buildHospitalsSection(BuildContext context, HomeViewModel model) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                'Hospitals & Clinics',
                style: TextStyle(
                  fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const HospitalsScreen(),
                            ),
                          );
                        },
                child: Text(
                          'View All',
                          style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
          const SizedBox(height: 16),
          
          // Dropdown-like Filters
          Row(
            children: [
              // Hospital Type Dropdown
              Expanded(
                child: _buildFilterDropdown(
                  context,
                  title: 'Type',
                  selectedValue: model.selectedHospitalType,
                  items: model.hospitalTypes,
                  onChanged: (value) {
                    if (value != null) {
                      model.setHospitalType(value);
                            }
                          },
                        ),
              ),
              const SizedBox(width: 10),
              // Cost Category Dropdown
              Expanded(
                child: _buildFilterDropdown(
                  context,
                  title: 'Cost',
                  selectedValue: model.selectedCostCategory,
                  items: model.costCategories,
                  onChanged: (value) {
                    if (value != null) {
                      model.setCostCategory(value);
                            }
                          },
                        ),
              ),
            ],
                ),

          const SizedBox(height: 16),

                // Hospital Cards
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: model.filteredHospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = model.filteredHospitals[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: HospitalCard(
                      hospital: hospital,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                        builder: (context) => HospitalDetailScreen(hospital: hospital),
                          ),
                        );
                      },
                      onMapTap: (selectedHospital) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HospitalMapScreen(
                              selectedHospital: selectedHospital,
                              hospitals: model.filteredHospitals,
                            ),
                          ),
                    );
                  },
                ),
              );
            },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context, {
    required String title,
    required String selectedValue,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
                ),
              ],
            ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          labelText: title,
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        style: TextStyle(
          color: AppColors.textBlack,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.primary,
          size: 18,
        ),
        dropdownColor: Colors.white,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                color: item == selectedValue ? AppColors.primary : AppColors.textBlack,
                fontWeight: item == selectedValue ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
