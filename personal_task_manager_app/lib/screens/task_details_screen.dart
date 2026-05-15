import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Color _priorityColor() {
    switch (_task.priority) {
      case 'High':
        return Colors.red.shade600;
      case 'Medium':
        return Colors.orange.shade700;
      case 'Low':
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  IconData _categoryIcon() {
    switch (_task.category) {
      case 'School':
        return Icons.school;
      case 'Personal':
        return Icons.person;
      case 'Health':
        return Icons.favorite;
      case 'Work':
        return Icons.work;
      case 'Finance':
        return Icons.attach_money;
      default:
        return Icons.label;
    }
  }

  bool get _isOverdue {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return !_task.isCompleted && _task.dueDate.isBefore(today);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      widget.onDelete();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor();
    final overdue = _isOverdue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.pop(context);
              widget.onEdit();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & description card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _categoryIcon(),
                          color: const Color(0xFFE91E8C),
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _task.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              decoration: _task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: _task.isCompleted
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _task.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Details card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _detailRow(
                      Icons.category,
                      'Category',
                      _task.category,
                      Colors.purple.shade400,
                    ),
                    const Divider(height: 20),
                    _detailRow(
                      Icons.flag,
                      'Priority',
                      _task.priority,
                      priorityColor,
                    ),
                    const Divider(height: 20),
                    _detailRow(
                      Icons.calendar_today,
                      'Due Date',
                      _formatDate(_task.dueDate),
                      overdue ? Colors.red : Colors.grey.shade700,
                    ),
                    if (overdue) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'This task is overdue',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Divider(height: 20),
                    _detailRow(
                      _task.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      'Status',
                      _task.isCompleted ? 'Completed' : 'Pending',
                      _task.isCompleted ? Colors.green : Colors.orange.shade700,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Toggle complete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _task.isCompleted
                      ? Colors.orange.shade700
                      : const Color(0xFFE91E8C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  _task.isCompleted ? Icons.undo : Icons.check_circle_outline,
                ),
                label: Text(
                  _task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
                  style: const TextStyle(fontSize: 15),
                ),
                onPressed: () {
                  setState(() => _task.isCompleted = !_task.isCompleted);
                },
              ),
            ),
            const SizedBox(height: 12),
            // Delete button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Task', style: TextStyle(fontSize: 15)),
                onPressed: _confirmDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
