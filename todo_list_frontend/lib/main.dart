import 'package:flutter/material.dart';

void main() {
  runApp(const TodoListApp());
}

// PUBLIC_INTERFACE
class TodoListApp extends StatelessWidget {
  /// The root widget for the To-Do List Flutter app
  const TodoListApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define custom color scheme
    const Color primaryColor = Color(0xFFc3cfda);
    const Color secondaryColor = Color(0xFF424242);
    const Color accentColor = Color(0xFFff0537);
    const Color scaffoldBg = Color(0xFF181818);

    final ThemeData darkMinimalTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBg,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: accentColor,
        onPrimary: scaffoldBg,
        onSecondary: primaryColor,
        surface: secondaryColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 1.2,
        ),
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        splashColor: primaryColor,
        elevation: 3,
        shape: CircleBorder(),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
            color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w400, fontSize: 18),
        bodyMedium: TextStyle(
            color: Colors.white70, fontWeight: FontWeight.w300, fontSize: 16),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStatePropertyAll(primaryColor),
        checkColor: MaterialStatePropertyAll(scaffoldBg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      cardColor: secondaryColor,
      dividerColor: Colors.grey[800],
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: accentColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        hintStyle: TextStyle(
          color: primaryColor.withOpacity(0.7),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: secondaryColor,
        contentTextStyle:
            TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: darkMinimalTheme,
      home: const TodoListScreen(),
    );
  }
}

// Data model for a task
class Task {
  String title;
  bool completed;
  DateTime createdAt;

  Task({
    required this.title,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Copy helper for immutability
  Task copyWith({String? title, bool? completed}) {
    return Task(
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt,
    );
  }
}

// --------------------------------------------
// Main To-Do List Screen & State Management
// --------------------------------------------

// PUBLIC_INTERFACE
class TodoListScreen extends StatefulWidget {
  /// The main screen displaying a list of tasks and primary interactions
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Task> _tasks = [];

  void _addTask(String taskTitle) {
    setState(() {
      _tasks.insert(
        0,
        Task(title: taskTitle),
      );
    });
  }

  void _editTask(int index, String newTitle) {
    setState(() {
      _tasks[index] = _tasks[index].copyWith(title: newTitle);
    });
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index] = _tasks[index]
          .copyWith(completed: !_tasks[index].completed);
    });
  }

  void _deleteTask(int index) {
    final removedTask = _tasks[index];
    setState(() {
      _tasks.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              setState(() {
                _tasks.insert(index, removedTask);
              });
            }),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _TaskDialog(
          title: 'New Task',
          confirmLabel: 'Add',
          onConfirm: (String value) {
            if (value.trim().isNotEmpty) {
              _addTask(value.trim());
            }
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showEditTaskDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return _TaskDialog(
          title: 'Edit Task',
          confirmLabel: 'Save',
          initialText: _tasks[index].title,
          onConfirm: (String value) {
            if (value.trim().isNotEmpty) {
              _editTask(index, value.trim());
            }
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // For a minimalistic app bar and body padding.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: _tasks.isEmpty
            ? const _EmptyStateWidget()
            : ListView.separated(
                itemCount: _tasks.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Dismissible(
                    key: ValueKey(task.createdAt.millisecondsSinceEpoch),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Theme.of(context).colorScheme.error,
                      padding: const EdgeInsets.only(right: 28),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) => _deleteTask(index),
                    child: _TaskListTile(
                      task: task,
                      onToggle: () => _toggleTask(index),
                      onEdit: () => _showEditTaskDialog(index),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add new task',
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}

// -----------------
// Task List Item UI
// -----------------

class _TaskListTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _TaskListTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.error;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Checkbox(
          value: task.completed,
          onChanged: (_) => onToggle(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: GestureDetector(
          onTap: onEdit,
          child: Text(
            task.title,
            style: TextStyle(
              color: task.completed
                  ? Colors.white38
                  : Theme.of(context).textTheme.bodyLarge?.color,
              decoration: task.completed
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              fontSize: 18,
              fontWeight:
                  task.completed ? FontWeight.w400 : FontWeight.bold,
              letterSpacing: 0.65,
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit_note_rounded, color: accentColor, size: 26),
          tooltip: 'Edit task',
          onPressed: onEdit,
        ),
      ),
    );
  }
}

// ----------------------
// Task Add/Edit Dialog UI
// ----------------------

class _TaskDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final String? initialText;
  final void Function(String value) onConfirm;

  const _TaskDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    this.initialText,
    required this.onConfirm,
  });

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onConfirm(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: Theme.of(context).dialogTheme.shape,
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.title,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 18),
              TextFormField(
                controller: _controller,
                style: const TextStyle(fontSize: 18, color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter task...',
                ),
                autofocus: true,
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(widget.confirmLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------
// Empty State UI
// --------------

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note_rounded,
                size: 80, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 20),
            Text(
              'No tasks yet!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Add tasks using the '+' button below.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
