import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rental_management/core/extensions/context_extensions.dart';
import 'package:rental_management/core/utils/validators.dart';
import 'package:rental_management/core/widgets/app_button.dart';
import 'package:rental_management/core/widgets/app_scaffold.dart';
import 'package:rental_management/core/widgets/app_text_field.dart';
import 'package:rental_management/features/rooms/domain/entities/room_status.dart';
import 'package:rental_management/features/rooms/domain/repositories/room_repository.dart';
import 'package:rental_management/features/rooms/presentation/providers/rooms_providers.dart';

class RoomFormPage extends ConsumerStatefulWidget {
  final String? roomId;

  const RoomFormPage({super.key, this.roomId});

  bool get isEditing => roomId != null;

  @override
  ConsumerState<RoomFormPage> createState() => _RoomFormPageState();
}

class _RoomFormPageState extends ConsumerState<RoomFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _roomCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _floorController = TextEditingController(text: '1');
  final _areaController = TextEditingController();
  final _rentController = TextEditingController();
  final _capacityController = TextEditingController(text: '2');
  final _descController = TextEditingController();

  RoomStatus _selectedStatus = RoomStatus.available;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    final detail = await ref.read(roomDetailProvider(widget.roomId!).future);
    final room = detail.room;
    _roomCodeController.text = room.roomCode;
    _nameController.text = room.name;
    _floorController.text = room.floor.toString();
    _areaController.text = room.area.toString();
    _rentController.text = room.monthlyRent.toInt().toString();
    _capacityController.text = room.capacity.toString();
    _descController.text = room.description ?? '';
    setState(() {
      _selectedStatus = room.status;
    });
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    _nameController.dispose();
    _floorController.dispose();
    _areaController.dispose();
    _rentController.dispose();
    _capacityController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.isEditing) {
        await ref.read(updateRoomUseCaseProvider)(
          widget.roomId!,
          UpdateRoomParams(
            name: _nameController.text.trim(),
            floor: int.parse(_floorController.text.trim()),
            area: double.parse(_areaController.text.trim()),
            monthlyRent: double.parse(_rentController.text.trim()),
            capacity: int.parse(_capacityController.text.trim()),
            status: _selectedStatus,
            description: _descController.text.trim(),
          ),
        );
        ref.invalidate(roomDetailProvider(widget.roomId!));
      } else {
        await ref.read(createRoomUseCaseProvider)(
          CreateRoomParams(
            roomCode: _roomCodeController.text.trim(),
            name: _nameController.text.trim(),
            floor: int.parse(_floorController.text.trim()),
            area: double.parse(_areaController.text.trim()),
            monthlyRent: double.parse(_rentController.text.trim()),
            capacity: int.parse(_capacityController.text.trim()),
            status: _selectedStatus,
            description: _descController.text.trim(),
          ),
        );
      }

      await ref.read(roomsListControllerProvider.notifier).loadRooms();

      if (mounted) {
        context.showSuccessSnackBar(
          widget.isEditing
              ? 'Cập nhật thông tin phòng thành công!'
              : 'Thêm phòng trọ mới thành công!',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          'Không thể lưu phòng: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.isEditing ? 'Chỉnh sửa phòng' : 'Thêm phòng mới',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _roomCodeController,
                label: 'Mã phòng',
                hint: 'Ví dụ: P101, A201',
                enabled: !widget.isEditing,
                validator: (val) => Validators.required(val, 'Mã phòng'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameController,
                label: 'Tên phòng',
                hint: 'Ví dụ: Phòng 101 có ban công',
                validator: (val) => Validators.required(val, 'Tên phòng'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _floorController,
                      label: 'Tầng',
                      hint: '1',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) => Validators.required(val, 'Tầng lầu'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _areaController,
                      label: 'Diện tích (m²)',
                      hint: '25',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => Validators.required(val, 'Diện tích'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _rentController,
                      label: 'Giá thuê / tháng (₫)',
                      hint: '3000000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) => Validators.positiveMoney(val, 'Giá thuê'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _capacityController,
                      label: 'Sức chứa (người)',
                      hint: '2',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: Validators.roomCapacity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RoomStatus>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái phòng',
                ),
                items: RoomStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descController,
                label: 'Mô tả thêm / Tiện ích phòng',
                hint: 'Nội thất, máy lạnh, ban công...',
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              AppButton(
                text: widget.isEditing ? 'Lưu thay đổi' : 'Tạo phòng',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
