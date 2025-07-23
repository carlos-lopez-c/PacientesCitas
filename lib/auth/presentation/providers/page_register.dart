import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageState {
  final int currentPage;

  PageState({
    this.currentPage = 0,
  });

  PageState copyWith({
    int? currentPage,
  }) {
    return PageState(
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PageControllerNotifier extends StateNotifier<PageState> {
  PageControllerNotifier() : super(PageState());

  void nextPage() {
    if (state.currentPage < 2) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page <= 2) {
      state = state.copyWith(currentPage: page);
    }
  }

  void reset() {
    state = PageState();
  }
}

final pageControllerProvider =
    StateNotifierProvider<PageControllerNotifier, PageState>((ref) {
  return PageControllerNotifier();
});
