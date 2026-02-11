import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobileapplication/userdashboard/config/user_dashboard_fonts.dart';
import 'package:mobileapplication/userdashboard/usersettingsv2/usersettings_provider_v2.dart';
import 'package:mobileapplication/widgets/floating_message.dart';

class SMSVerificationDialog extends StatefulWidget {
  final String phoneNumber;
  final SettingsProviderV2 provider;

  const SMSVerificationDialog({
    Key? key,
    required this.phoneNumber,
    required this.provider,
  }) : super(key: key);

  @override
  _SMSVerificationDialogState createState() => _SMSVerificationDialogState();
}

class _SMSVerificationDialogState extends State<SMSVerificationDialog> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isResending = false;
  int _remainingTime = 300; // 5 minutes in seconds
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingTime--;
        });

        if (_remainingTime <= 0) {
          timer.cancel();
        }
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.length != 6) {
      _showErrorSnackBar('Please enter a 6-digit verification code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('DEBUG: Verifying SMS code: ${_codeController.text}');
      final result = await widget.provider.verifySMSCode(_codeController.text);
      print('DEBUG: Verification result: $result');

      if (result['success']) {
        if (mounted) {
          print('DEBUG: SMS verification successful, closing dialog');
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('DEBUG: SMS verification failed: ${result['message']}');
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      print('DEBUG: SMS verification error: $e');
      _showErrorSnackBar('Error verifying code: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
    });

    try {
      print('DEBUG: Resending SMS code to: ${widget.phoneNumber}');
      final result =
          await widget.provider.sendSMSVerificationCode(widget.phoneNumber);
      print('DEBUG: Resend result: $result');

      if (result['success']) {
        setState(() {
          _remainingTime = 300; // Reset timer
        });
        _startTimer();
        _showSuccessSnackBar('Verification code resent');
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      print('DEBUG: Resend error: $e');
      _showErrorSnackBar('Error resending code: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    FloatingMessageService().showError(context, message);
  }

  void _showSuccessSnackBar(String message) {
    FloatingMessageService().showSuccess(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width * 0.9; // 90% of screen width
    final maxHeight = screenSize.height * 0.8; // 80% of screen height

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth > 400 ? 400 : maxWidth,
          maxHeight: maxHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1A1A1A),
                      const Color(0xFF2D2D2D),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFFF8F9FA),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 60,
                offset: const Offset(0, 30),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ultra Compact Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenSize.width < 350 ? 16 : 20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFF8F9FA),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Ultra Compact Icon Container
                      Container(
                        padding:
                            EdgeInsets.all(screenSize.width < 350 ? 10 : 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF01BAEF),
                        ),
                        child: Icon(
                          Icons.sms_outlined,
                          color: Colors.white,
                          size: screenSize.width < 350 ? 18 : 20,
                        ),
                      ),

                      SizedBox(height: screenSize.width < 350 ? 10 : 12),

                      // Title
                      Text(
                        'SMS Verification',
                        style: UserDashboardFonts.largeTextSemiBold.copyWith(
                          color:
                              isDark ? Colors.white : const Color(0xFF1A1A1A),
                          fontSize: screenSize.width < 350 ? 16 : 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: screenSize.width < 350 ? 4 : 6),

                      // Subtitle
                      Text(
                        'Enter the 6-digit code sent to',
                        style: UserDashboardFonts.bodyText.copyWith(
                          color:
                              isDark ? Colors.white70 : const Color(0xFF6B7280),
                          fontSize: screenSize.width < 350 ? 12 : 13,
                        ),
                      ),

                      SizedBox(height: screenSize.width < 350 ? 3 : 4),

                      // Phone Number
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width < 350 ? 8 : 10,
                            vertical: screenSize.width < 350 ? 3 : 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.provider.getFormattedPhoneNumber(),
                          style: UserDashboardFonts.bodyText.copyWith(
                            color:
                                isDark ? Colors.white : const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w600,
                            fontSize: screenSize.width < 350 ? 12 : 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Ultra Compact Content Area
                Padding(
                  padding: EdgeInsets.all(screenSize.width < 350 ? 16 : 20),
                  child: Column(
                    children: [
                      // Compact Verification Code Input
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color:
                              isDark ? const Color(0xFF2D2D2D) : Colors.white,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF404040)
                                : const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _codeController,
                          focusNode: _codeFocusNode,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          style: UserDashboardFonts.largeTextSemiBold.copyWith(
                            fontSize: screenSize.width < 350 ? 18 : 20,
                            letterSpacing: screenSize.width < 350 ? 4 : 6,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            hintText: '• • • • • •',
                            hintStyle:
                                UserDashboardFonts.largeTextSemiBold.copyWith(
                              fontSize: screenSize.width < 350 ? 18 : 20,
                              letterSpacing: screenSize.width < 350 ? 4 : 6,
                              color: isDark
                                  ? Colors.white30
                                  : const Color(0xFFD1D5DB),
                              fontWeight: FontWeight.w700,
                            ),
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF01BAEF),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenSize.width < 350 ? 12 : 16,
                              vertical: screenSize.width < 350 ? 12 : 14,
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length == 6) {
                              _verifyCode();
                            }
                          },
                        ),
                      ),

                      SizedBox(height: screenSize.width < 350 ? 10 : 12),

                      // Ultra Compact Timer
                      if (_remainingTime > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width < 350 ? 8 : 10,
                              vertical: screenSize.width < 350 ? 4 : 6),
                          decoration: BoxDecoration(
                            color: _remainingTime < 60
                                ? Colors.red.withOpacity(0.1)
                                : (isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : const Color(0xFFF3F4F6)),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _remainingTime < 60
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: screenSize.width < 350 ? 10 : 12,
                                color: _remainingTime < 60
                                    ? Colors.red
                                    : (isDark
                                        ? Colors.white70
                                        : const Color(0xFF6B7280)),
                              ),
                              SizedBox(width: screenSize.width < 350 ? 3 : 4),
                              Flexible(
                                child: Text(
                                  'Code expires in ${_formatTime(_remainingTime)}',
                                  style: UserDashboardFonts.smallText.copyWith(
                                    color: _remainingTime < 60
                                        ? Colors.red
                                        : (isDark
                                            ? Colors.white70
                                            : const Color(0xFF6B7280)),
                                    fontWeight: FontWeight.w600,
                                    fontSize: screenSize.width < 350 ? 10 : 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: screenSize.width < 350 ? 12 : 16),

                      // Ultra Compact Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _remainingTime > 0 || _isResending
                                    ? (isDark
                                        ? const Color(0xFF404040)
                                        : const Color(0xFFF3F4F6))
                                    : (isDark
                                        ? const Color(0xFF404040)
                                        : const Color(0xFFF3F4F6)),
                              ),
                              child: TextButton(
                                onPressed: _isResending || _remainingTime > 0
                                    ? null
                                    : _resendCode,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          screenSize.width < 350 ? 8 : 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isResending
                                    ? SizedBox(
                                        height:
                                            screenSize.width < 350 ? 12 : 14,
                                        width: screenSize.width < 350 ? 12 : 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            isDark
                                                ? Colors.white70
                                                : const Color(0xFF6B7280),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Resend Code',
                                        style: UserDashboardFonts.bodyText
                                            .copyWith(
                                          color: _remainingTime > 0
                                              ? (isDark
                                                  ? Colors.white30
                                                  : const Color(0xFF9CA3AF))
                                              : (isDark
                                                  ? Colors.white70
                                                  : const Color(0xFF6B7280)),
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                              screenSize.width < 350 ? 12 : 13,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenSize.width < 350 ? 6 : 8),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFF01BAEF),
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _verifyCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          screenSize.width < 350 ? 8 : 10),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height:
                                            screenSize.width < 350 ? 12 : 14,
                                        width: screenSize.width < 350 ? 12 : 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Verify',
                                        style: UserDashboardFonts.bodyText
                                            .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize:
                                              screenSize.width < 350 ? 12 : 13,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenSize.width < 350 ? 10 : 12),

                      // Cancel Button
                      TextButton(
                        onPressed: () {
                          widget.provider.clearSMSVerification();
                          Navigator.of(context).pop(false);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width < 350 ? 10 : 12,
                              vertical: screenSize.width < 350 ? 4 : 6),
                        ),
                        child: Text(
                          'Cancel',
                          style: UserDashboardFonts.bodyText.copyWith(
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w500,
                            fontSize: screenSize.width < 350 ? 12 : 13,
                          ),
                        ),
                      ),
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
