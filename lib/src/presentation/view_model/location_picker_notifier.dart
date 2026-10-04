import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'location_picker_state.dart';
import '../../domain/address_lookup.dart';
import '../../domain/device_location.dart';
import '../../domain/network_status.dart';
import '../../utils/location_picker_failure.dart';
import '../location_picker_strings.dart';

class LocationPickerNotifier extends ValueNotifier<LocationPickerState> {
  final LatLng fallbackLatLng;
  final LocationPickerStrings strings;
  final AddressLookup _addressLookup;
  final DeviceLocation _deviceLocation;
  final NetworkStatus _networkStatus;
  late LocationPickerState _state;
  bool _disposed = false;

  LocationPickerNotifier({
    LatLng? initialLatLng,
    String? initialAddress,
    this.fallbackLatLng = const LatLng(33.3152, 44.3661),
    required this.strings,
    required AddressLookup addressLookup,
    required DeviceLocation deviceLocation,
    required NetworkStatus networkStatus,
  }) : _addressLookup = addressLookup,
       _deviceLocation = deviceLocation,
       _networkStatus = networkStatus,
       super(
         LocationPickerState(
           position: initialLatLng,
           currentCenter: initialLatLng ?? fallbackLatLng,
           addressData: BaseState(
             state:
                 (initialLatLng != null && initialAddress != null)
                     ? StatusState.success
                     : StatusState.initial,
             data: initialAddress,
           ),
         ),
       ) {
    _state = super.value;
  }

  @override
  LocationPickerState get value => _state;

  void _emit(LocationPickerState next) {
    if (_disposed) return;
    final previous = _state;
    _state = next;
    final shouldNotify =
        previous.addressData.state != next.addressData.state ||
        previous.addressData.data != next.addressData.data ||
        previous.addressData.exception != next.addressData.exception ||
        previous.position != next.position ||
        previous.currentCenter != next.currentCenter ||
        previous.isMoving != next.isMoving ||
        previous.shouldMoveToPosition != next.shouldMoveToPosition;
    if (!shouldNotify) return;
    super.value = next;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> getCurrentLocation({LatLng? position}) async {
    // If position is provided, check the cache first to avoid showing loading spinner
    if (position != null) {
      final cachedAddress = _addressLookup.cachedAddress(position);

      if (cachedAddress != null) {
        _emit(
          value.copyWith(
            position: position,
            currentCenter: position,
            shouldMoveToPosition: true,
            isMoving: false,
            addressData: BaseState(
              state: StatusState.success,
              data: cachedAddress,
            ),
          ),
        );
        return;
      }

      _emit(
        value.copyWith(
          position: position,
          currentCenter: position,
          shouldMoveToPosition: true,
          isMoving: false,
          addressData: const BaseState(state: StatusState.loading),
        ),
      );
      getAddressFromLatLng(position);
      return;
    }

    _emit(
      value.copyWith(
        addressData: const BaseState(state: StatusState.loading),
        shouldMoveToPosition: false,
        isMoving: false,
      ),
    );

    try {
      final latLng = await _deviceLocation.currentLocation(
        serviceDisabledMessage: strings.serviceDisabled,
        permissionDeniedMessage: strings.permissionDenied,
        permissionPermanentlyDeniedMessage: strings.permissionPermanentlyDenied,
        fetchFailedMessage: strings.locationFetchFailed,
      );

      // Check cache first to avoid flashing loading state
      final cachedAddress = _addressLookup.cachedAddress(latLng);

      if (cachedAddress != null) {
        _emit(
          value.copyWith(
            position: latLng,
            currentCenter: latLng,
            shouldMoveToPosition: true,
            addressData: BaseState(
              state: StatusState.success,
              data: cachedAddress,
            ),
          ),
        );
        return;
      }

      _emit(
        value.copyWith(
          position: latLng,
          currentCenter: latLng,
          shouldMoveToPosition: true,
          addressData: value.addressData.copyWith(state: StatusState.loading),
        ),
      );

      getAddressFromLatLng(latLng);
    } catch (error) {
      final fallbackPosition =
          value.currentCenter ?? value.position ?? fallbackLatLng;

      // Automatically fallback to manual selection mode centered at the fallback position
      getAddressFromLatLng(fallbackPosition);
    }
  }

  void onCameraMove(LatLng position) {
    _emit(value.copyWith(currentCenter: position, isMoving: true));
  }

  void onCameraIdle() {
    if (value.isMoving && value.currentCenter != null) {
      _emit(value.copyWith(isMoving: false));

      // If we already have or are loading the address for the target position,
      // and the camera stopped close to it (same cache key), do not trigger another fetch.
      if (value.position != null) {
        final targetKey = addressCacheKey(value.position!);
        final currentKey = addressCacheKey(value.currentCenter!);
        if (targetKey == currentKey &&
            (value.addressData.state == StatusState.success ||
                value.addressData.state == StatusState.loading)) {
          return;
        }
      }

      getAddressFromLatLng(value.currentCenter!);
    }
  }

  void updateShouldMoveToPosition(bool shouldMove) {
    _emit(value.copyWith(shouldMoveToPosition: shouldMove));
  }

  Future<void> getAddressFromLatLng(LatLng position) async {
    // Check if the address is already in the cache first to avoid showing the loader and network check
    final cachedAddress = _addressLookup.cachedAddress(position);

    if (cachedAddress != null) {
      _emit(
        value.copyWith(
          position: position,
          currentCenter: position,
          addressData: BaseState(
            state: StatusState.success,
            data: cachedAddress,
          ),
        ),
      );
      return;
    }

    _emit(
      value.copyWith(
        position: position,
        currentCenter: position,
        addressData: const BaseState(state: StatusState.loading),
      ),
    );

    final isConnected = await _networkStatus.hasInternet;
    if (!isConnected) {
      _emit(
        value.copyWith(
          position: position,
          currentCenter: position,
          addressData: BaseState(
            state: StatusState.failure,
            exception: OfflineFailure(strings.noInternet),
          ),
        ),
      );
      return;
    }

    try {
      final address = await _addressLookup.addressFor(position);
      _emit(
        value.copyWith(
          position: position,
          currentCenter: position,
          addressData: BaseState(
            state: StatusState.success,
            data:
                (address != "Unknown" && address.isNotEmpty)
                    ? address
                    : value.addressData.data,
          ),
        ),
      );
    } catch (e) {
      _emit(
        value.copyWith(
          position: position,
          currentCenter: position,
          addressData: BaseState(
            state: StatusState.failure,
            exception: LocationPickerFailure(strings.locationFetchFailed),
          ),
        ),
      );
    }
  }

  void selectLocation(LatLng position, String address) {
    _emit(
      value.copyWith(
        position: position,
        currentCenter: position,
        shouldMoveToPosition: true,
        isMoving: false,
        addressData: BaseState(state: StatusState.success, data: address),
      ),
    );
  }

  void dismissError() {
    final fallbackPosition =
        value.currentCenter ?? value.position ?? fallbackLatLng;
    _emit(
      value.copyWith(
        position: fallbackPosition,
        currentCenter: fallbackPosition,
        shouldMoveToPosition: true,
        isMoving: false,
        addressData: BaseState(
          state: StatusState.success,
          data: value.addressData.data ?? strings.unknownLocation,
        ),
      ),
    );
  }
}
