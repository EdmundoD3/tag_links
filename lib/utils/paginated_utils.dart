// paginated_utils.dart

class PaginatedParams {
  final int page;
  final int pageSize;
  final Order order;

  const PaginatedParams({
    this.page = 1,
    this.pageSize = 10,
    this.order = Order.updatedDesc,
  });

  int get offset => (page - 1) * pageSize;
  int get limit => pageSize;
}

enum Order { updatedDesc, updatedAsc, createdDesc, createdAsc }

const  _orderSql = {
  Order.updatedDesc: 'updatedAt DESC',
  Order.updatedAsc: 'updatedAt ASC',
  Order.createdDesc: 'createdAt DESC',
  Order.createdAsc: 'createdAt ASC',
};

String orderBySql(Order order) => _orderSql[order]!;
