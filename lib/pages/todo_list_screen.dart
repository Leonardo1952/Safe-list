import 'package:flutter/material.dart';
import 'package:safe_list/database/database_helper.dart';
import 'package:safe_list/models/todo.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Todo> _todoItems = [];
  final TextEditingController _textController = TextEditingController();

  static const _appBarTitle = 'Minha Lista de Tarefas';
  static const _emptyMessage =
      'Nenhuma tarefa ainda.\nToque no + para adicionar!';
  static const _addTaskHint = 'Digite sua tarefa aqui...';
  static const _saveButtonText = 'Salvar';
  static const _cancelButtonText = 'Cancelar';
  static const _addTaskTitle = 'Nova Tarefa';

  @override
  void initState() {
    super.initState();
    _refreshTodoList();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _refreshTodoList() async {
    final data = await DatabaseHelper.instance.getTodos();
    setState(() {
      _todoItems = data;
    });
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
              value: item.isDone,
              onChanged: (value) => _toggleTodoItem(item),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                decoration: item.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: item.isDone ? Colors.grey : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeTodoItem(item.id!),
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

  void _saveTask() async {
    final text = _textController.text.trim();
    final navigator = Navigator.of(context);

    if (text.isNotEmpty) {
      await DatabaseHelper.instance.add(Todo(title: text));
      _refreshTodoList();
      navigator.pop();
    }
  }

  void _toggleTodoItem(Todo item) async {
    item.isDone = !item.isDone;
    await DatabaseHelper.instance.update(item);
    _refreshTodoList();
  }

  void _removeTodoItem(int id) async {
    await DatabaseHelper.instance.delete(id);
    _refreshTodoList();
  }
}