import 'package:wire/utils/wire_command_with_wire_data.dart';
import 'package:wire_example_shared/todo/const/data_keys.dart';
import 'package:wire_example_shared/todo/data/vo/todo_vo.dart';

class ClearCompletedTodosCommand extends WireCommandWithWireData<void> {
  ClearCompletedTodosCommand();

  @override
  Future<void> execute() async {
    final todoIdsList = await get<List<String>>(DataKeys.LIST_OF_IDS);
    final List<String> listOfIdsToRemove = [];
    await Future.forEach(todoIdsList, (String todoId) async {
      final todoVO = await get<TodoVO>(todoId);
      final completed = todoVO.completed;
      if (completed) {
        print('> \t\t completed: $todoId');
        listOfIdsToRemove.add(todoId);
      }
    });

    await Future.forEach(listOfIdsToRemove, (String todoId) async {
      todoIdsList.remove(todoId);
      await remove(todoId);
    });
    update(DataKeys.LIST_OF_IDS, data: todoIdsList);

    print('> ClearCompletedTodosCommand -> executed: length = ${todoIdsList.length}');
  }
}
