library;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:intl_mobile_field/countries.dart';
import 'package:intl_mobile_field/country_picker_dialog.dart';
import 'package:intl_mobile_field/flags_drop_down.dart';
import 'package:intl_mobile_field/helpers.dart';
import 'package:intl_mobile_field/mobile_number.dart';
import 'package:material_ui/material_ui.dart';

class IntlMobileField extends StatefulWidget {
  final GlobalKey<FormFieldState>? formFieldKey;
  final InputBorder? border;
  final BoxConstraints? prefixIconConstraints;
  final Color? fillColor;
  final bool obscureText;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final VoidCallback? onTap;
  final bool readOnly;
  final FormFieldSetter<MobileNumber>? onSaved;
  final ValueChanged<MobileNumber>? onChanged;
  final FutureOr<String?> Function(MobileNumber?)? validator;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final Brightness? keyboardAppearance;
  final String? initialValue;
  final List<String>? countries;
  final InputDecoration decoration;
  final TextStyle? style;
  final bool disableLengthCheck;
  final bool disableLengthCounter;
  final List<TextInputFormatter>? inputFormatters;
  final bool autoFocus;
  final AutovalidateMode? autovalidateMode;
  final String? invalidNumberMessage;
  final Color? cursorColor;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final double cursorWidth;
  final bool? showCursor;
  final TextInputAction? textInputAction;
  final bool disableAutoFillHints;
  final TextMagnifierConfiguration? magnifierConfiguration;
  final EdgeInsets scrollPadding;
  final bool expands;
  final int? maxLines;
  final TapRegionCallback? onTapOutside;
  final Widget? suffixIcon;
  final ValueKey? flagsButtonKey;
  final bool showDropdownIcon;
  final bool disableFlagTap;
  final String? initialCountryCode;
  final Widget dropdownIcon;
  final Position dropdownIconPosition;
  final bool showDialogCountryFlag;
  final BoxDecoration dropdownDecoration;
  final EdgeInsetsGeometry flagsButtonPadding;
  final EdgeInsets flagsButtonMargin;
  final double? flagWidth;
  final TextStyle? dropdownTextStyle;
  final List<String> favorite;
  final String? languageCode;
  final bool? enableFavoriteIcon;
  final Position favoriteIconPosition;
  final Widget? favoriteIcon;
  final bool? rltSupport;
  final PickerDialogStyle? pickerDialogStyle;
  final Position favoriteCountryCodePosition;
  final Position dialogCountryCodePosition;
  final Position fieldCountryCodePosition;
  final ValueChanged<Country>? onCountryChanged;
  final bool countryCodeDisable;
  final bool showFieldCountryFlag;
  final double? countryPickerDialogBoxHeight;
  final TextStyle? lengthCounterTextStyle;
  final MobileNumber? initialMobileNumber;

  const IntlMobileField({
    super.key,
    this.formFieldKey,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.disableAutoFillHints = false,
    this.obscureText = false,
    this.textAlign = TextAlign.left,
    this.textAlignVertical,
    this.onTap,
    this.readOnly = false,
    this.initialValue,
    this.keyboardType = TextInputType.phone,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.style,
    this.border,
    this.fillColor,
    this.prefixIconConstraints,
    this.onSubmitted,
    this.validator,
    this.onChanged,
    this.countries,
    this.onSaved,
    this.inputFormatters,
    this.enabled = true,
    this.keyboardAppearance,
    this.autoFocus = false,
    this.textInputAction,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.cursorColor,
    this.disableLengthCheck = false,
    this.disableLengthCounter = false,
    this.invalidNumberMessage = 'Invalid Mobile Number',
    this.cursorHeight,
    this.cursorRadius = Radius.zero,
    this.cursorWidth = 2.0,
    this.showCursor = true,
    this.magnifierConfiguration,
    this.expands = false,
    this.maxLines = 1,
    this.onTapOutside,
    this.suffixIcon,
    this.onCountryChanged,
    this.flagsButtonKey,
    this.initialCountryCode,
    this.favorite = const [],
    this.showDropdownIcon = true,
    this.dropdownIcon = const Icon(Icons.arrow_drop_down),
    this.dropdownIconPosition = Position.leading,
    this.showDialogCountryFlag = true,
    this.dropdownDecoration = const BoxDecoration(),
    this.flagsButtonPadding = EdgeInsets.zero,
    this.flagsButtonMargin = EdgeInsets.zero,
    this.flagWidth = 32,
    this.dropdownTextStyle,
    this.disableFlagTap = false,
    this.languageCode,
    this.rltSupport,
    this.pickerDialogStyle,
    this.favoriteIcon,
    this.favoriteIconPosition = Position.leading,
    this.enableFavoriteIcon,
    this.fieldCountryCodePosition = Position.trailing,
    this.favoriteCountryCodePosition = Position.leading,
    this.dialogCountryCodePosition = Position.trailing,
    this.countryCodeDisable = false,
    this.showFieldCountryFlag = true,
    this.countryPickerDialogBoxHeight,
    this.lengthCounterTextStyle,
    this.initialMobileNumber,
  });

