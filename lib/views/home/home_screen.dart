import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/home_view_model.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/category_card.dart';
import 'widgets/appointment_card.dart';
import 'widgets/doctor_card.dart';

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
                      IconButton(
                        icon: Stack(
                          children: [
                            const Icon(Icons.notifications_none,
                                color: Colors.blueGrey),
                            if (model.unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
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
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/notifications'),
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
                              Icon(Icons.tune, color: AppColors.secondary),
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
                        onTap: () => model.setCategory(category['name']),
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
                        onPressed: () {},
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
                        onPressed: () {},
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
                    return DoctorCard(
                      doctor: model.doctors[index],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
