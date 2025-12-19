import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';
import '../../../../models/CategoryM/categoty_model.dart'; // import your model

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  // ✅ Typed cache list
  List<CategoryModel> categoriesCache = [];

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<FetchCategories>((event, emit) async {
      // 🔹 If we already have cached categories, emit them directly
      if (categoriesCache.isNotEmpty) {
        emit(CategoryLoaded(categoriesCache));
        return;
      }

      emit(CategoryLoading());
      try {
        final categories = await repository.fetchCategories();
        categoriesCache = categories; // ✅ store in typed cache
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });
  }
}
