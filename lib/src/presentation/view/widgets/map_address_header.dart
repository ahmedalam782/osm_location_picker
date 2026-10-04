import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/place_search.dart';
import '../../location_picker_icon.dart';
import '../../location_picker_strings.dart';
import '../../location_picker_theme.dart';

/// A creative, responsive search and address header widget with frosted glassmorphism,
/// desktop keyboard shortcuts, and responsive constraints across all devices.
class MapAddressHeader extends StatefulWidget {
  final String addressText;
  final LocationPickerTheme theme;
  final LocationPickerStrings strings;
  final PlaceSearch placeSearch;
  final LatLng? near;
  final bool isLoading;
  final void Function(LatLng position, String address) onLocationSelected;

  const MapAddressHeader({
    super.key,
    required this.addressText,
    required this.theme,
    required this.strings,
    required this.placeSearch,
    required this.near,
    required this.isLoading,
    required this.onLocationSelected,
  });

  @override
  State<MapAddressHeader> createState() => _MapAddressHeaderState();
}

class _MapAddressHeaderState extends State<MapAddressHeader> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<NominatimSearchResult> _results = [];
  bool _searching = false;
  bool _loading = false;
  bool _hasSearched = false;
  int _activeIndex = 0;
  Timer? _debounce;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.onKeyEvent = _onSearchKey;
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _controller.text.isEmpty) {
        setState(() {
          _searching = false;
          _results = [];
          _hasSearched = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searching = true);
    _focusNode.requestFocus();
  }

  void _closeSearch() {
    _debounce?.cancel();
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _searching = false;
      _results = [];
      _loading = false;
      _hasSearched = false;
    });
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
        _hasSearched = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () => _search(query));
  }

  KeyEventResult _onSearchKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || _results.isEmpty) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _activeIndex = (_activeIndex + 1).clamp(0, _results.length - 1);
      });
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _activeIndex = (_activeIndex - 1).clamp(0, _results.length - 1);
      });
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _search(String query) async {
    final requestId = ++_requestId;
    setState(() => _loading = true);
    final results = await widget.placeSearch.search(query, near: widget.near);
    if (!mounted || requestId != _requestId) return;
    setState(() {
      _results = results;
      _loading = false;
      _hasSearched = true;
      _activeIndex = 0;
    });
  }

  void _submit(String query) {
    if (_results.isEmpty) {
      _search(query);
      return;
    }
    final index = _activeIndex.clamp(0, _results.length - 1);
    _select(_results[index]);
  }

  void _select(NominatimSearchResult item) {
    widget.onLocationSelected(item.latLng, item.displayName);
    _closeSearch();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final place = _placeName(widget.addressText);
    final area = _areaName(widget.addressText, isRtl);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surfaceColor = widget.theme.cardColor.withValues(
      alpha: widget.theme.glassmorphism ? 0.88 : 1.0,
    );
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : widget.theme.borderColor.withValues(alpha: 0.45);
    final radius = BorderRadius.circular(widget.theme.borderRadius);

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): _closeSearch,
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Search & Address Floating Card ---
                _FrostedCard(
                  theme: widget.theme,
                  borderRadius: radius,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searching)
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: _onQueryChanged,
                          textInputAction: TextInputAction.search,
                          onSubmitted: _submit,
                          style: TextStyle(
                            color: widget.theme.textDarkColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: widget.strings.searchHint,
                            hintStyle: TextStyle(
                              color: widget.theme.textDarkColor.withValues(
                                alpha: 0.5,
                              ),
                              fontSize: 15,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: LocationPickerIconView(
                                icon:
                                    widget.theme.searchIcon ??
                                    LocationPickerIcon.search,
                                color: widget.theme.primaryColor,
                                size: 20,
                              ),
                            ),
                            suffixIcon: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: widget.theme.textDarkColor.withValues(
                                    alpha: 0.65,
                                  ),
                                  size: 20,
                                ),
                                onPressed: _closeSearch,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 8,
                            ),
                          ),
                        )
                      else
                        InkWell(
                          onTap: _openSearch,
                          borderRadius: radius,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: widget.theme.primaryColor.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: LocationPickerIconView(
                                      icon:
                                          widget.theme.searchIcon ??
                                          LocationPickerIcon.search,
                                      color: widget.theme.primaryColor,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: widget.isLoading
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: widget.theme.primaryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                widget.addressText,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: widget.theme.textDarkColor
                                                      .withValues(alpha: 0.7),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              place,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.start,
                                              textDirection: isRtl
                                                  ? TextDirection.rtl
                                                  : TextDirection.ltr,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: widget.theme.textDarkColor,
                                              ),
                                            ),
                                            if (area.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                area,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.start,
                                                textDirection: isRtl
                                                    ? TextDirection.rtl
                                                    : TextDirection.ltr,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: widget.theme.textDarkColor
                                                      .withValues(alpha: 0.65),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.tune_rounded,
                                  size: 18,
                                  color: widget.theme.textDarkColor.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if ((_searching && _loading) ||
                          (!_searching && widget.isLoading))
                        _GlowingAddressLoadBar(color: widget.theme.primaryColor),
                      if (_searching &&
                          _hasSearched &&
                          !_loading &&
                          _results.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          child: Text(
                            widget.strings.noResults,
                            style: TextStyle(
                              color: widget.theme.textDarkColor.withValues(
                                alpha: 0.55,
                              ),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      if (_searching && _results.isNotEmpty) ...[
                        Divider(height: 1, thickness: 0.6, color: borderColor),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 320),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final item = _results[index];
                              return _SearchResultTile(
                                item: item,
                                query: _controller.text,
                                theme: widget.theme,
                                isRtl: isRtl,
                                selected: index == _activeIndex,
                                onTap: () => _select(item),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FrostedCard extends StatelessWidget {
  final LocationPickerTheme theme;
  final BorderRadius borderRadius;
  final Color surfaceColor;
  final Color borderColor;
  final Widget child;

  const _FrostedCard({
    required this.theme,
    required this.borderRadius,
    required this.surfaceColor,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [theme.shadowBox],
      ),
      child: child,
    );

    if (!theme.glassmorphism) return container;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: container,
      ),
    );
  }
}

class _SearchResultTile extends StatefulWidget {
  final NominatimSearchResult item;
  final String query;
  final LocationPickerTheme theme;
  final bool isRtl;
  final bool selected;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.item,
    required this.query,
    required this.theme,
    required this.isRtl,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<_SearchResultTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final direction = widget.isRtl ? TextDirection.rtl : TextDirection.ltr;
    final highlighted = _isHovered || widget.selected;
    final address = _orderedAddress(widget.item.displayName, widget.isRtl);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: highlighted
            ? widget.theme.textDarkColor.withValues(alpha: 0.06)
            : Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              textDirection: direction,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 22,
                  color: widget.theme.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _highlight(
                        address,
                        widget.query,
                        TextStyle(
                          color: widget.theme.textDarkColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        TextStyle(
                          color: widget.theme.textDarkColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: direction,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowingAddressLoadBar extends StatefulWidget {
  final Color color;

  const _GlowingAddressLoadBar({required this.color});

  @override
  State<_GlowingAddressLoadBar> createState() => _GlowingAddressLoadBarState();
}

class _GlowingAddressLoadBarState extends State<_GlowingAddressLoadBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          final barWidth = trackWidth * 0.45;
          return ColoredBox(
            color: widget.color.withValues(alpha: 0.12),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final travel = trackWidth + barWidth;
                return Stack(
                  children: [
                    Positioned(
                      left: travel * _controller.value - barWidth,
                      width: barWidth,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.color.withValues(alpha: 0.1),
                              widget.color,
                              widget.color.withValues(alpha: 0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

List<InlineSpan> _highlight(
  String text,
  String query,
  TextStyle base,
  TextStyle match,
) {
  final needle = query.trim();
  if (needle.isEmpty) return [TextSpan(text: text, style: base)];
  final lower = text.toLowerCase();
  final target = needle.toLowerCase();
  final spans = <InlineSpan>[];
  var start = 0;
  while (start < text.length) {
    final index = lower.indexOf(target, start);
    if (index < 0) {
      spans.add(TextSpan(text: text.substring(start), style: base));
      break;
    }
    if (index > start) {
      spans.add(TextSpan(text: text.substring(start, index), style: base));
    }
    final end = index + target.length;
    spans.add(TextSpan(text: text.substring(index, end), style: match));
    start = end;
  }
  return spans;
}

List<String> _addressParts(String address) {
  return address
      .split(RegExp(r'\s*[,،]\s*'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
}

/// Nominatim starts with the place under the pin and ends with the country.
String _placeName(String address) {
  final parts = _addressParts(address);
  if (parts.isEmpty) return address;
  return parts.first;
}

/// The wider area. Arabic reads this from the country side.
String _areaName(String address, bool isRtl) {
  final parts = _addressParts(address);
  if (parts.length < 2) return '';
  final area = parts.sublist(1);
  final ordered = isRtl ? area.reversed : area;
  return ordered.join(isRtl ? '، ' : ', ');
}

/// Nominatim returns "number, street, city, country".
/// Arabic reads that from the country side, so the parts are reversed.
String _orderedAddress(String address, bool isRtl) {
  final parts = _addressParts(address);
  if (parts.isEmpty) return address;
  if (parts.length < 2) return parts.first;
  final ordered = isRtl ? parts.reversed : parts;
  return ordered.join(', ');
}