  @override
  State<IntlMobileField> createState() => _IntlMobileFieldState();
}

class _IntlMobileFieldState extends State<IntlMobileField> {
  late List<Country> countryList;
  late Country _selectedCountry;
  String number = '';
  String? asyncValidationMessage;
  bool isValidating = false;
  String initial = "";

  Timer? _debounceTimer;
  // unchanged
  String get _selectedCountryDialCode => '+${_selectedCountry.fullCountryCode}';

  // unchanged
  MobileNumber _buildMobileNumber(String? number) {
    return MobileNumber(
      countryISOCode: _selectedCountry.code,
      countryCode: _selectedCountryDialCode,
      number: number ?? '',
    );
  }

  @override
  void initState() {
    super.initState();

    // Build from attached countries list; keep your filtering behavior
    countryList = (widget.countries == null || widget.countries!.isEmpty)
        ? countries
        : countries.where((c) {
            final allow = widget.countries!;
            return allow.contains(c.code) || allow.contains(c.dialCode);
          }).toList(); // uses attached countries and Country model

    // Always resolve from initialCountryCode or fallback, do not infer from controller text
    _selectedCountry = _resolveInitialCountry(widget.initialCountryCode);

    if (widget.initialMobileNumber != null) {
      final mobile = widget.initialMobileNumber!;
      _selectedCountry = countryList.firstWhere(
        (c) =>
            c.code.toUpperCase() == mobile.countryISOCode.toUpperCase() ||
            c.dialCode == mobile.countryCode.replaceAll('+', ''),
        orElse: () => _selectedCountry,
      );
      number = mobile.number;
      if (widget.controller != null) {
        widget.controller!.text = number;
      }
    } else {
      final initialText = widget.controller?.text ?? widget.initialValue ?? '';
      widget.controller?.addListener(_handleControllerChange);
      number = _stripCountryCode(initialText, _selectedCountry);
      if (widget.controller != null) {
        widget.controller!.text = number;
      }
      if (widget.autovalidateMode == AutovalidateMode.always) {
        _validateAsync(_buildMobileNumber(number)); // will be gated by length
      }
    }
  }

  Country _resolveInitialCountry(String? initialCountryCode) {
    if (initialCountryCode != null && initialCountryCode.isNotEmpty) {
      final code = initialCountryCode.toUpperCase();
      final byIso = countryList.where((c) => c.code.toUpperCase() == code);
      if (byIso.isNotEmpty) return byIso.first;
      final byDial = countryList.where((c) => c.dialCode == code);
      if (byDial.isNotEmpty) return byDial.first;
    }
    return countryList.firstWhere(
      (c) => c.code.toUpperCase() == 'BD',
      orElse: () => countryList.first,
    ); // BD exists in attached data
  }

  Country _getInitialCountry(String number) {
    final cleanNumber = number.replaceAll(RegExp(r'[^+0-9]'), '');
    if (cleanNumber.startsWith('+')) {
      final withoutPlus = cleanNumber.substring(1);
      for (final country in countryList) {
        final fullCode = country.dialCode + (country.regionCode);
        if (fullCode.isNotEmpty && withoutPlus.startsWith(fullCode)) {
          return country;
        }
      }
      for (final country in countryList) {
        if (withoutPlus.startsWith(country.dialCode)) {
          return country;
        }
      }
    }
    return _resolveInitialCountry(widget.initialCountryCode);
  }

