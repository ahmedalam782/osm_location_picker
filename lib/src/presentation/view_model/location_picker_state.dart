import 'package:latlong2/latlong.dart';

enum StatusState { initial, loading, success, failure, moreLoading }

class BaseState<T> {
  final StatusState state;
  final T? data;
  final Exception? exception;

  const BaseState({required this.state, this.data, this.exception});

  BaseState<T> copyWith({StatusState? state, T? data, Exception? exception}) {
    return BaseState<T>(
      state: state ?? this.state,
      data: data ?? this.data,
      exception: exception ?? this.exception,
    );
  }
}

class LocationPickerState {
  /// The position used for markers and the initial map center.
  final LatLng? position;
  final BaseState<String> addressData;

  /// Whether the map is currently being dragged.
  final bool isMoving;

  /// Whether the map should animate to [position] (initial load or my location).
  final bool shouldMoveToPosition;

  /// The current visual center of the map.
  final LatLng? currentCenter;

  const LocationPickerState({
    this.position,
    this.addressData = const BaseState(state: StatusState.initial),
    this.isMoving = false,
    this.shouldMoveToPosition = true,
    this.currentCenter,
  });

  LocationPickerState copyWith({
    LatLng? position,
    BaseState<String>? addressData,
    bool? isMoving,
    bool? shouldMoveToPosition,
    LatLng? currentCenter,
  }) {
    return LocationPickerState(
      position: position ?? this.position,
      addressData: addressData ?? this.addressData,
      isMoving: isMoving ?? this.isMoving,
      shouldMoveToPosition: shouldMoveToPosition ?? this.shouldMoveToPosition,
      currentCenter: currentCenter ?? this.currentCenter,
    );
  }
}
