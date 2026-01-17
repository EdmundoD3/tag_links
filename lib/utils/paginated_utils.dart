// paginated_utils.dart

abstract class PaginatedParams {
  final int page;
  final int pageSize;

  const PaginatedParams({
    this.page = 1,
    this.pageSize = 10,
  });

  int get offset => (page - 1) * pageSize;
  int get limit => pageSize;

  String get orderSql;
}

class PaginatedByDate extends PaginatedParams {
  final OrderDate order;

  static const Map<OrderDate, String> _orderSqlDate = {
    OrderDate.updatedDesc: 'updatedAt DESC',
    OrderDate.updatedAsc: 'updatedAt ASC',
    OrderDate.createdDesc: 'createdAt DESC',
    OrderDate.createdAsc: 'createdAt ASC',
  };

  const PaginatedByDate({
    super.page = 1,
    super.pageSize = 10,
    this.order = OrderDate.updatedDesc,
  });

  @override
  String get orderSql =>
      _orderSqlDate[order] ?? 'updatedAt DESC';
  PaginatedByDate copyWith({
    int? page,
    int? pageSize,
    OrderDate? order,
  }) {
    return PaginatedByDate(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      order: order ?? this.order,
    );
  }
}

class PaginatedByUsage extends PaginatedParams {
  final OrderByUsage order;

  static const Map<OrderByUsage, String> _orderSqlUsage = {
    OrderByUsage.usageDesc: 'usageCount DESC',
    OrderByUsage.usageAsc: 'usageCount ASC',
  };

  const PaginatedByUsage({
    super.page = 1,
    super.pageSize = 10,
    this.order = OrderByUsage.usageDesc,
  });

  @override
  String get orderSql =>
      _orderSqlUsage[order] ?? 'usageCount DESC';
}

enum OrderByUsage { usageDesc, usageAsc }

enum OrderDate { updatedDesc, updatedAsc, createdDesc, createdAsc }
