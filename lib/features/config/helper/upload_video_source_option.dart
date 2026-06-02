import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/widgets/material_widgets/text_custom.dart';

class UploadSourceSheet extends StatelessWidget {
  const UploadSourceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: WarnaApp.wrWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36.w,
            height: 4,
            decoration: BoxDecoration(
              color: WarnaApp.wrGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20.h),

          TextCustom(
            "Pilih Sumber Video",
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: WarnaApp.wrTextBlack,
          ),
          SizedBox(height: 6.h),
          TextCustom(
            "Pilih dari mana video akan diambil",
            fontSize: 12,
            color: WarnaApp.wrGrey,
          ),
          SizedBox(height: 20.h),

          //Tombol Galeri
          SourceOption(
            icon: Icons.photo_library_outlined,
            label: "Galeri",
            desc: "Pilih video dari galeri",
            color: WarnaApp.wrBlue,
            onTap: () => Get.back(result: 'gallery'),
          ),
          SizedBox(height: 10.h),

          // Tombol File Manager
          SourceOption(
            icon: Icons.folder_outlined,
            label: "File Manager",
            desc: "Cari file .mp4 di penyimpanan",
            color: WarnaApp.wrOrange,
            onTap: () => Get.back(result: 'files'),
          ),
          SizedBox(height: 8.h),

          // Tombol Batal
          TextButton(
            onPressed: () => Get.back(),
            child: TextCustom(
              "Batal",
              fontSize: 14,
              color: WarnaApp.wrGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final VoidCallback onTap;
  const SourceOption({super.key, 
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  label,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: WarnaApp.wrTextBlack,
                ),
                TextCustom(desc, fontSize: 12, color: WarnaApp.wrGrey),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: WarnaApp.wrGrey.withValues(alpha: 0.5),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
