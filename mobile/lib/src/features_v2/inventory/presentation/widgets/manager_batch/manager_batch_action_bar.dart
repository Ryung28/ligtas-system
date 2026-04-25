import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';

class ManagerBatchActionBar extends StatelessWidget {
  const ManagerBatchActionBar({
    super.key,
    required this.isReserveMode,
    required this.selectedItems,
    required this.totalQuantity,
    required this.onClear,
    required this.onReview,
    required this.onExit,
  });

  final bool isReserveMode;
  final int selectedItems;
  final int totalQuantity;
  final VoidCallback onClear;
  final VoidCallback onReview;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    const onyx = Color(0xFF0F172A);
    const surfaceBorder = Color(0x33FFFFFF);
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final modeLabel = isReserveMode ? 'Reserve batch' : 'Borrow batch';
    final metrics = '$selectedItems items • $totalQuantity units';

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: safeBottom > 0 ? 8 : 0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: onyx.withOpacity(0.98),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: surfaceBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        metrics,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(6),
                IconButton(
                  onPressed: onClear,
                  tooltip: 'Clear selection',
                  icon: Icon(
                    Icons.restart_alt_rounded,
                    color: Colors.white.withOpacity(0.65),
                    size: 20,
                  ),
                ),
                const Gap(2),
                ElevatedButton(
                  onPressed: selectedItems == 0 ? null : onReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: onyx,
                    disabledBackgroundColor: Colors.white.withOpacity(0.2),
                    disabledForegroundColor: Colors.white.withOpacity(0.6),
                    elevation: 0,
                    minimumSize: const Size(92, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Review',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Gap(2),
                IconButton(
                  onPressed: onExit,
                  tooltip: 'Exit batch mode',
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withOpacity(0.65),
                    size: 20,
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
