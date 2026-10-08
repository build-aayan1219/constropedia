import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/mixture_record.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

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
        return 'Mixture Record $n';
      }
    }
    return docId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cement mixture data'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Sort Records',
            icon: const Icon(Icons.sort_rounded),
            onSelected: _onSortChanged,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'default',
                child: Text('Default Order'),
              ),
              PopupMenuItem(
                value: 'strength_desc',
                child: Text('Highest Strength'),
              ),
              PopupMenuItem(
                value: 'age_desc',
                child: Text('Longest Curing Age'),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingState(message: 'Loading mixture records...');
    }

    if (_errorMessage != null) {
      return AppErrorState(
        title: 'Unable to load mixture data',
        details: _errorMessage!,
        onRetry: _loadInitialRecords,
      );
    }

    if (_records.isEmpty) {
      return const AppEmptyState(
        icon: Icons.science_outlined,
        title: 'No mixture data available',
        message: 'There are no mixture component records loaded yet.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _records.length + 1,
      itemBuilder: (context, index) {
        if (index < _records.length) {
          final record = _records[index];
          return _buildRecordCard(record);
        }

        // Footer / Load More item
        if (_hasMore) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: _isLoadingMore
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _loadMoreRecords,
                      icon: const Icon(Icons.expand_more_rounded),
                      label: const Text('Load more records'),
                    ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'Showing all ${_records.length} records loaded',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordCard(ConcreteMixtureRecord record) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: const IconBadge(icon: Icons.science_rounded),
            title: Text(
              _formatRecordTitle(record.id),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.orangeSoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${record.age} days',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${record.compressiveStrength.toStringAsFixed(2)} MPa',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orangeDark,
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
                    const Divider(),
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
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              '${comp.value} ${comp.unit}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
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
      ),
    );
  }
}
