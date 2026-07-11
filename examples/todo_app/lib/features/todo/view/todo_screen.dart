import 'package:flutter/material.dart';
import 'package:capsa/capsa.dart';
import '../screen_model/todo_screen_model.dart';

class TodoScreen extends StatelessWidget {
  final TodoScreenModel model;
  final TextEditingController _controller = TextEditingController();

  TodoScreen({super.key, required this.model}) {
    model.attach();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flura Todos'),
        actions: [
          XReactive(() {
            if (model.todos().any((t) => t.completed)) {
              return IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: () => model.clearCompleted(),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'What needs to be done?',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      model.addTodo(value);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    model.addTodo(_controller.text);
                    _controller.clear();
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: XReactive(() {
              if (model.isLoading()) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = model.todos();
              if (items.isEmpty) {
                return const Center(child: Text('No todos yet'));
              }

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final todo = items[index];
                  return ListTile(
                    leading: Checkbox(
                      value: todo.completed,
                      onChanged: (_) => model.toggleTodo(todo),
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => model.deleteTodo(todo.id),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
