import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/core/utils/currency_formatter.dart';
import 'package:rental_management/core/utils/date_formatter.dart';
import 'package:rental_management/core/widgets/app_button.dart';
import 'package:rental_management/core/widgets/app_card.dart';
import 'package:rental_management/core/widgets/app_scaffold.dart';
import 'package:rental_management/core/widgets/app_text_field.dart';
import 'package:rental_management/features/contracts/presentation/providers/contract_providers.dart';
import 'package:rental_management/features/invoices/domain/usecases/create_invoice_usecase.dart';
import 'package:rental_management/features/invoices/presentation/providers/invoice_providers.dart';
import 'package:rental_management/features/invoices/presentation/providers/invoices_list_controller.dart';
import 'package:rental_management/features/rooms/presentation/providers/rooms_providers.dart';
import 'package:rental_management/features/utilities/presentation/providers/utility_providers.dart';

class InvoiceFormPage extends ConsumerStatefulWidget {
  final String? initialRoomId;

  const InvoiceFormPage({super.key, this.initialRoomId});

  @override
  ConsumerState<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends ConsumerState<InvoiceFormPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedRoomId;
  String? _selectedTenantId;
  String? _selectedTenantName;

  final _invoiceNumberController = TextEditingController();
  final _rentController = TextEditingController();
  final _electricityController = TextEditingController(text: '0');
  final _waterController = TextEditingController(text: '0');
  final _internetController = TextEditingController(text: '100000');
  final _otherController = TextEditingController(text: '30000');
  final _discountController = TextEditingController(text: '0');
  final _noteController = TextEditingController();

  late String _billingMonth;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _billingMonth = '${now.month.toString().padLeft(2, '0')}/${now.year}';
    _selectedRoomId = widget.initialRoomId;

    _invoiceNumberController.text =
        'HD-${now.year}${now.month.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(9)}';

    if (_selectedRoomId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoFillRoomData(_selectedRoomId!);
      });
    }
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _rentController.dispose();
    _electricityController.dispose();
    _waterController.dispose();
    _internetController.dispose();
    _otherController.dispose();
    _discountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _autoFillRoomData(String roomId) async {
    setState(() => _isLoading = true);
    try {
      // 1. Lấy hợp đồng hiệu lực để biết giá thuê và khách đại diện
      final getContracts = ref.read(getContractsUseCaseProvider);
      final contracts = await getContracts.call();
      final activeContract = contracts.where((c) => c.roomId == roomId && c.isActive).firstOrNull;

      if (activeContract != null && mounted) {
        _rentController.text = activeContract.monthlyRent.toStringAsFixed(0);
        _selectedTenantId = activeContract.primaryTenantId;
        _selectedTenantName = activeContract.primaryTenantName;
      }

      // 2. Lấy chỉ số điện nước mới nhất của phòng
      final getLatest = ref.read(getLatestReadingUseCaseProvider);
      final latest = await getLatest.call(roomId);

      if (latest != null && mounted) {
        _electricityController.text = latest.electricityAmount.toStringAsFixed(0);
        _waterController.text = latest.waterAmount.toStringAsFixed(0);
      }
    } catch (_) {
      // Ignored
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Real-time Calculations ---
  double get _rent => double.tryParse(_rentController.text) ?? 0;
  double get _electricity => double.tryParse(_electricityController.text) ?? 0;
  double get _water => double.tryParse(_waterController.text) ?? 0;
  double get _internet => double.tryParse(_internetController.text) ?? 0;
  double get _other => double.tryParse(_otherController.text) ?? 0;
  double get _discount => double.tryParse(_discountController.text) ?? 0;

  double get _totalCalculated {
    final subtotal = _rent + _electricity + _water + _internet + _other;
    final total = subtotal - _discount;
    return total > 0 ? total : 0;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phòng cần lập hóa đơn')),
      );
      return;
    }

    // Nếu phòng chưa có hợp đồng để lấy tenantId, dùng tạm ID phòng
    _selectedTenantId ??= 'tenant_for_room_$_selectedRoomId';

    setState(() => _isLoading = true);
    try {
      final params = CreateInvoiceParams(
        invoiceNumber: _invoiceNumberController.text.trim(),
        roomId: _selectedRoomId!,
        tenantId: _selectedTenantId!,
        billingMonth: _billingMonth,
        rentAmount: _rent,
        electricityAmount: _electricity,
        waterAmount: _water,
        internetAmount: _internet,
        otherAmount: _other,
        discountAmount: _discount,
        dueDate: _dueDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      final useCase = ref.read(createInvoiceUseCaseProvider);
      await useCase.call(params);

      await ref.read(invoicesListControllerProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lập hóa đơn tiền phòng thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roomsAsync = ref.watch(roomsListProvider);

    return AppScaffold(
      title: 'Lập hóa đơn tháng',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Phòng & Định danh
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin hóa đơn',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Số hóa đơn *',
                      controller: _invoiceNumberController,
                      prefixIcon: const Icon(Icons.tag),
                    ),
                    const SizedBox(height: 12),

                    // Chọn phòng
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
                              setState(() => _selectedRoomId = val);
                              _autoFillRoomData(val);
                            }
                          },
                          validator: (val) => val == null ? 'Vui lòng chọn phòng' : null,
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Không tải được danh sách phòng'),
                    ),
                    if (_selectedTenantName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Người đại diện: $_selectedTenantName',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
                      ),
                    ],
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Kỳ hóa đơn *',
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
                                initialDate: _dueDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _dueDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Hạn đóng tiền',
                                prefixIcon: Icon(Icons.today_outlined),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(DateFormatter.format(_dueDate)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Chi tiết các khoản phí
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Các khoản phí chi tiết (VNĐ)',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Tiền thuê phòng *',
                      controller: _rentController,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.home_work_outlined),
                      onChanged: (_) => setState(() {}),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Nhập tiền phòng';
                        final numVal = double.tryParse(val);
                        if (numVal == null || numVal <= 0) return 'Phải > 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Tiền điện',
                            controller: _electricityController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icon(Icons.bolt, color: Colors.amber.shade800),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Tiền nước',
                            controller: _waterController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icon(Icons.water_drop, color: Colors.blue.shade600),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Internet / WiFi',
                            controller: _internetController,
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.wifi, color: Colors.indigo),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Rác / Dịch vụ khác',
                            controller: _otherController,
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.delete_outline, color: Colors.teal),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    AppTextField(
                      label: 'Giảm giá / Khuyến mãi',
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.discount_outlined, color: Colors.red),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Tổng cộng preview
              AppCard(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng tiền hóa đơn:',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      CurrencyFormatter.format(_totalCalculated),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Ghi chú thêm',
                controller: _noteController,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              AppButton(
                text: 'Phát hành hóa đơn',
                icon: Icons.check_circle_outline,
                isLoading: _isLoading,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
