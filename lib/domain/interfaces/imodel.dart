abstract class IModel<T> {
  Future<String> create(T t);
  Future<bool> delete(T t);
  Future<List<T>> read(int readById);
  Future<bool> update(T t);
}
