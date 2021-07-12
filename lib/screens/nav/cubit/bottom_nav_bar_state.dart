part of 'bottom_nav_bar_cubit.dart';

class BottomNavBarState extends Equatable {
  final BottomNavItem selectedItem;
  const BottomNavBarState({@required this.selectedItem});

  List<Object> get props => [selectedItem];
}
