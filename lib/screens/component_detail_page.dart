import 'package:flutter/material.dart';
import '../models/mixture_record.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

class ComponentDetailPage extends StatelessWidget {
  final MixtureComponentItem component;

  const ComponentDetailPage({
    super.key,
    required this.component,
  });

  IconData _getComponentIcon(String fieldName) {
    switch (fieldName) {
      case 'cement':
        return Icons.construction;
      case 'blastFurnaceSlag':
        return Icons.layers_outlined;
      case 'flyAsh':
        return Icons.cloud_outlined;
      case 'water':
        return Icons.water_drop_outlined;
      case 'superplasticizer':
        return Icons.science_outlined;
      case 'coarseAggregate':
        return Icons.grain;
      case 'fineAggregate':
        return Icons.scatter_plot_outlined;
      case 'age':
        return Icons.access_time_rounded;
      case 'compressiveStrength':
        return Icons.fitness_center_rounded;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(component.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconBadge(icon: _getComponentIcon(component.fieldName)),
                    const SizedBox(height: 16),
                    Text(
                      component.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Concrete mixture component',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            const AppSectionHeader(title: 'Sample mixture value'),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Measured quantity',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            component.value,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.orangeDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orangeSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        component.unit,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orangeDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(title: 'Role in concrete mixture'),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  component.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(title: 'Standard specifications'),
            const SizedBox(height: 10),
            _buildSpecTile(
              label: 'Standard measurement unit',
              value: component.unit,
              icon: Icons.straighten_rounded,
            ),
            _buildSpecTile(
              label: 'Database field key',
              value: component.fieldName,
              icon: Icons.storage_rounded,
            ),
            _buildSpecTile(
              label: 'Associated material',
              value: 'Cement & Concrete Mixtures',
              icon: Icons.engineering_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.orangeDark),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
