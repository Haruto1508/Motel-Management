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
import 'package:rental_management/features/tenants/domain/usecases/create_tenant_usecase.dart';
import 'package:rental_management/features/tenants/domain/usecases/update_tenant_usecase.dart';
import 'package:rental_management/features/tenants/presentation/providers/tenant_providers.dart';
import 'package:rental_management/features/tenants/presentation/providers/tenants_list_controller.dart';

class TenantFormPage extends ConsumerStatefulWidget {
  final String? tenantId;

  const TenantFormPage({super.key, this.tenantId});

  @override
  ConsumerState<TenantFormPage> createState() => _TenantFormPageState();
}

class _TenantFormPageState extends ConsumerState<TenantFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _identityController = TextEditingController();
  final _hometownController = TextEditingController();
  final _occupationController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _dateOfBirth;
  String _gender = 'Nam';
  String _status = 'ACTIVE';
  bool _isLoading = false;
  bool _isInit = false;

  bool get isEditing => widget.tenantId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _identityController.dispose();
    _hometownController.dispose();
    _occupationController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _loadExistingTenant(dynamic tenant) {
    if (_isInit) return;
    _nameController.text = tenant.fullName;
    _phoneController.text = tenant.phone;
    _emailController.text = tenant.email ?? '';
    _identityController.text = tenant.identityNumber ?? '';
    _hometownController.text = tenant.hometown ?? '';
    _occupationController.text = tenant.occupation ?? '';
    _emergencyContactController.text = tenant.emergencyContact ?? '';
    _emergencyPhoneController.text = tenant.emergencyPhone ?? '';
    _noteController.text = tenant.note ?? '';
    _dateOfBirth = tenant.dateOfBirth;
    _gender = tenant.gender ?? 'Nam';
    _status = tenant.status.code;
    _isInit = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (isEditing) {
        final updateUseCase = ref.read(updateTenantUseCaseProvider);
        await updateUseCase(
          widget.tenantId!,
          UpdateTenantParams(
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
            identityNumber: _identityController.text.trim().isEmpty
                ? null
                : _identityController.text.trim(),
            dateOfBirth: _dateOfBirth,
            gender: _gender,
            hometown: _hometownController.text.trim().isEmpty
                ? null
                : _hometownController.text.trim(),
            occupation: _occupationController.text.trim().isEmpty
                ? null
                : _occupationController.text.trim(),
            emergencyContact: _emergencyContactController.text.trim().isEmpty
                ? null
                : _emergencyContactController.text.trim(),
            emergencyPhone: _emergencyPhoneController.text.trim().isEmpty
                ? null
                : _emergencyPhoneController.text.trim(),
            note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
            status: _status,
          ),
        );
        ref.invalidate(tenantDetailProvider(widget.tenantId!));
      } else {
        final createUseCase = ref.read(createTenantUseCaseProvider);
        await createUseCase(
          CreateTenantParams(
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
            identityNumber: _identityController.text.trim().isEmpty
                ? null
                : _identityController.text.trim(),
            dateOfBirth: _dateOfBirth,
            gender: _gender,
            hometown: _hometownController.text.trim().isEmpty
                ? null
                : _hometownController.text.trim(),
            occupation: _occupationController.text.trim().isEmpty
                ? null
                : _occupationController.text.trim(),
            emergencyContact: _emergencyContactController.text.trim().isEmpty
                ? null
                : _emergencyContactController.text.trim(),
            emergencyPhone: _emergencyPhoneController.text.trim().isEmpty
                ? null
                : _emergencyPhoneController.text.trim(),
            note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          ),
        );
      }

      await ref.read(tenantsListControllerProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Cập nhật khách thuê thành công' : 'Thêm khách thuê thành công'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
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
    if (isEditing) {
      final tenantAsync = ref.watch(tenantDetailProvider(widget.tenantId!));
      return tenantAsync.when(
        loading: () => const Scaffold(body: LoadingView()),
        error: (err, _) => Scaffold(
          appBar: AppBar(title: const Text('Lỗi')),
          body: Center(child: Text(err.toString())),
        ),
        data: (tenant) {
          _loadExistingTenant(tenant);
          return _buildFormScaffold();
        },
      );
    }

    return _buildFormScaffold();
  }

  Widget _buildFormScaffold() {
    return AppScaffold(
      title: isEditing ? 'Chỉnh sửa khách thuê' : 'Thêm khách thuê mới',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin cơ bản
              AppCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin cơ bản',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Họ và tên *',
                      hint: 'Nguyễn Văn A',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (val) => Validators.required(val, 'Họ và tên'),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Số điện thoại *',
                      hint: '0901234567',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      validator: Validators.phone,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'CCCD / CMND',
                      hint: '12 chữ số căn cước',
                      controller: _identityController,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.badge_outlined),
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          return Validators.identityNumber(val);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Email',
                      hint: 'example@gmail.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (val) {
                        if (val != null && val.trim().isNotEmpty) {
                          return Validators.email(val);
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Thông tin bổ sung
              AppCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin bổ sung',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Giới tính', style: Theme.of(context).textTheme.labelMedium),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _gender,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                                  DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                                  DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _gender = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ngày sinh', style: Theme.of(context).textTheme.labelMedium),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _dateOfBirth ?? DateTime(2000, 1, 1),
                                    firstDate: DateTime(1950),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => _dateOfBirth = picked);
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
                                      Text(
                                        _dateOfBirth != null
                                            ? DateFormatter.format(_dateOfBirth!)
                                            : 'Chọn ngày',
                                        style: TextStyle(
                                          color: _dateOfBirth == null ? Colors.grey : null,
                                        ),
                                      ),
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
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Quê quán',
                      hint: 'Tỉnh / Thành phố',
                      controller: _hometownController,
                      prefixIcon: const Icon(Icons.home_outlined),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Nghề nghiệp',
                      hint: 'Sinh viên, Nhân viên văn phòng...',
                      controller: _occupationController,
                      prefixIcon: const Icon(Icons.work_outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Người liên hệ khẩn cấp
              AppCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Liên hệ khẩn cấp',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Họ tên người thân',
                      hint: 'Bố, Mẹ, Người giám hộ...',
                      controller: _emergencyContactController,
                      prefixIcon: const Icon(Icons.contact_phone_outlined),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Số điện thoại khẩn cấp',
                      hint: '0987654321',
                      controller: _emergencyPhoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_in_talk_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Ghi chú & Trạng thái
              AppCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isEditing) ...[
                      Text('Trạng thái khách thuê', style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'ACTIVE', child: Text('Đang thuê (ACTIVE)')),
                          DropdownMenuItem(value: 'INACTIVE', child: Text('Tạm ngưng (INACTIVE)')),
                          DropdownMenuItem(value: 'LEFT', child: Text('Đã trả phòng (LEFT)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    AppTextField(
                      label: 'Ghi chú',
                      hint: 'Ghi chú thêm về khách thuê...',
                      controller: _noteController,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AppButton(
                text: isEditing ? 'Lưu thay đổi' : 'Tạo hồ sơ khách thuê',
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
