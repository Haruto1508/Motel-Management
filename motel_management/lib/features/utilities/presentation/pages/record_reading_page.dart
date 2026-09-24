import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/core/utils/currency_formatter.dart';
import 'package:rental_management/core/utils/date_formatter.dart';
import 'package:rental_management/core/widgets/app_button.dart';
import 'package:rental_management/core/widgets/app_card.dart';
import 'package:rental_management/core/widgets/app_scaffold.dart';
import 'package:rental_management/core/widgets/app_text_field.dart';
import 'package:rental_management/features/rooms/presentation/providers/rooms_providers.dart';
import 'package:rental_management/features/utilities/domain/entities/water_calc_method.dart';
import 'package:rental_management/features/utilities/domain/usecases/record_utility_reading_usecase.dart';
import 'package:rental_management/features/utilities/presentation/providers/utilities_controller.dart';
import 'package:rental_management/features/utilities/presentation/providers/utility_providers.dart';

class RecordReadingPage extends ConsumerStatefulWidget {
  final String? initialRoomId;

  const RecordReadingPage({super.key, this.initialRoomId});

  @override
  ConsumerState<RecordReadingPage> createState() => _RecordReadingPageState();
}

class _RecordReadingPageState extends ConsumerState<RecordReadingPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedRoomId;
  String? _selectedRoomCode;

  final _prevElectricityController = TextEditingController();
  final _currElectricityController = TextEditingController();
  final _electricityPriceController = TextEditingController(text: '3500');

  final _prevWaterController = TextEditingController();
  final _currWaterController = TextEditingController();
  final _waterPriceController = TextEditingController(text: '25000');

  final _noteController = TextEditingController();

  WaterCalcMethod _waterCalcMethod = WaterCalcMethod.meter;
  DateTime _readingDate = DateTime.now();
  late String _billingMonth;

  bool _isLoadingLatest = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _billingMonth = '${now.month.toString().padLeft(2, '0')}/${now.year}';
    _selectedRoomId = widget.initialRoomId;

    if (_selectedRoomId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadLatestReadingForRoom(_selectedRoomId!);
      });
    }
  }

  @override
  void dispose() {
    _prevElectricityController.dispose();
    _currElectricityController.dispose();
    _electricityPriceController.dispose();
    _prevWaterController.dispose();
    _currWaterController.dispose();
    _waterPriceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadLatestReadingForRoom(String roomId) async {
    setState(() => _isLoadingLatest = true);
    try {
      final getLatest = ref.read(getLatestReadingUseCaseProvider);
      final latest = await getLatest.call(roomId);

      if (latest != null && mounted) {
        _prevElectricityController.text = latest.currentElectricity.toStringAsFixed(0);
        _prevWaterController.text = latest.currentWater.toStringAsFixed(0);
        _electricityPriceController.text = latest.electricityPrice.toStringAsFixed(0);
        _waterPriceController.text = latest.waterPrice.toStringAsFixed(0);
        _waterCalcMethod = latest.waterCalcMethod;
      }
    } catch (_) {
      // Ignored
    } finally {
      if (mounted) setState(() => _isLoadingLatest = false);
    }
  }

  // --- Real-time Calculations ---
  double get _prevElectricity => double.tryParse(_prevElectricityController.text) ?? 0;
  double get _currElectricity => double.tryParse(_currElectricityController.text) ?? 0;
  double get _elecPrice => double.tryParse(_electricityPriceController.text) ?? 3500;

  double get _prevWater => double.tryParse(_prevWaterController.text) ?? 0;
  double get _currWater => double.tryParse(_currWaterController.text) ?? 0;
  double get _waterPrice => double.tryParse(_waterPriceController.text) ?? 25000;

  double get _elecConsumption {
    final diff = _currElectricity - _prevElectricity;
    return diff > 0 ? diff : 0;
  }

  double get _elecAmount => _elecConsumption * _elecPrice;

  double get _waterConsumption {
    if (_waterCalcMethod != WaterCalcMethod.meter) return 0;
    final diff = _currWater - _prevWater;
    return diff > 0 ? diff : 0;
  }

  double get _waterAmount {
    if (_waterCalcMethod == WaterCalcMethod.meter) {
      return _waterConsumption * _waterPrice;
    }
    return _waterPrice;
  }

  double get _totalEstimated => _elecAmount + _waterAmount;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phòng cần ghi chỉ số')),
      );
      return;
    }

    if (_currElectricity < _prevElectricity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ số điện mới không được nhỏ hơn chỉ số cũ!')),
      );
      return;
    }

    if (_waterCalcMethod == WaterCalcMethod.meter && _currWater < _prevWater) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ số nước mới không được nhỏ hơn chỉ số cũ!')),
      );
      return;
    }

    final params = RecordUtilityParams(
      roomId: _selectedRoomId!,
      billingMonth: _billingMonth,
      readingDate: _readingDate,
      previousElectricity: _prevElectricity,
      currentElectricity: _currElectricity,
      electricityPrice: _elecPrice,
      previousWater: _prevWater,
      currentWater: _currWater,
      waterPrice: _waterPrice,
      waterCalcMethod: _waterCalcMethod,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    final success = await ref.read(utilitiesControllerProvider.notifier).recordReading(params);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã ghi chỉ số điện nước cho phòng ${_selectedRoomCode ?? ""}'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roomsAsync = ref.watch(roomsListProvider);
    final controllerState = ref.watch(utilitiesControllerProvider);

    return AppScaffold(
      title: 'Ghi chỉ số điện nước',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Chọn phòng & Chu kỳ
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin ghi số',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    roomsAsync.when(
                      data: (rooms) {
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedRoomId,
                          decoration: const InputDecoration(
                            labelText: 'Chọn phòng trọ *',
                            prefixIcon: Icon(Icons.meeting_room_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: rooms.map((r) {
                            return DropdownMenuItem(
                              value: r.id,
                              child: Text('${r.roomCode} - ${r.name}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedRoomId = val;
                                final room = rooms.firstWhere((r) => r.id == val);
                                _selectedRoomCode = room.roomCode;
                              });
                              _loadLatestReadingForRoom(val);
                            }
                          },
                          validator: (val) => val == null ? 'Vui lòng chọn phòng' : null,
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Không tải được danh sách phòng'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Kỳ thanh toán *',
                            controller: TextEditingController(text: _billingMonth),
                            prefixIcon: const Icon(Icons.calendar_month_outlined),
                            onChanged: (val) => _billingMonth = val,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _readingDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _readingDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Ngày chốt số',
                                prefixIcon: Icon(Icons.today_outlined),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(DateFormatter.format(_readingDate)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_isLoadingLatest)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(child: CircularProgressIndicator()),
                ),

              // 2. Chỉ số ĐIỆN
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bolt, color: Colors.amber.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Chỉ số Điện (kWh)',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Chỉ số cũ',
                            controller: _prevElectricityController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Chỉ số mới *',
                            controller: _currElectricityController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Nhập số điện';
                              }
                              final numVal = double.tryParse(val);
                              if (numVal == null) return 'Không hợp lệ';
                              if (numVal < _prevElectricity) {
                                return 'Phải ≥ số cũ';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Đơn giá điện (VNĐ/kWh)',
                      controller: _electricityPriceController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Chỉ số NƯỚC
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.water_drop, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Chỉ số Nước',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<WaterCalcMethod>(
                      initialValue: _waterCalcMethod,
                      decoration: const InputDecoration(
                        labelText: 'Cách tính tiền nước',
                        border: OutlineInputBorder(),
                      ),
                      items: WaterCalcMethod.values.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(m.label),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _waterCalcMethod = val);
                      },
                    ),
                    if (_waterCalcMethod == WaterCalcMethod.meter) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Chỉ số cũ (m³)',
                              controller: _prevWaterController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Chỉ số mới (m³) *',
                              controller: _currWaterController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Nhập số nước';
                                }
                                final numVal = double.tryParse(val);
                                if (numVal == null) return 'Không hợp lệ';
                                if (numVal < _prevWater) {
                                  return 'Phải ≥ số cũ';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    AppTextField(
                      label: _waterCalcMethod == WaterCalcMethod.meter
                          ? 'Đơn giá nước (VNĐ/m³)'
                          : 'Tiền nước khoán (VNĐ/tháng)',
                      controller: _waterPriceController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. BẢNG TÍNH THỰC TẾ (REAL-TIME PREVIEW)
              AppCard(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tạm tính tiêu thụ & thành tiền',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Điện tiêu thụ: ${_elecConsumption.toStringAsFixed(0)} kWh'),
                        Text(
                          CurrencyFormatter.format(_elecAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_waterCalcMethod == WaterCalcMethod.meter
                            ? 'Nước tiêu thụ: ${_waterConsumption.toStringAsFixed(0)} m³'
                            : 'Nước (${_waterCalcMethod.label}):'),
                        Text(
                          CurrencyFormatter.format(_waterAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng tiền tạm tính:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          CurrencyFormatter.format(_totalEstimated),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Ghi chú
              AppTextField(
                label: 'Ghi chú thêm',
                controller: _noteController,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              if (controllerState.errorMessage != null) ...[
                Text(
                  controllerState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 12),
              ],

              AppButton(
                text: 'Lưu chỉ số điện nước',
                icon: Icons.save_outlined,
                isLoading: controllerState.isLoading,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
