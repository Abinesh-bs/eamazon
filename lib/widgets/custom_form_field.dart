import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatefulWidget {
  CustomTextFormField({
    Key? key,
    this.labelName,
    this.isEditable = false,
    this.prefixIcon,
    required this.hintText,
    this.validator,
    this.initialValue,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.keyboardType,
    this.controller,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.fillColor = const Color.fromRGBO(211, 211, 211, .2),
    this.focusColor = Colors.white,
    this.onFieldSubmitted,
    this.marginHorizontal,
    this.marginVertical,
    this.focusScope,
  }) : super(key: key);
  final String? labelName, hintText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  String? initialValue;
  List<TextInputFormatter>? inputFormatters;
  int? maxLines = 1;
  int? minLines;
  int? maxLength;
  bool isEditable = false;
  GestureTapCallback? onTap;
  bool readOnly;
  ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final FormFieldValidator? validator;
  final Color? fillColor;
  final Color? focusColor;
  bool obscureText;
  ValueChanged<String>? onFieldSubmitted;
  final double? marginVertical;
  final double? marginHorizontal;
  final FocusNode? focusScope;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late FocusNode _myFocusNode;
  final ValueNotifier<bool> _myFocusNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    _myFocusNode = widget.focusScope ?? FocusNode();
    _myFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _myFocusNode.removeListener(_onFocusChange);
    _myFocusNode.dispose();
    _myFocusNotifier.dispose();

    super.dispose();
  }

  void _onFocusChange() {
    _myFocusNotifier.value = _myFocusNode.hasFocus;
  }

  Color? colors;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _myFocusNotifier,
      builder: (_, isFocus, child) {
        buildColor() {
          if (widget.readOnly) {
            colors = widget.fillColor;
          }
          if (widget.readOnly && widget.isEditable) {
            colors = widget.fillColor;
          }
          if (isFocus) {
            colors = widget.focusColor;
          }
          if (isFocus && widget.readOnly && !widget.isEditable) {
            colors = widget.fillColor;
          }
          if (!isFocus && !widget.readOnly) {
            colors = widget.fillColor;
          }
          return colors;
        }

        return Container(
          margin: EdgeInsets.symmetric(
            vertical: widget.marginVertical ?? 8.h,
            horizontal: widget.marginHorizontal ?? 16.w,
          ),
          child: TextFormField(
            onFieldSubmitted: widget.onFieldSubmitted,
            keyboardType: widget.keyboardType,
            maxLength: widget.maxLength,
            initialValue: widget.initialValue,
            controller: widget.controller,
            onTap: widget.onTap,
            maxLines: widget.obscureText == true ? 1 : widget.maxLines ?? 1,
            minLines: widget.minLines,
            readOnly: widget.readOnly,
            inputFormatters: widget.inputFormatters,
            style:
                kIsWeb
                    ? Theme.of(context).textTheme.bodyLarge
                    : Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.start,
            validator: widget.validator,
            onChanged: widget.onChanged,
            obscureText: widget.obscureText,
            focusNode: _myFocusNode,
            decoration: InputDecoration(
              hintText: widget.hintText,
              counterText: "",
              hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.withOpacity(0.8),
                fontSize: 14.sp,
              ),
              filled: true,
              fillColor: buildColor(),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              border:
                  isFocus
                      ? OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isFocus ? Colors.black : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      )
                      : InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10.r),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        );
      },
    );
  }
}
