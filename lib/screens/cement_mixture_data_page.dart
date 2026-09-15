import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/mixture_record.dart';
import '../services/firestore_service.dart';

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
        title: const Text(
          'Cement Mixture Data',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 55,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadInitialRecords,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.science_outlined,
                size: 65,
                color: Colors.orange.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                'No mixture data available.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'There are no mixture component records loaded yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
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
                      label: const Text('Load More Records'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'Showing all ${_records.length} records loaded',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordCard(ConcreteMixtureRecord record) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.science_rounded,
              color: Colors.orange.shade900,
              size: 24,
            ),
          ),
          title: Text(
            _formatRecordTitle(record.id),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${record.age} days',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${record.compressiveStrength.toStringAsFixed(2)} MPa',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
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
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          Text(
                            '${comp.value} ${comp.unit}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
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
