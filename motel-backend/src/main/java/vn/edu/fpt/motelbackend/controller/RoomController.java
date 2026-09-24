package vn.edu.fpt.motelbackend.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.motelbackend.dto.ApiResponse;
import vn.edu.fpt.motelbackend.dto.room.*;
import vn.edu.fpt.motelbackend.service.RoomService;

import java.util.List;

@RestController
@RequestMapping("/api/v1/rooms")
@RequiredArgsConstructor
public class RoomController {

    private final RoomService roomService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<RoomResponse>>> getRooms(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Integer floor) {
        List<RoomResponse> rooms = roomService.getRooms(query, status, floor);
        return ResponseEntity.ok(ApiResponse.ok(rooms));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<RoomDetailResponse>> getRoomById(@PathVariable String id) {
        RoomDetailResponse detail = roomService.getRoomDetail(id);
        return ResponseEntity.ok(ApiResponse.ok(detail));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<RoomResponse>> createRoom(@Valid @RequestBody RoomRequest request) {
        RoomResponse room = roomService.createRoom(request);
        return ResponseEntity.ok(ApiResponse.ok(room, "Thêm phòng mới thành công"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<RoomResponse>> updateRoom(
            @PathVariable String id,
            @Valid @RequestBody RoomRequest request) {
        RoomResponse room = roomService.updateRoom(id, request);
        return ResponseEntity.ok(ApiResponse.ok(room, "Cập nhật phòng thành công"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteRoom(@PathVariable String id) {
        roomService.deleteRoom(id);
        return ResponseEntity.ok(ApiResponse.ok(null, "Xóa phòng thành công"));
    }

    @PostMapping("/{roomId}/members")
    public ResponseEntity<ApiResponse<RoomMemberResponse>> addMemberToRoom(
            @PathVariable String roomId,
            @Valid @RequestBody RoomMemberRequest request) {
        RoomMemberResponse member = roomService.addMemberToRoom(roomId, request);
        return ResponseEntity.ok(ApiResponse.ok(member, "Thêm khách vào phòng thành công"));
    }

    @DeleteMapping("/{roomId}/members/{memberId}")
    public ResponseEntity<ApiResponse<Void>> removeMemberFromRoom(
            @PathVariable String roomId,
            @PathVariable String memberId) {
        roomService.removeMemberFromRoom(roomId, memberId);
        return ResponseEntity.ok(ApiResponse.ok(null, "Đã xóa khách khỏi phòng"));
    }
}