  String _stripCountryCode(String input, Country country) {
    if (input.isEmpty) return '';
    final clean = input.replaceAll(RegExp(r'[^+0-9]'), '');
    if (clean.startsWith('+')) {
      final withoutPlus = clean.substring(1);
      if (withoutPlus.startsWith(country.fullCountryCode)) {
        return withoutPlus.substring(country.fullCountryCode.length);
      }
      if (withoutPlus.startsWith(country.dialCode)) {
        return withoutPlus.substring(country.dialCode.length);
      }
      return withoutPlus;
    }
    return clean; // keep digits only
  }

  void _handleControllerChange() {
    if (!mounted) return;

    final rawText = widget.controller?.text ?? '';
    final cleanText = rawText.replaceAll(RegExp(r'[^+0-9]'), '');

    if (cleanText.isEmpty) {
      final defaultCountry = _resolveInitialCountry(widget.initialCountryCode);
      if (_selectedCountry.code != defaultCountry.code) {
        setState(() {
          _selectedCountry = defaultCountry;
        });
        widget.onCountryChanged?.call(defaultCountry);
      }
      setState(() => number = '');
      widget.onChanged?.call(_buildMobileNumber(''));
      return;
    }

    if (cleanText.startsWith('+')) {
      final newCountry = _getInitialCountry(cleanText);
      final stripped = _stripCountryCode(cleanText, newCountry);

      if (newCountry.code != _selectedCountry.code) {
        setState(() {
          _selectedCountry = newCountry;
        });
        widget.onCountryChanged?.call(newCountry);
      }

      final isComplete = stripped.length >= newCountry.maxLength;
      if (isComplete) {
        final cursorPosition =
            widget.controller!.selection.baseOffset -
            (cleanText.length - stripped.length);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.controller?.text = stripped;
          widget.controller?.selection = TextSelection.collapsed(
            offset: cursorPosition.clamp(0, stripped.length),
          );
        });
      }

