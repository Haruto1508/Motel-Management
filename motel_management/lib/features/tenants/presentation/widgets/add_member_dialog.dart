import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/core/utils/date_formatter.dart';
import 'package:rental_management/core/widgets/app_button.dart';
import 'package:rental_management/core/widgets/app_text_field.dart';
import 'package:rental_management/features/tenants/domain/usecases/create_tenant_usecase.dart';
import 'package:rental_management/features/tenants/domain/usecases/room_member_usecases.dart';
import 'package:rental_management/features/tenants/presentation/providers/tenant_providers.dart';

class AddMemberDialog extends ConsumerStatefulWidget {
  final String roomId;
  final String roomCode;
  final int capacity;
  final int currentOccupancy;
  final bool hasPrimaryTenant;

  const AddMemberDialog({
    super.key,
    required this.roomId,
    required this.roomCode,
    required this.capacity,
    required this.currentOccupancy,
    required this.hasPrimaryTenant,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String roomId,
    required String roomCode,
    required int capacity,
    required int currentOccupancy,
    required bool hasPrimaryTenant,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AddMemberDialog(
        roomId: roomId,
        roomCode: roomCode,
        capacity: capacity,
        currentOccupancy: currentOccupancy,
        hasPrimaryTenant: hasPrimaryTenant,
      ),
    );
  }

  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _identityController = TextEditingController();

  String _role = 'MEMBER';
  DateTime _moveInDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Nếu phòng chưa có đại diện, mặc định chọn PRIMARY
    if (!widget.hasPrimaryTenant) {
      _role = 'PRIMARY';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _identityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.currentOccupancy >= widget.capacity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phòng đã đạt sức chứa tối đa, không thể thêm thành viên mới!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Tạo hồ sơ khách thuê mới nếu nhập thông tin
      final createTenantUseCase = ref.read(createTenantUseCaseProvider);
      final newTenant = await createTenantUseCase(
        CreateTenantParams(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          identityNumber: _identityController.text.trim().isEmpty
              ? null
              : _identityController.text.trim(),
        ),
      );

      // 2. Gán vào phòng
      final addMemberUseCase = ref.read(addMemberToRoomUseCaseProvider);
      await addMemberUseCase(
        AddMemberToRoomParams(
          roomId: widget.roomId,
          tenantId: newTenant.id,
          role: _role,
          moveInDate: _moveInDate,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi thêm thành viên: $e'),
            backgroundColor: Colors.red,
          ),
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
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Thêm thành viên (${widget.roomCode})'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sức chứa tóm tắt
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Hiện tại: ${widget.currentOccupancy}/${widget.capacity} người',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Họ và tên *',
                  hint: 'Nguyễn Văn A',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Vui lòng nhập họ tên';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                AppTextField(
                  label: 'Số điện thoại *',
                  hint: '0901234567',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Vui lòng nhập SĐT';
                    if (val.trim().length < 9) return 'SĐT không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                AppTextField(
                  label: 'CCCD / CMND',
                  hint: '001298001234',
                  controller: _identityController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
                const SizedBox(height: 12),

                // Vai trò
                Text('Vai trò trong phòng', style: theme.textTheme.labelMedium),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'MEMBER',
                      child: Text('Thành viên ở chung'),
                    ),
                    DropdownMenuItem(
                      value: 'PRIMARY',
                      enabled: !widget.hasPrimaryTenant || _role == 'PRIMARY',
                      child: Text(
                        widget.hasPrimaryTenant && _role != 'PRIMARY'
                            ? 'Người đại diện (Đã có)'
                            : 'Người đại diện thuê',
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _role = val);
                  },
                ),
                const SizedBox(height: 12),

                // Ngày chuyển vào
                Text('Ngày chuyển vào', style: theme.textTheme.labelMedium),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _moveInDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _moveInDate = picked);
                    }
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
                        Text(DateFormatter.format(_moveInDate)),
                        const Icon(Icons.calendar_today_outlined, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        AppButton(
          text: 'Thêm',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}
