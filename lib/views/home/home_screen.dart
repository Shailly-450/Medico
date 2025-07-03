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

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.secondary,
                        child:
                            const Icon(Icons.location_on, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.userName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Row(
                              children: [
                                Text(
                                  model.userLocation,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                                const Icon(Icons.keyboard_arrow_down,
                                    color: AppColors.primary),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none,
                                color: Colors.blueGrey),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationScreen(),
                                ),
                              );
                            },
                          ),
                          if (model.unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${model.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
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
                ),

                // Search Bar with lighter border
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/search'),
                    child: AbsorbPointer(
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Search doctor or symptoms',
                          prefixIcon:
                              Icon(Icons.search, color: AppColors.primary),
                          suffixIcon:
                              Icon(Icons.tune, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: AppColors.secondary),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: AppColors.secondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // After the search bar Padding, insert:
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FindHospitalsScreen()),
                        );
                      },
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Find Hospitals on Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                // Categories
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: model.categories.length,
                    itemBuilder: (context, index) {
                      final category = model.categories[index];
                      final isActive =
                          model.selectedCategory == category['name'];
                      return GestureDetector(
                        onTap: () {
                          model.setCategory(category['name']);
                          Navigator.pushNamed(
                            context,
                            '/category',
                            arguments: category['name'],
                          );
                        },
                        child: CategoryCard(
                          icon: category['icon'],
                          title: category['name'],
                          isActive: isActive,
                        ),
                      );
                    },
                  ),
                ),

                // Upcoming Appointments with shadow
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upcoming Appointments (${model.upcomingAppointments.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ScheduleScreen()),
                          );
                        },
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                // Appointment Cards
                if (model.upcomingAppointments.isNotEmpty)
                  SizedBox(
                    height: 210,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: model.upcomingAppointments.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 350,
                          child: AppointmentCard(
                            appointment: model.upcomingAppointments[index],
                          ),
                        );
                      },
                    ),
                  ),

                // Offers & Packages Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Offers & Packages',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const OffersScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Offer Cards
                if (model.offers.isNotEmpty)
                  SizedBox(
                    height: 340,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 16.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: model.offers.length,
                      itemBuilder: (context, index) {
                        return OfferCard(
                          offer: model.offers[index],
                          onTap: () {
                            // Handle offer card tap - could navigate to offer details
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Booking ${model.offers[index].title}...'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                // Find Your Doctor Section with bold text
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Find Your Doctor',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DoctorsScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Specialties Filter with consistent style
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: model.specialties.length,
                    itemBuilder: (context, index) {
                      final specialty = model.specialties[index];
                      final isSelected = model.selectedSpecialty == specialty;
                      final isAll = specialty == 'All';

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            specialty,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : AppColors.primary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          backgroundColor: isSelected
                              ? AppColors.primary
                              : AppColors.secondary,
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color: Colors.transparent,
                          ),
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

                // Doctor Cards
                ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: model.doctors.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
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
                    );
                  },
                ),

                // Find Hospitals/Clinics Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Find Hospitals/Clinics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const HospitalsScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hospital Type Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: model.hospitalTypes.length,
                    itemBuilder: (context, index) {
                      final hospitalType = model.hospitalTypes[index];
                      final isSelected =
                          model.selectedHospitalType == hospitalType;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            hospitalType,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : AppColors.primary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          backgroundColor: isSelected
                              ? AppColors.primary
                              : AppColors.secondary,
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color: Colors.transparent,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              model.setHospitalType(hospitalType);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Cost Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: model.costCategories.length,
                    itemBuilder: (context, index) {
                      final costCategory = model.costCategories[index];
                      final isSelected =
                          model.selectedCostCategory == costCategory;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            costCategory,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : AppColors.primary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          backgroundColor: isSelected
                              ? AppColors.primary
                              : AppColors.secondary,
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color: Colors.transparent,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              model.setCostCategory(costCategory);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Hospital Specialties Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: model.hospitalSpecialties.length,
                    itemBuilder: (context, index) {
                      final specialty = model.hospitalSpecialties[index];
                      final isSelected =
                          model.selectedHospitalSpecialty == specialty;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            specialty,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : AppColors.primary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          backgroundColor: isSelected
                              ? AppColors.primary
                              : AppColors.secondary,
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color: Colors.transparent,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              model.setHospitalSpecialty(specialty);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Hospital Cards
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: model.filteredHospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = model.filteredHospitals[index];
                    return HospitalCard(
                      hospital: hospital,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HospitalDetailScreen(hospital: hospital),
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
                    );
                  },
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FindHospitalsScreen()),
                      );
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Find Hospitals on Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
