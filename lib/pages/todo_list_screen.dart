import 'package:flutter/material.dart';

class TodoListScreen extends StatefulWidget {


  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<TodoItem> _todoItems = [];
  final TextEditingController _textController = TextEditingController();

  static const _appBarTitle = 'Minha Lista de Tarefas';
  static const _emptyMessage = 'Nenhuma tarefa ainda.\nToque no + para adicionar!';
  static const _addTaskHint = 'Digite sua tarefa aqui...';
  static const _saveButtonText = 'Salvar';
  static const _cancelButtonText = 'Cancelar';
  static const _addTaskTitle = 'Nova Tarefa';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_appBarTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_todoItems.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _todoItems.length,
      itemBuilder: (context, index) {
        final item = _todoItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Checkbox(
              value: item.isCompleted,
              onChanged: (value) => _toggleTodoItem(index),
            ),
            title: Text(
              item.text,
              style: TextStyle(
                decoration: item.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: item.isCompleted ? Colors.grey : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeTodoItem(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            _emptyMessage,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    _textController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(_addTaskTitle),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: _addTaskHint,
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            maxLines: 3,
            minLines: 1,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(_cancelButtonText),
            ),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text(_saveButtonText),
            ),
          ],
        );
      },
    );
  }

  void _saveTask() {
    final text = _textController.text.trim();

    if (text.isNotEmpty) {
      setState(() {
        _todoItems.add(TodoItem(text: text));
      });
      Navigator.of(context).pop();
    }
  }

  void _toggleTodoItem(int index) {
    setState(() {
      _todoItems[index] = _todoItems[index].copyWith(
        isCompleted: !_todoItems[index].isCompleted,
      );
    });
  }

  void _removeTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
  }
}

class TodoItem {
  final String text;
  final bool isCompleted;

  const TodoItem({
    required this.text,
    this.isCompleted = false,
  });

  TodoItem copyWith({
    String? text,
    bool? isCompleted,
  }) {
    return TodoItem(
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}