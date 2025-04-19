import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultButton extends StatelessWidget {
  DefaultButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color,
  }) : super(key: key);
  final String text;
  final VoidCallback onPressed;
  Color? color;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: double.infinity,
      // height: SizeConfig.getProportionateScreenHeight(10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              color == null
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          textStyle: Theme.of(context).textTheme.headlineSmall,
        ),
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: color ?? Colors.white),
        ),
      ),
    );
  }
}
