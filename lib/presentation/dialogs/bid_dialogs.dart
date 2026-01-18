import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/validators.dart';

/// Custom Bid Dialog
class CustomBidDialog extends StatefulWidget {
  final double currentPrice;
  final double minIncrement;
  final Function(double) onBid;

  const CustomBidDialog({
    super.key,
    required this.currentPrice,
    required this.minIncrement,
    required this.onBid,
  });

  @override
  State<CustomBidDialog> createState() => _CustomBidDialogState();
}

class _CustomBidDialogState extends State<CustomBidDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  late double _bidAmount;
  bool _isValid = false;

  double get _minimumBid => widget.currentPrice + widget.minIncrement;

  @override
  void initState() {
    super.initState();
    _bidAmount = _minimumBid;
    _controller = TextEditingController(text: _minimumBid.toStringAsFixed(0));
    _validateAmount(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAmount(String value) {
    final amount = double.tryParse(value.replaceAll(',', ''));
    setState(() {
      _isValid = amount != null && amount >= _minimumBid;
      if (_isValid) _bidAmount = amount!;
    });
  }

  void _incrementBid() {
    _bidAmount += widget.minIncrement;
    _controller.text = _bidAmount.toStringAsFixed(0);
    _validateAmount(_controller.text);
  }

  void _decrementBid() {
    if (_bidAmount - widget.minIncrement >= _minimumBid) {
      _bidAmount -= widget.minIncrement;
      _controller.text = _bidAmount.toStringAsFixed(0);
      _validateAmount(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'مزايدة مخصصة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current price info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'السعر الحالي',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyUtils.formatIQD(widget.currentPrice),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Minimum bid info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: AppColors.secondaryDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الحد الأدنى للمزايدة: ${CurrencyUtils.formatIQD(_minimumBid)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bid amount input
            Form(
              key: _formKey,
              child: Row(
                children: [
                  // Decrement button
                  IconButton.outlined(
                    onPressed: _bidAmount > _minimumBid ? _decrementBid : null,
                    icon: const Icon(Icons.remove),
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Amount input
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        suffixText: 'د.ع',
                        errorText: !_isValid && _controller.text.isNotEmpty
                            ? 'المبلغ أقل من الحد الأدنى'
                            : null,
                      ),
                      onChanged: _validateAmount,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Increment button
                  IconButton.filled(
                    onPressed: _incrementBid,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick add buttons
            Wrap(
              spacing: 8,
              children: [5000, 10000, 25000, 50000].map((increment) {
                return ActionChip(
                  label: Text('+${CurrencyUtils.formatIQDShort(increment.toDouble())}'),
                  onPressed: () {
                    _bidAmount += increment;
                    _controller.text = _bidAmount.toStringAsFixed(0);
                    _validateAmount(_controller.text);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isValid
                    ? () {
                        widget.onBid(_bidAmount);
                        Navigator.pop(context);
                      }
                    : null,
                child: Text(
                  'مزايدة بمبلغ ${CurrencyUtils.formatIQD(_bidAmount)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Auto-Bid Setup Dialog
class AutoBidDialog extends StatefulWidget {
  final double currentPrice;
  final double minIncrement;
  final Function(double) onSetup;

  const AutoBidDialog({
    super.key,
    required this.currentPrice,
    required this.minIncrement,
    required this.onSetup,
  });

  @override
  State<AutoBidDialog> createState() => _AutoBidDialogState();
}

class _AutoBidDialogState extends State<AutoBidDialog> {
  late TextEditingController _controller;
  late double _maxAmount;
  bool _isValid = false;

  double get _minimumMax => widget.currentPrice + (widget.minIncrement * 2);

  @override
  void initState() {
    super.initState();
    _maxAmount = _minimumMax;
    _controller = TextEditingController(text: _minimumMax.toStringAsFixed(0));
    _validateAmount(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAmount(String value) {
    final amount = double.tryParse(value.replaceAll(',', ''));
    setState(() {
      _isValid = amount != null && amount >= _minimumMax;
      if (_isValid) _maxAmount = amount!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.autorenew, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text(
                      'المزايدة التلقائية',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Explanation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'كيف تعمل المزايدة التلقائية؟',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• حدد الحد الأقصى للمبلغ الذي ترغب بدفعه\n'
                    '• سنزايد تلقائياً نيابة عنك عند وجود مزايدات أخرى\n'
                    '• نضمن لك أقل سعر ممكن للفوز',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Current price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('السعر الحالي:', style: TextStyle(color: AppColors.textSecondary)),
                Text(
                  CurrencyUtils.formatIQD(widget.currentPrice),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الحد الأدنى للزيادة:', style: TextStyle(color: AppColors.textSecondary)),
                Text(
                  CurrencyUtils.formatIQD(widget.minIncrement),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Max amount input
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'الحد الأقصى للمزايدة',
                suffixText: 'د.ع',
                helperText: 'الحد الأدنى: ${CurrencyUtils.formatIQD(_minimumMax)}',
                errorText: !_isValid && _controller.text.isNotEmpty
                    ? 'المبلغ أقل من الحد الأدنى المطلوب'
                    : null,
              ),
              onChanged: _validateAmount,
            ),
            const SizedBox(height: 16),

            // Suggested amounts
            Wrap(
              spacing: 8,
              children: [
                _minimumMax + 25000,
                _minimumMax + 50000,
                _minimumMax + 100000,
              ].map((amount) {
                return ChoiceChip(
                  label: Text(CurrencyUtils.formatIQDShort(amount)),
                  selected: _maxAmount == amount,
                  onSelected: (selected) {
                    if (selected) {
                      _maxAmount = amount;
                      _controller.text = amount.toStringAsFixed(0);
                      _validateAmount(_controller.text);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _isValid
                    ? () {
                        widget.onSetup(_maxAmount);
                        Navigator.pop(context);
                      }
                    : null,
                icon: const Icon(Icons.autorenew),
                label: const Text(
                  'تفعيل المزايدة التلقائية',
                  style: TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
