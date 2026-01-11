import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signa_video_to_text/features/config/themes/colors_theme.dart';
import 'package:signa_video_to_text/features/presentation/widgets/material_widgets/text_custom.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(35.h, 76.h, 35.h, 0.h),
      child: Column(
        children: [
          Container(
            height: 102.w,
            width: double.infinity.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: BoxBorder.all(width: 2.5, color: WarnaApp.wrBlue),
              color: WarnaApp.wrWhite,
            ),
            child: Padding(
              padding: EdgeInsets.all(12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: double.infinity.w,
                    width: 76.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: WarnaApp.wrGrey,
                    ),
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 46.sp,
                      color: WarnaApp.wrWhite,
                    ),
                  ),
                  SizedBox(width: 16.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      TextCustom(
                        "halo nama saya......",
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: WarnaApp.wrTextBlack,
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextCustom(
                            "30/12/2025",
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: WarnaApp.wrTextBlack,
                          ),
                          TextCustom(" | "),
                          TextCustom(
                            "25 detik",
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: WarnaApp.wrTextBlack,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  Center(
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.highlight_remove_outlined,
                        size: 32.sp,
                        color: WarnaApp.wrRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // batas reminder hungkul
          SizedBox(height: 18.h),

          Container(
            height: 102.w,
            width: double.infinity.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: BoxBorder.all(width: 2.5, color: WarnaApp.wrBlue),
              color: WarnaApp.wrWhite,
            ),
            child: Padding(
              padding: EdgeInsets.all(12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: double.infinity.w,
                    width: 76.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: WarnaApp.wrGrey,
                    ),
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 46.sp,
                      color: WarnaApp.wrWhite,
                    ),
                  ),
                  SizedBox(width: 16.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      TextCustom(
                        "saya masih bel....",
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: WarnaApp.wrTextBlack,
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextCustom(
                            "27/12/2025",
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: WarnaApp.wrTextBlack,
                          ),
                          TextCustom(" | "),
                          TextCustom(
                            "43 detik",
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: WarnaApp.wrTextBlack,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  Center(
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.highlight_remove_outlined,
                        size: 32.sp,
                        color: WarnaApp.wrRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
