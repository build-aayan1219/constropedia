import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/mixture_record.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/primary_button.dart';

class CementMixtureDataPage extends StatefulWidget {
  final String articleId;

  const CementMixtureDataPage({
    super.key,
    this.articleId = 'cement',
  });

  @override
  State<CementMixtureDataPage> createState() => _CementMixtureDataPageState();
}

class _CementMixtureDataPageState extends State<CementMixtureDataPage> {
  final FirestoreService _firestoreService = FirestoreService();

  final List<ConcreteMixtureRecord> _records = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  String _sortBy = 'default'; // 'default', 'strength_desc', 'age_desc'

  @override
  void initState() {
    super.initState();
    _loadInitialRecords();
  }

  Future<void> _loadInitialRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _records.clear();
      _lastDocument = null;
      _hasMore = true;
    });

    try {
      final snap = await _firestoreService.getMixtureDataSnapshot(
        articleId: widget.articleId,
        limit: 20,
      );

      if (snap.docs.isNotEmpty) {
        _lastDocument = snap.docs.last;
        final list = snap.docs
            .map((doc) => ConcreteMixtureRecord.fromMap(doc.id, doc.data()))
            .toList();

        _applySortToList(list);

        setState(() {
          _records.addAll(list);
          _hasMore = snap.docs.length >= 20;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading mixture records: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load mixture data. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreRecords() async {
    if (_isLoadingMore || !_hasMore || _lastDocument == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final snap = await _firestoreService.getMixtureDataSnapshot(
        articleId: widget.articleId,
        limit: 20,
        startAfter: _lastDocument,
      );

      if (snap.docs.isNotEmpty) {
        _lastDocument = snap.docs.last;
        final list = snap.docs
            .map((doc) => ConcreteMixtureRecord.fromMap(doc.id, doc.data()))
            .toList();

        _applySortToList(list);

        setState(() {
          _records.addAll(list);
          _hasMore = snap.docs.length >= 20;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _hasMore = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading more records: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load more records. Please check your connection.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _applySortToList(List<ConcreteMixtureRecord> list) {
    if (_sortBy == 'strength_desc') {
      list.sort((a, b) => b.compressiveStrength.compareTo(a.compressiveStrength));
    } else if (_sortBy == 'age_desc') {
      list.sort((a, b) => b.age.compareTo(a.age));
    }
  }

  void _onSortChanged(String? newSort) {
    if (newSort == null || newSort == _sortBy) return;
    setState(() {
      _sortBy = newSort;
      _applySortToList(_records);
    });
  }

  String _formatRecordTitle(String docId) {
    final numStr = docId.replaceAll(RegExp(r'[^0-9]'), '');
    if (numStr.isNotEmpty) {
      final n = int.tryParse(numStr);
      if (n != null) {
        return 'Mixture Batch #$n';
      }
    }
    return docId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Concrete Mix Dataset',
        subtitle: 'Laboratory Mix Formulations & Compressive Testing',
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Sort Records',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.sort_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
            onSelected: _onSortChanged,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    Icon(Icons.list_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Default Order'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'strength_desc',
                child: Row(
                  children: [
                    Icon(Icons.fitness_center_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Highest Strength (MPa)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'age_desc',
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Longest Curing Age (Days)'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2.8,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 14),
            Text(
              'Loading laboratory records...',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return ErrorStateWidget(
        message: _errorMessage!,
        onRetry: _loadInitialRecords,
      );
    }

    if (_records.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.science_outlined,
        title: 'No Mixture Data Loaded',
        message: 'No mixture records found in the laboratory dataset.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      itemCount: _records.length + 1,
      itemBuilder: (context, index) {
        if (index < _records.length) {
          final record = _records[index];
          return _buildRecordCard(record);
        }

        // Footer / Load More
        if (_hasMore) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: PrimaryButton(
                label: 'Load More Records',
                icon: Icons.expand_more_rounded,
                isOutlined: true,
                isLoading: _isLoadingMore,
                width: 220,
                height: 46,
                onPressed: _loadMoreRecords,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'All ${_records.length} laboratory test records loaded',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordCard(ConcreteMixtureRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryBorder.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(
              Icons.science_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          title: Text(
            _formatRecordTitle(record.id),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '${record.age} Days Cured',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${record.compressiveStrength.toStringAsFixed(2)} MPa',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 6),
                  ...record.components.map(
                    (comp) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              comp.name,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${comp.value} ${comp.unit}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
