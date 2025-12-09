import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/widgets/felt_background.dart';
import '../../core/widgets/smart_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Tip Calculator utility screen
class TipCalculatorScreen extends StatefulWidget {
  const TipCalculatorScreen({super.key});

  @override
  State<TipCalculatorScreen> createState() => _TipCalculatorScreenState();
}

class _TipCalculatorScreenState extends State<TipCalculatorScreen> {
  final TextEditingController _billController = TextEditingController();
  final TextEditingController _customPercentController = TextEditingController();
  final TextEditingController _splitController = TextEditingController(text: '1');

  double _billAmount = 0.0;
  double _tipPercentage = 0.18; // Default 18%
  int _splitCount = 1;
  bool _useCustomPercent = false;

  final List<double> _percentPresets = [0.10, 0.15, 0.18, 0.20, 0.25];

  @override
  void dispose() {
    _billController.dispose();
    _customPercentController.dispose();
    _splitController.dispose();
    super.dispose();
  }

  void _calculateTip() {
    setState(() {
      _billAmount = double.tryParse(_billController.text) ?? 0.0;
      _splitCount = int.tryParse(_splitController.text) ?? 1;
      if (_splitCount < 1) _splitCount = 1;
      
      if (_useCustomPercent) {
        final customPercent = double.tryParse(_customPercentController.text) ?? 18.0;
        _tipPercentage = customPercent / 100;
      }
    });
  }

  double get _tipAmount => _billAmount * _tipPercentage;
  double get _totalAmount => _billAmount + _tipAmount;
  double get _perPersonAmount => _totalAmount / _splitCount;
  double get _perPersonTip => _tipAmount / _splitCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        backgroundImage: 'assets/main-bg-min.jpg',
        darkOverlay: true,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBillInput(),
                      const SizedBox(height: 20),
                      _buildTipPercentSection(),
                      const SizedBox(height: 20),
                      _buildSplitSection(),
                      const SizedBox(height: 24),
                      _buildResultsCard(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.gold,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip Calculator',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quick tip calculations',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.slateGray,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.gold),
            onPressed: () {
              setState(() {
                _billController.clear();
                _customPercentController.clear();
                _splitController.text = '1';
                _billAmount = 0.0;
                _tipPercentage = 0.18;
                _splitCount = 1;
                _useCustomPercent = false;
              });
            },
            tooltip: 'Reset',
          ),
        ],
      ),
    );
  }

  Widget _buildBillInput() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  color: AppColors.gold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bill Amount',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _billController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.textOnGreen,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: AppTypography.displaySmall.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
                hintText: '0.00',
                hintStyle: AppTypography.displaySmall.copyWith(
                  color: AppColors.slateGray.withOpacity(0.5),
                ),
                filled: true,
                fillColor: AppColors.feltGreen,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gold, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
              onChanged: (_) => _calculateTip(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipPercentSection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.percent,
                  color: AppColors.gold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tip Percentage',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Preset buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _percentPresets.map((percent) {
                final isSelected = !_useCustomPercent && _tipPercentage == percent;
                return _buildPercentButton(
                  '${(percent * 100).toInt()}%',
                  percent,
                  isSelected,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // Custom percent
            Row(
              children: [
                Checkbox(
                  value: _useCustomPercent,
                  onChanged: (value) {
                    setState(() {
                      _useCustomPercent = value ?? false;
                      if (_useCustomPercent) {
                        _calculateTip();
                      }
                    });
                  },
                  activeColor: AppColors.gold,
                  checkColor: AppColors.feltGreen,
                ),
                Text(
                  'Custom:',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textOnGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _customPercentController,
                    enabled: _useCustomPercent,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textOnGreen,
                    ),
                    decoration: InputDecoration(
                      suffixText: '%',
                      hintText: '0',
                      filled: true,
                      fillColor: AppColors.feltGreen,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.gold),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) => _calculateTip(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentButton(String label, double percent, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _useCustomPercent = false;
          _tipPercentage = percent;
          _calculateTip();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withOpacity(0.2)
              : AppColors.feltGreen,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.gold.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? AppColors.gold : AppColors.textOnGreen,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSplitSection() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.people,
                  color: AppColors.gold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Split Bill',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.gold,
                  onPressed: () {
                    final current = int.tryParse(_splitController.text) ?? 1;
                    if (current > 1) {
                      _splitController.text = (current - 1).toString();
                      _calculateTip();
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _splitController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textOnGreen,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.feltGreen,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.gold),
                      ),
                    ),
                    onChanged: (_) => _calculateTip(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.gold,
                  onPressed: () {
                    final current = int.tryParse(_splitController.text) ?? 1;
                    _splitController.text = (current + 1).toString();
                    _calculateTip();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${_splitCount} ${_splitCount == 1 ? 'person' : 'people'}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return SmartCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calculate,
                  color: AppColors.gold,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Calculation',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildResultRow('Bill Amount', '\$${_billAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _buildResultRow(
              'Tip (${(_tipPercentage * 100).toStringAsFixed(0)}%)',
              '\$${_tipAmount.toStringAsFixed(2)}',
              isHighlighted: true,
            ),
            const SizedBox(height: 12),
            Divider(color: AppColors.gold.withOpacity(0.3)),
            const SizedBox(height: 12),
            _buildResultRow(
              'Total',
              '\$${_totalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
            
            if (_splitCount > 1) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Per Person',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.slateGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${_perPersonAmount.toStringAsFixed(2)}',
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Includes \$${_perPersonTip.toStringAsFixed(2)} tip',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.slateGray,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isHighlighted = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isTotal ? AppColors.gold : AppColors.slateGray,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: (isTotal ? AppTypography.displaySmall : AppTypography.bodyLarge).copyWith(
            color: isHighlighted || isTotal ? AppColors.gold : AppColors.textOnGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
