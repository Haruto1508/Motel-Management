import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/core/utils/date_formatter.dart';
import 'package:rental_management/core/utils/validators.dart';
import 'package:rental_management/core/widgets/app_button.dart';
import 'package:rental_management/core/widgets/app_card.dart';
import 'package:rental_management/core/widgets/app_scaffold.dart';
import 'package:rental_management/core/widgets/app_text_field.dart';
import 'package:rental_management/core/widgets/loading_view.dart';
import 'package:rental_management/features/contracts/domain/usecases/create_contract_usecase.dart';
import 'package:rental_management/features/contracts/domain/usecases/update_contract_usecase.dart';
import 'package:rental_management/features/contracts/presentation/providers/contract_providers.dart';
import 'package:rental_management/features/contracts/presentation/providers/contracts_list_controller.dart';
import 'package:rental_management/features/rooms/presentation/providers/rooms_providers.dart';
import 'package:rental_management/features/tenants/presentation/providers/tenant_providers.dart';

class ContractFormPage extends ConsumerStatefulWidget {
  final String? contractId;
  final String? initialRoomId;

  const ContractFormPage({super.key, this.contractId, this.initialRoomId});

  @override
  ConsumerState<ContractFormPage> createState() => _ContractFormPageState();
}

class _ContractFormPageState extends ConsumerState<ContractFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _contractNumberController = TextEditingController();
  final _monthlyRentController = TextEditingController();
  final _depositController = TextEditingController();
  final _dueDayController = TextEditingController(text: '5');
  final _termsController = TextEditingController();

  String? _selectedRoomId;
  String? _selectedTenantId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));

  bool _isLoading = false;
  bool _isInit = false;

  bool get isEditing => widget.contractId != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialRoomId != null) {
      _selectedRoomId = widget.initialRoomId;
    }
    // Gợi ý số hợp đồng ngẫu nhiên
    if (!isEditing) {
      final now = DateTime.now();
      _contractNumberController.text = 'HD-${now.year}-${now.millisecondsSinceEpoch.toString().substring(8)}';
    }
  }

  @override
  void dispose() {
    _contractNumberController.dispose();
    _monthlyRentController.dispose();
    _depositController.dispose();
    _dueDayController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  void _loadExistingContract(dynamic contract) {
    if (_isInit) return;
    _contractNumberController.text = contract.contractNumber;
    _selectedRoomId = contract.roomId;
    _selectedTenantId = contract.primaryTenantId;
    _startDate = contract.startDate;
    _endDate = contract.endDate;
    _monthlyRentController.text = contract.monthlyRent.toInt().toString();
    _depositController.text = contract.depositAmount.toInt().toString();
    _dueDayController.text = contract.paymentDueDay.toString();
    _termsController.text = contract.terms ?? '';
    _isInit = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phòng thuê'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedTenantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn người đại diện thuê'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ngày kết thúc phải sau ngày bắt đầu'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rent = double.tryParse(_monthlyRentController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final deposit = double.tryParse(_depositController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final dueDay = int.tryParse(_dueDayController.text) ?? 5;

      if (isEditing) {
        final updateUseCase = ref.read(updateContractUseCaseProvider);
        await updateUseCase(
          widget.contractId!,
          UpdateContractParams(
            startDate: _startDate,
            endDate: _endDate,
            monthlyRent: rent,
            depositAmount: deposit,
            paymentDueDay: dueDay,
            terms: _termsController.text.trim().isEmpty ? null : _termsController.text.trim(),
          ),
        );
        ref.invalidate(contractDetailProvider(widget.contractId!));
      } else {
        final createUseCase = ref.read(createContractUseCaseProvider);
        await createUseCase(
          CreateContractParams(
            contractNumber: _contractNumberController.text.trim(),
            roomId: _selectedRoomId!,
            primaryTenantId: _selectedTenantId!,
            startDate: _startDate,
            endDate: _endDate,
            monthlyRent: rent,
            depositAmount: deposit,
            paymentDueDay: dueDay,
            terms: _termsController.text.trim().isEmpty ? null : _termsController.text.trim(),
          ),
        );
      }

      await ref.read(contractsListControllerProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Cập nhật hợp đồng thành công' : 'Tạo hợp đồng thành công'),
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      final contractAsync = ref.watch(contractDetailProvider(widget.contractId!));
      return contractAsync.when(
        loading: () => const Scaffold(body: LoadingView()),
        error: (err, _) => Scaffold(
          appBar: AppBar(title: const Text('Lỗi')),
          body: Center(child: Text(err.toString())),
        ),
        data: (contract) {
          _loadExistingContract(contract);
          return _buildFormScaffold();
        },
      );
    }

    return _buildFormScaffold();
  }

  Widget _buildFormScaffold() {
    final roomsAsync = ref.watch(getRoomsUseCaseProvider);
    final tenantsAsync = ref.watch(getTenantsUseCaseProvider);

    return AppScaffold(
      title: isEditing ? 'Chỉnh sửa hợp đồng' : 'Tạo hợp đồng thuê mới',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin định danh hợp đồng
              AppCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thông tin chung', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Số hợp đồng *',
                      hint: 'HD-2026-101',
                      controller: _contractNumberController,
                      prefixIcon: const Icon(Icons.tag),
                      validator: (val) => Validators.required(val, 'Số hợp đồng'),
                    ),
                    const SizedBox(height: 12),

                    // Chọn phòng
                    Text('Phòng thuê *', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 6),
                    FutureBuilder(
                      future: roomsAsync(),
                      builder: (context, snapshot) {
                        final rooms = snapshot.data ?? [];
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedRoomId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          hint: const Text('Chọn phòng thuê'),
                          items: rooms.map((r) {
                            return DropdownMenuItem(
                              value: r.id,
                              child: Text('${r.roomCode} - ${r.name}'),
                            );
                          }).toList(),
                          onChanged: isEditing ? null : (val) {
                            setState(() {
                              _selectedRoomId = val;
                              final found = rooms.where((r) => r.id == val).firstOrNull;
                              if (found != null && _monthlyRentController.text.isEmpty) {
                                _monthlyRentController.text = found.monthlyRent.toInt().toString();
                                _depositController.text = found.monthlyRent.toInt().toString();
                              }
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Chọn khách thuê đại diện
                    Text('Người đại diện thuê *', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 6),
                    FutureBuilder(
                      future: tenantsAsync(),
                      builder: (context, snapshot) {
                        final tenants = snapshot.data ?? [];
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedTenantId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          hint: const Text('Chọn người đại diện ký hợp đồng'),
                          items: tenants.map((t) {
                            return DropdownMenuItem(
                              value: t.id,
                              child: Text('${t.fullName} (${t.phone})'),
                            );
                          }).toList(),
                          onChanged: isEditing ? null : (val) {
                            setState(() => _selectedTenantId = val);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Thời hạn hợp đồng
              AppCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thời hạn hợp đồng', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ngày bắt đầu', style: Theme.of(context).textTheme.labelMedium),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2035),
                                  );
                                  if (picked != null) setState(() => _startDate = picked);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormatter.format(_startDate)),
                                      const Icon(Icons.calendar_today_outlined, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ngày kết thúc', style: Theme.of(context).textTheme.labelMedium),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2035),
                                  );
                                  if (picked != null) setState(() => _endDate = picked);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormatter.format(_endDate)),
                                      const Icon(Icons.calendar_today_outlined, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tài chính & Điều khoản
              AppCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tài chính & Thu tiền', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Giá thuê hàng tháng (VNĐ) *',
                      hint: '3500000',
                      controller: _monthlyRentController,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.attach_money),
                      validator: (val) => Validators.positiveMoney(val, 'Giá thuê'),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Tiền đặt cọc (VNĐ) *',
                      hint: '3500000',
                      controller: _depositController,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.savings_outlined),
                      validator: (val) => Validators.required(val, 'Tiền đặt cọc'),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Ngày thu tiền định kỳ hàng tháng (1 - 31)',
                      hint: '5',
                      controller: _dueDayController,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.event_outlined),
                      validator: (val) {
                        final n = int.tryParse(val ?? '');
                        if (n == null || n < 1 || n > 31) {
                          return 'Vui lòng nhập ngày từ 1 đến 31';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Điều khoản & Ghi chú bổ sung',
                      hint: 'Ví dụ: Đặt cọc 1 tháng, thanh toán đầu tháng...',
                      controller: _termsController,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AppButton(
                text: isEditing ? 'Lưu thay đổi' : 'Ký hợp đồng',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
