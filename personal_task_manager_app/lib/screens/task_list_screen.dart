import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import 'task_details_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> _tasks = [
    Task(
      title: 'Complete Flutter Exercise',
      description: 'Build the personal task manager app for the Mobile App Development course.',
      category: 'School',
      priority: 'High',
      dueDate: DateTime.now().add(const Duration(days: 3)),
    ),
    Task(
      title: 'Morning Run',
      description: '5km run before breakfast to stay active and healthy.',
      category: 'Health',
      priority: 'Medium',
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    Task(
      title: 'Review Week 10 Notes',
      description: 'Go through all lecture slides and summarize the key points from Week 10.',
      category: 'School',
      priority: 'Low',
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  String _filter = 'All';
  String _sortBy = 'Due Date';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<Task> get _displayedTasks {
    List<Task> result = List.from(_tasks);

    if (_filter == 'Pending') {
      result = result.where((t) => !t.isCompleted).toList();
    } else if (_filter == 'Completed') {
      result = result.where((t) => t.isCompleted).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_sortBy == 'Due Date') {
      result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (_sortBy == 'Priority') {
      const order = {'High': 0, 'Medium': 1, 'Low': 2};
      result.sort(
        (a, b) => (order[a.priority] ?? 3).compareTo(order[b.priority] ?? 3),
      );
    }

    return result;
  }

  int get _completedCount => _tasks.where((t) => t.isCompleted).length;
  int get _pendingCount => _tasks.where((t) => !t.isCompleted).length;

  void _deleteTask(Task task) => setState(() => _tasks.remove(task));

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Tasks'),
        content: const Text(
          'Are you sure? This will permanently delete all your tasks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
    if (confirmed == true) setState(() => _tasks.clear());
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Sort Tasks By',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            RadioListTile<String>(
              title: const Text('Due Date (Earliest First)'),
              value: 'Due Date',
              groupValue: _sortBy,
              activeColor: const Color(0xFFE91E8C),
              onChanged: (val) {
                setState(() => _sortBy = val!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('Priority (High to Low)'),
              value: 'Priority',
              groupValue: _sortBy,
              activeColor: const Color(0xFFE91E8C),
              onChanged: (val) {
                setState(() => _sortBy = val!);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showTaskSheet({Task? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String category = existing?.category ?? 'School';
    String priority = existing?.priority ?? 'Medium';
    DateTime? dueDate = existing?.dueDate;
    bool dateError = false;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          existing == null ? 'New Task' : 'Edit Task',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: _inputDec('Title', Icons.title),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Title cannot be empty' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: _inputDec('Description', Icons.description),
                    maxLines: 2,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Description cannot be empty' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: _inputDec('Category', Icons.category),
                    items: ['School', 'Personal', 'Health', 'Work', 'Finance']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setSheet(() => category = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: priority,
                    decoration: _inputDec('Priority', Icons.flag),
                    items: ['Low', 'Medium', 'High']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setSheet(() => priority = v!),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: dueDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setSheet(() {
                          dueDate = picked;
                          dateError = false;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: dateError ? Colors.red : Colors.grey.shade400,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: dateError ? Colors.red : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            dueDate == null
                                ? 'Pick Due Date *'
                                : 'Due: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                            style: TextStyle(
                              fontSize: 15,
                              color: dueDate == null
                                  ? (dateError ? Colors.red : Colors.grey.shade600)
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (dateError)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, left: 12),
                      child: Text(
                        'Please pick a due date',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E8C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        final valid = formKey.currentState!.validate();
                        if (dueDate == null) setSheet(() => dateError = true);
                        if (!valid || dueDate == null) return;

                        setState(() {
                          if (existing == null) {
                            _tasks.add(Task(
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              category: category,
                              priority: priority,
                              dueDate: dueDate!,
                            ));
                          } else {
                            existing.title = titleCtrl.text.trim();
                            existing.description = descCtrl.text.trim();
                            existing.category = category;
                            existing.priority = priority;
                            existing.dueDate = dueDate!;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        existing == null ? 'Add Task' : 'Save Changes',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayed = _displayedTasks;
    final total = _tasks.length;
    final completed = _completedCount;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : const Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortSheet,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E8C).withValues(alpha: 0.06),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statChip('Total', total, const Color(0xFFE91E8C)),
                    _statChip('Done', completed, Colors.green.shade600),
                    _statChip('Pending', _pendingCount, Colors.orange.shade700),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.pink.shade100,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFE91E8C),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}% completed',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          // Filter buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: ['All', 'Pending', 'Completed'].map((f) {
                final selected = _filter == f;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selected
                            ? const Color(0xFFE91E8C)
                            : Colors.grey.shade100,
                        foregroundColor:
                            selected ? Colors.white : Colors.grey.shade700,
                        elevation: selected ? 2 : 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => setState(() => _filter = f),
                      child: Text(
                        f,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Task list
          Expanded(
            child: displayed.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: displayed.length,
                    itemBuilder: (ctx, i) {
                      final task = displayed[i];
                      return TaskCard(
                        task: task,
                        onDelete: () => _deleteTask(task),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskDetailsScreen(
                                task: task,
                                onDelete: () => _deleteTask(task),
                                onEdit: () => _showTaskSheet(existing: task),
                              ),
                            ),
                          );
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        onPressed: () => _showTaskSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist_rounded, size: 72, color: Colors.pink.shade100),
          const SizedBox(height: 16),
          Text(
            _tasks.isEmpty
                ? 'No tasks yet!\nTap + to add your first task.'
                : 'No tasks match your current filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade400,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
