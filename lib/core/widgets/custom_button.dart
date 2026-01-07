import 'package:flutter/material.dart';
import '../utils/colors.dart';

class TombolCustom extends StatelessWidget {
  final String teks;
  final VoidCallback? onPressed;
  final Color? warna;
  final Color? warnaTeks;
  final double? lebar;
  final double? tinggi;
  final bool isOutline;

  const TombolCustom({
    super.key,
    required this.teks,
    this.onPressed,
    this.warna,
    this.warnaTeks,
    this.lebar,
    this.tinggi,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: lebar ?? double.infinity,
      height: tinggi ?? 50,
      child: isOutline
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: warna ?? AppColors.primary,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                teks,
                style: TextStyle(
                  color: warnaTeks ?? AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: warna ?? AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                teks,
                style: TextStyle(
                  color: warnaTeks ?? AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}