      setState(() => number = stripped);
      widget.onChanged?.call(_buildMobileNumber(stripped));
      return;
    }

    final stripped = _stripCountryCode(cleanText, _selectedCountry);
    setState(() => number = stripped);
    widget.onChanged?.call(_buildMobileNumber(stripped));
  }

  void _onChanged(String value) {
    final mobileNumber = _buildMobileNumber(value);
    widget.onChanged?.call(mobileNumber);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _validateAsync(mobileNumber); // now guarded by length and try/catch
    });
  }

  String? _validateSync(MobileNumber mobileNumber) {
    final value = mobileNumber.number;
    if (value.isEmpty) return null;
    if (!isNumeric(value)) return widget.invalidNumberMessage;

    if (!widget.disableLengthCheck) {
      final isValidLength =
          value.length >= _selectedCountry.minLength &&
          value.length <= _selectedCountry.maxLength;
      if (!isValidLength) return widget.invalidNumberMessage;
    }
    return null; // sync passes, async may still run later
  }

  Future<void> _validateAsync(MobileNumber mobileNumber) async {
    if (widget.validator == null) return;

    // Guard: do not call async validator until minimum length is reached
    final localLen = mobileNumber.number.length;
    if (localLen < _selectedCountry.minLength) {
      // Clear async message while typing short input
      if (asyncValidationMessage != null || isValidating) {
        setState(() {
          asyncValidationMessage = null;
          isValidating = false;
        });
      }
      return;
    } // prevents NumberTooShortException while typing

    setState(() => isValidating = true);
    try {
      final result = await widget.validator!.call(mobileNumber);
      if (!mounted) return;
      setState(() {
        asyncValidationMessage = result;
        isValidating = false;
      });
    } catch (e) {
      // Swallow length-related exceptions and generic errors during typing
      if (!mounted) return;
      setState(() {
        // Do not surface an error message for transient typing states
        asyncValidationMessage = null;
        isValidating = false;
      });
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChange);
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullText = widget.controller?.text ?? widget.initialValue ?? '';
    final hasCodeInText = fullText.startsWith(_selectedCountryDialCode);

    return TextFormField(
      key: widget.formFieldKey,
      initialValue: widget.controller == null ? number : null,
      autofillHints: widget.disableAutoFillHints
          ? null
          : [AutofillHints.telephoneNumberNational],
      readOnly: widget.readOnly,
      obscureText: widget.obscureText,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      cursorColor: widget.cursorColor,
      onTap: widget.onTap,
      onTapOutside:
          widget.onTapOutside ??
          (_) => FocusManager.instance.primaryFocus?.unfocus(),
      controller: widget.controller,
      focusNode: widget.focusNode,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorWidth: widget.cursorWidth,
      showCursor: widget.showCursor,
      onFieldSubmitted: widget.onSubmitted,
      expands: widget.expands,
      maxLines: widget.maxLines,
      magnifierConfiguration: widget.magnifierConfiguration,
      decoration: widget.decoration.copyWith(
        prefixIcon: FlagsDropDown(
          key: ValueKey(_selectedCountry.code),
          countries: countryList,
          initialCountryCode: _selectedCountry.code,
          onCountryChanged: (Country country) {
            _selectedCountry = country;
            widget.onCountryChanged?.call(country);
            setState(() {});
          },
          countryCodeDisable: widget.countryCodeDisable,
          dialogCountryCodePosition: widget.dialogCountryCodePosition,
          disableFlagTap: widget.disableFlagTap,
          dropdownDecoration: widget.dropdownDecoration,
          dropdownIcon: widget.dropdownIcon,
          dropdownIconPosition: widget.dropdownIconPosition,
          dropdownTextStyle: widget.dropdownTextStyle,
          enableFavoriteIcon: widget.enableFavoriteIcon,
          favorite: widget.favorite,
          favoriteCountryCodePosition: widget.favoriteCountryCodePosition,
          favoriteIcon: widget.favoriteIcon,
          favoriteIconPosition: widget.favoriteIconPosition,
          fieldCountryCodePosition: widget.fieldCountryCodePosition,
          flagWidth: widget.flagWidth,
          flagsButtonKey: widget.flagsButtonKey,
          flagsButtonMargin: widget.flagsButtonMargin,
          flagsButtonPadding: widget.flagsButtonPadding,
          languageCode: widget.languageCode,
          pickerDialogStyle: widget.pickerDialogStyle,
          rltSupport: widget.rltSupport,
          showDialogCountryFlag: widget.showDialogCountryFlag,
          showDropdownIcon: widget.showDropdownIcon,
          showFieldCountryFlag: widget.showFieldCountryFlag,
          countryPickerDialogBoxHeight: widget.countryPickerDialogBoxHeight,
        ),
        counterText: widget.enabled ? null : '',
        border: widget.border,
        enabledBorder: widget.border,
        focusedBorder: widget.border,
        prefixIconConstraints: widget.prefixIconConstraints,
        filled: widget.fillColor != null,
        fillColor: widget.fillColor,
        suffixIcon: widget.suffixIcon,
      ),
      style: widget.style,
      onSaved: (value) => widget.onSaved?.call(_buildMobileNumber(value)),
      onChanged: _onChanged,
      validator: (value) {
        final mobileNumber = _buildMobileNumber(value);

        if (asyncValidationMessage != null) {
          return asyncValidationMessage;
        }

        final result = widget.validator?.call(mobileNumber);

        if (result is Future<String?>) {
          result.then((msg) {
            if (mounted) {
              setState(() => asyncValidationMessage = msg);
            }
          });
          return widget.invalidNumberMessage;
        }

        if (result is String) return result;

        return _validateSync(mobileNumber);
      },
      maxLength: widget.disableLengthCounter
          ? null
          : hasCodeInText
          ? (_selectedCountry.maxLength + _selectedCountryDialCode.length)
          : _selectedCountry.maxLength,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      keyboardAppearance: widget.keyboardAppearance,
      autofocus: widget.autoFocus,
      textInputAction: widget.textInputAction,
      autovalidateMode: widget.autovalidateMode,
      scrollPadding: widget.scrollPadding,
      buildCounter:
          (
            BuildContext context, {
            int? currentLength,
            int? maxLength,
            bool? isFocused,
          }) {
            final ft = widget.controller?.text ?? widget.initialValue ?? '';
            final numberLength = _stripCountryCode(ft, _selectedCountry).length;
            final maxNumberLength = widget.disableLengthCounter
                ? 0
                : _selectedCountry.maxLength;

            return Text(
              widget.disableLengthCounter
                  ? ""
                  : '$numberLength / $maxNumberLength',
              style: widget.lengthCounterTextStyle,
            );
          },
    );
  }
}

enum Position { leading, trailing }
