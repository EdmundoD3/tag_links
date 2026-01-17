import 'package:flutter_riverpod/legacy.dart';
import 'package:tag_links/utils/paginated_utils.dart';

final _basePaginated = PaginatedByDate();

final paginationProvider =
    StateProvider<PaginatedByDate>((ref) => _basePaginated);
